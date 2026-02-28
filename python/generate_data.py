import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta
import os

np.random.seed(42)
random.seed(42)

# ─── CONFIG ───────────────────────────────────────────
NUM_USERS = 500
TRANSACTIONS_PER_USER = 25
OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "data", "transactions.csv")

CATEGORIES = [
    "Food & Dining", "Fashion", "Gaming", "Entertainment",
    "Electronics", "Grocery", "Travel", "Health", "Alcohol", "Subscriptions"
]

IMPULSE_CATEGORIES = {"Fashion", "Gaming", "Entertainment", "Alcohol", "Electronics"}

ARCHETYPES = {
    "night_owl":      {"weight": 0.25, "late_night_prob": 0.6,  "eom_prob": 0.2, "velocity_mean": 4},
    "eom_spender":    {"weight": 0.20, "late_night_prob": 0.15, "eom_prob": 0.7, "velocity_mean": 3},
    "freq_binger":    {"weight": 0.20, "late_night_prob": 0.3,  "eom_prob": 0.3, "velocity_mean": 7},
    "controlled":     {"weight": 0.35, "late_night_prob": 0.05, "eom_prob": 0.1, "velocity_mean": 1},
}

# ─── HELPERS ──────────────────────────────────────────
def pick_archetype():
    names = list(ARCHETYPES.keys())
    weights = [ARCHETYPES[a]["weight"] for a in names]
    return random.choices(names, weights=weights, k=1)[0]

def generate_timestamp(archetype_cfg, base_date):
    is_late_night = random.random() < archetype_cfg["late_night_prob"]
    is_eom = random.random() < archetype_cfg["eom_prob"]

    if is_eom:
        day = random.randint(26, 30)
    else:
        day = random.randint(1, 25)

    if is_late_night:
        hour = random.choice([23, 0, 1, 2, 3])
    else:
        hour = random.randint(8, 22)

    try:
        dt = base_date.replace(day=day, hour=hour, minute=random.randint(0, 59))
    except ValueError:
        dt = base_date.replace(day=28, hour=hour, minute=random.randint(0, 59))

    return dt

def compute_impulse_label(row, archetype):
    score = 0

    if row["is_late_night"]:
        score += 2
    if row["is_end_of_month"]:
        score += 1.5
    if row["category"] in IMPULSE_CATEGORIES:
        score += 2
    if row["spending_velocity"] >= 4:
        score += 1.5
    if row["category_switch_count"] >= 3:
        score += 1
    if row["amount"] > row["avg_user_spend"] * 2.5:
        score += 2
    if row["transaction_gap_minutes"] < 15:
        score += 1
    if archetype == "night_owl" and row["is_late_night"]:
        score += 1
    if archetype == "eom_spender" and row["is_end_of_month"]:
        score += 1
    if archetype == "freq_binger" and row["spending_velocity"] >= 5:
        score += 1.5

    # Add some noise
    score += np.random.normal(0, 0.5)

    return 1 if score >= 5 else 0

# ─── MAIN GENERATOR ───────────────────────────────────
def generate_dataset():
    records = []
    base_date = datetime(2025, 1, 1)

    for user_id in range(NUM_USERS):
        archetype = pick_archetype()
        arch_cfg = ARCHETYPES[archetype]

        # User's average spend (varies per person)
        avg_spend = random.uniform(200, 2000)

        timestamps = []
        for _ in range(TRANSACTIONS_PER_USER):
            month_offset = random.randint(0, 5)
            month_date = base_date + timedelta(days=30 * month_offset)
            ts = generate_timestamp(arch_cfg, month_date)
            timestamps.append(ts)

        timestamps.sort()

        recent_categories = []

        for i, ts in enumerate(timestamps):
            category = random.choice(CATEGORIES)

            # Amount: impulse categories tend to be higher
            if category in IMPULSE_CATEGORIES:
                amount = round(random.uniform(avg_spend * 0.5, avg_spend * 4), 2)
            else:
                amount = round(random.uniform(avg_spend * 0.1, avg_spend * 1.5), 2)

            is_late_night = ts.hour >= 23 or ts.hour <= 3
            is_end_of_month = ts.day >= 26
            is_weekend = ts.weekday() >= 5

            # Velocity: how many transactions in last 2 hours
            two_hours_ago = ts - timedelta(hours=2)
            velocity = sum(1 for t in timestamps[:i] if t >= two_hours_ago)

            # Gap from last transaction
            gap = (ts - timestamps[i - 1]).total_seconds() / 60 if i > 0 else 999

            # Category switch count in last 1 hour
            one_hour_ago = ts - timedelta(hours=1)
            recent_cats = [
                records[j]["category"]
                for j in range(max(0, len(records) - 10), len(records))
                if records[j]["user_id"] == user_id and
                datetime.fromisoformat(records[j]["timestamp"]) >= one_hour_ago
            ]
            unique_recent = len(set(recent_cats + [category]))

            # Mood proxy: late night + weekend + impulse category = high mood score
            mood_proxy = round(
                (0.4 * int(is_late_night)) +
                (0.3 * int(is_weekend)) +
                (0.3 * int(category in IMPULSE_CATEGORIES)) +
                np.random.uniform(0, 0.2), 3
            )

            row = {
                "user_id": f"U{user_id:04d}",
                "archetype": archetype,
                "timestamp": ts.isoformat(),
                "hour": ts.hour,
                "day_of_week": ts.weekday(),
                "day_of_month": ts.day,
                "category": category,
                "amount": amount,
                "avg_user_spend": round(avg_spend, 2),
                "is_late_night": int(is_late_night),
                "is_end_of_month": int(is_end_of_month),
                "is_weekend": int(is_weekend),
                "spending_velocity": velocity,
                "transaction_gap_minutes": round(gap, 2),
                "category_switch_count": unique_recent,
                "mood_proxy_score": mood_proxy,
            }

            row["impulse_label"] = compute_impulse_label(row, archetype)
            records.append(row)

    df = pd.DataFrame(records)

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    df.to_csv(OUTPUT_PATH, index=False)

    print(f"✅ Dataset generated: {len(df)} records")
    print(f"📁 Saved to: {OUTPUT_PATH}")
    print(f"\n📊 Impulse label distribution:")
    print(df["impulse_label"].value_counts())
    print(f"\n🧠 Archetype distribution:")
    print(df["archetype"].value_counts())
    print(f"\n📋 Sample data:")
    print(df.head(3).to_string())

if __name__ == "__main__":
    generate_dataset()