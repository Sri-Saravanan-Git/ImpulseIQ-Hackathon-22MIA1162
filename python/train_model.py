import pandas as pd
import numpy as np
import os
import json
import pickle
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import IsolationForest
from sklearn.metrics import classification_report, roc_auc_score
from xgboost import XGBClassifier
import tensorflow as tf

# ─── PATHS ────────────────────────────────────────────
BASE = os.path.dirname(__file__)
DATA_PATH = os.path.join(BASE, "data", "transactions.csv")
MODEL_OUT = os.path.join(BASE, "..", "assets", "models")
os.makedirs(MODEL_OUT, exist_ok=True)

# ─── LOAD DATA ────────────────────────────────────────
print("📂 Loading dataset...")
df = pd.read_csv(DATA_PATH)
print(f"   {len(df)} records loaded")

# ─── FEATURE ENGINEERING ──────────────────────────────
print("\n⚙️  Engineering features...")

# Encode category
category_map = {c: i for i, c in enumerate(df["category"].unique())}
df["category_encoded"] = df["category"].map(category_map)

# Encode archetype
archetype_map = {"controlled": 0, "night_owl": 1, "eom_spender": 2, "freq_binger": 3}
df["archetype_encoded"] = df["archetype"].map(archetype_map)

# Spend ratio vs user average
df["spend_ratio"] = df["amount"] / df["avg_user_spend"]

# Hour buckets: morning/afternoon/evening/night
df["hour_bucket"] = pd.cut(df["hour"],
    bins=[-1, 6, 12, 18, 23],
    labels=[0, 1, 2, 3]).astype(int)

# Normalized gap (cap at 999)
df["gap_normalized"] = df["transaction_gap_minutes"].clip(upper=999) / 999

FEATURES = [
    "hour", "day_of_week", "day_of_month",
    "is_late_night", "is_end_of_month", "is_weekend",
    "spending_velocity", "gap_normalized",
    "category_switch_count", "mood_proxy_score",
    "spend_ratio", "category_encoded", "hour_bucket"
]

X = df[FEATURES].values
y = df["impulse_label"].values

# ─── ANOMALY DETECTION (Isolation Forest) ─────────────
print("\n🔍 Training Isolation Forest (anomaly detection)...")
iso = IsolationForest(n_estimators=100, contamination=0.15, random_state=42)
iso.fit(X)
df["anomaly_score"] = iso.decision_function(X)
df["is_anomaly"] = (iso.predict(X) == -1).astype(int)

anomaly_rate = df["is_anomaly"].mean()
print(f"   Anomaly rate detected: {anomaly_rate:.1%}")

# Add anomaly score as extra feature
X_enriched = np.column_stack([X, df["anomaly_score"].values])

# ─── TRAIN/TEST SPLIT ─────────────────────────────────
X_train, X_test, y_train, y_test = train_test_split(
    X_enriched, y, test_size=0.2, random_state=42, stratify=y
)

# Scale
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# ─── XGBOOST CLASSIFIER ───────────────────────────────
print("\n🤖 Training XGBoost classifier...")
scale_pos_weight = (y == 0).sum() / (y == 1).sum()

xgb = XGBClassifier(
    n_estimators=200,
    max_depth=6,
    learning_rate=0.1,
    scale_pos_weight=scale_pos_weight,
    use_label_encoder=False,
    eval_metric="logloss",
    random_state=42
)
xgb.fit(X_train_scaled, y_train,
        eval_set=[(X_test_scaled, y_test)],
        verbose=False)

y_pred = xgb.predict(X_test_scaled)
y_prob = xgb.predict_proba(X_test_scaled)[:, 1]

print("\n📊 Classification Report:")
print(classification_report(y_test, y_pred))
print(f"🎯 ROC-AUC Score: {roc_auc_score(y_test, y_prob):.4f}")

# ─── CONVERT TO TFLITE ────────────────────────────────
print("\n🔄 Converting to TFLite...")

# Build a small TF model that mimics XGBoost probabilities
input_dim = X_train_scaled.shape[1]
train_probs = xgb.predict_proba(X_train_scaled)[:, 1].reshape(-1, 1)

tf_model = tf.keras.Sequential([
    tf.keras.layers.Input(shape=(input_dim,)),
    tf.keras.layers.Dense(64, activation="relu"),
    tf.keras.layers.BatchNormalization(),
    tf.keras.layers.Dropout(0.3),
    tf.keras.layers.Dense(32, activation="relu"),
    tf.keras.layers.BatchNormalization(),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(16, activation="relu"),
    tf.keras.layers.Dense(1, activation="sigmoid")
])

tf_model.compile(optimizer="adam", loss="binary_crossentropy", metrics=["accuracy"])

print("   Training distillation model...")
tf_model.fit(
    X_train_scaled, train_probs,
    epochs=30, batch_size=64,
    validation_split=0.1,
    verbose=0
)
print("   ✅ Distillation complete")

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(tf_model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

tflite_path = os.path.join(MODEL_OUT, "impulse_model.tflite")
with open(tflite_path, "wb") as f:
    f.write(tflite_model)
print(f"   ✅ TFLite model saved: {tflite_path}")

# ─── SAVE METADATA ────────────────────────────────────
print("\n💾 Saving metadata...")

# Save scaler params
scaler_data = {
    "mean": scaler.mean_.tolist(),
    "scale": scaler.scale_.tolist(),
    "features": FEATURES + ["anomaly_score"]
}
with open(os.path.join(MODEL_OUT, "scaler.json"), "w") as f:
    json.dump(scaler_data, f, indent=2)

# Save category map
with open(os.path.join(MODEL_OUT, "category_map.json"), "w") as f:
    json.dump(category_map, f, indent=2)

# Save archetype map
with open(os.path.join(MODEL_OUT, "archetype_map.json"), "w") as f:
    json.dump(archetype_map, f, indent=2)

# Save feature importance
importance = dict(zip(FEATURES, xgb.feature_importances_[:len(FEATURES)]))
importance_sorted = dict(sorted({k: float(v) for k, v in importance.items()}.items(), key=lambda x: x[1], reverse=True))
with open(os.path.join(MODEL_OUT, "feature_importance.json"), "w") as f:
    json.dump(importance_sorted, f, indent=2)

print("   ✅ scaler.json saved")
print("   ✅ category_map.json saved")
print("   ✅ feature_importance.json saved")

print("\n🏆 ALL DONE! Files in assets/models/:")
for f in os.listdir(MODEL_OUT):
    size = os.path.getsize(os.path.join(MODEL_OUT, f))
    print(f"   {f} ({size/1024:.1f} KB)")