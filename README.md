# 🧠 ImpulseIQ — Financial Behaviour Intelligence

> Detecting impulse spending patterns in young adults using on-device machine learning & behavioural analytics.

![Flutter](https://img.shields.io/badge/Flutter-3.35.5-02569B?style=flat&logo=flutter)
![Python](https://img.shields.io/badge/Python-3.13-3776AB?style=flat&logo=python)
![XGBoost](https://img.shields.io/badge/Model-XGBoost-FF6600?style=flat)
![TFLite](https://img.shields.io/badge/Deploy-TFLite-FF6F00?style=flat&logo=tensorflow)
![ROC-AUC](https://img.shields.io/badge/ROC--AUC-98.21%25-00D4AA?style=flat)

---

## 📌 Problem Statement

Young adults (18–25) lack real-time awareness of **why** they spend impulsively. Traditional budgeting apps only show *what* was spent — not the behavioural triggers behind it.

**ImpulseIQ** bridges this gap with on-device ML that classifies spending behaviour in real-time and delivers personalized nudges before habits form.

---

## 🗂️ Dataset

### Type: **Synthetic**

**Why synthetic?**
No public dataset exists that captures impulse buying behaviour with emotional and temporal triggers. Real financial transaction data has strict privacy constraints. Synthetic data allows us to precisely encode known behavioural patterns and control ground truth labels.

### How it was generated

- **Tool:** Python (`generate_data.py`) with NumPy and Pandas
- **Rules & distributions:** Archetype-based transaction patterns with randomized amounts, timestamps, and categories following realistic distributions
- **Assumptions:** Impulse behaviour correlates with late-night hours, end-of-month timing, high spending velocity, and category switching

### Dataset Specs

| Property | Value |
|---|---|
| Total Records | 12,500 transactions |
| Users | 500 synthetic users |
| Transactions/user | 25 |
| Impulse rate | ~38% |
| Controlled rate | ~62% |
| Time range | Jan–Feb 2025 (synthetic) |

### Features (13 engineered)

| Feature | Description |
|---|---|
| `timestamp` | Transaction datetime |
| `merchant_category` | Spending category (10 types) |
| `amount` | Transaction amount (₹50–₹10,000) |
| `transaction_gap_minutes` | Time since last transaction |
| `is_late_night` | 1 if hour >= 23 or hour <= 3 |
| `is_end_of_month` | 1 if day >= 25 |
| `spending_velocity` | Transactions in last 2 hours / avg |
| `category_switch_count` | Unique categories in last 5 txns |
| `mood_proxy_score` | Composite emotional state score |
| `anomaly_score` | Isolation Forest output |
| `amount_ratio` | Amount / user average spend |
| `is_weekend` | 1 if Saturday or Sunday |
| `archetype_encoded` | Encoded behavioural archetype |

---

## 👤 Behavioural Archetypes

| Archetype | % of Users | Trigger |
|---|---|---|
| 🦉 Night Owl | 25% | Shops 11PM–3AM |
| 📅 EOM Spender | 20% | Month-end salary splurge |
| 🛒 Freq Binger | 20% | High transaction velocity |
| 🛡️ Controlled | 35% | Disciplined, planned spender |

---

## 🤖 ML Pipeline

```
Raw Transaction
     ↓
Feature Engineering (13 features)
     ↓
Isolation Forest (Anomaly Score)
     ↓
XGBoost Classifier
     ↓
Knowledge Distillation (30 epochs)
     ↓
TFLite Model (11KB)
     ↓
On-Device Prediction
```

### Model: XGBoost Classifier

- 200 estimators, max_depth=6, learning_rate=0.1
- `scale_pos_weight` for class imbalance
- 80/20 stratified train-test split
- Feature importance exported for explainability

### Hybrid Approach: + Isolation Forest

- Unsupervised anomaly detection (15% contamination)
- Anomaly score fed as feature into XGBoost
- Captures unknown impulse patterns without labels

---

## 📊 Evaluation Metrics

| Metric | Score |
|---|---|
| **ROC-AUC** | **98.21%** |
| Precision (Impulse) | 80% |
| Recall (Impulse) | 89% |
| F1-Score | 84% |
| Model Size (TFLite) | 11 KB |

### Top Feature Importances

| Feature | Importance |
|---|---|
| spending_velocity | 31% |
| mood_proxy_score | 24% |
| anomaly_score | 18% |
| is_late_night | 14% |
| amount_ratio | 9% |

---

## 📱 Flutter App — 5 Screens

### 1. 📊 Dashboard
- Animated impulse risk gauge (0–100)
- Total spend, impulse spend, impulse transaction count
- Recent spending pattern bar chart
- Last 5 transactions with risk badges

### 2. 🧬 Behaviour Analysis
- Archetype card with personalized description
- 6 behavioural dimension progress bars
- Hour-of-day spending heatmap
- Top 5 spending categories

### 3. 🔮 Prediction Engine
- Summary: High Risk / Caution / Safe counts
- Full transaction feed with impulse scores
- Explainable reasons per transaction

### 4. 💡 AI Nudges
- 4 personalized recommendations per archetype
- Controlled spending streak tracker

### 5. ⚡ Live Simulator *(Interactive)*
- Select category, amount, time of day
- Real-time impulse score with AI verdict
- "Why this score?" breakdown

---

## 🏗️ Project Structure

```
├── lib/
│   ├── core/
│   │   ├── ml/               # TFLite integration
│   │   ├── models/           # Transaction, UserProfile
│   │   └── services/         # Data generation, simulation
│   ├── features/
│   │   ├── dashboard/        # Risk gauge, stats
│   │   ├── behaviour/        # Archetypes, heatmap
│   │   ├── prediction/       # Detection feed
│   │   ├── nudges/           # AI recommendations
│   │   └── simulation/       # Live transaction tester
│   ├── theme/                # Dark theme, colors
│   └── main.dart
├── python/
│   ├── generate_data.py      # Synthetic dataset generation
│   ├── train_model.py        # XGBoost + TFLite pipeline
│   └── data/
│       └── transactions.csv  # Generated dataset
├── assets/
│   └── models/
│       ├── impulse_model.tflite
│       ├── scaler.json
│       ├── category_map.json
│       └── feature_importance.json
└── pubspec.yaml
```

---

## 🚀 Setup & Run

### Prerequisites
- Flutter 3.35+
- Python 3.10+
- Android Studio (for emulator) or physical device

### Generate Dataset & Train Model
```bash
cd python
pip install xgboost tensorflow pandas numpy scikit-learn
python generate_data.py
python train_model.py
```

### Run Flutter App
```bash
flutter pub get
flutter run
```

---

## 🔑 Key Assumptions

1. Impulse behaviour is detectable from transactional metadata alone (no direct emotional input)
2. Late-night hours (11PM–3AM) correlate with reduced decision-making quality
3. Rapid successive transactions indicate impulsive binge behaviour
4. End-of-month salary receipt triggers "treat yourself" psychology
5. Category switching within short time windows signals unplanned purchasing

---

## ⚖️ Important Rules Compliance

- ✅ **Data is synthetic** — clearly documented above
- ✅ **Original work** — no copied repositories
- ✅ **All assumptions explained**
- ✅ **Public repository**
- ✅ **ML/AI approach** — XGBoost + Isolation Forest hybrid

---

## 👨‍💻 Author

**Sri Saravanan K.B** — 22MIA1162  
Integrated M.Tech CSE (Business Analytics)  
Hackathon 2026
