import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.metrics import mean_squared_error, r2_score
from scipy.stats import randint
import matplotlib.pyplot as plt
import joblib

# Load data
df = pd.read_csv("binary_cleaned_matrix.csv")

# Log-transform the temperature
df["log_temperature"] = np.log(df["temperature"])
X = df.drop(columns=["temperature", "log_temperature"])
y = df["log_temperature"]

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Define parameter grid
param_dist = {
    "n_estimators": randint(100, 300),
    "max_depth": [10, 20, 30, None],
    "min_samples_split": randint(2, 10)
}

# Randomized Search CV
rf = RandomForestRegressor(random_state=42)
random_search = RandomizedSearchCV(
    estimator=rf,
    param_distributions=param_dist,
    n_iter=20,
    scoring="r2",
    cv=5,
    random_state=42,
    n_jobs=24,
    verbose=2
)

random_search.fit(X_train, y_train)
best_model = random_search.best_estimator_
print("Best Parameters:", random_search.best_params_)

# Predict and inverse-transform
y_pred_log = best_model.predict(X_test)
y_pred = np.exp(y_pred_log)
y_true = np.exp(y_test)

rmse = np.sqrt(mean_squared_error(y_true, y_pred))
r2 = r2_score(y_true, y_pred)

print(f"RMSE (original scale): {rmse:.2f}")
print(f"R² Score (original scale): {r2:.3f}")

# Plot prediction vs. ground truth
label = "Test"
plt.figure(figsize=(6, 6))
plt.scatter(y_true, y_pred, alpha=0.6, edgecolors='k')
plt.plot([y_true.min(), y_true.max()], [y_true.min(), y_true.max()], 'r--')
plt.xlabel("Measured OGT (°C)")
plt.ylabel("Predicted OGT (°C)")
plt.title(f"{label} Dataset (binary_pfam)")
plt.text(0.05, 0.95, f"RMSE = {rmse:.2f}\nR² = {r2:.3f}", transform=plt.gca().transAxes,
         fontsize=12, verticalalignment='top',
         bbox=dict(boxstyle="round,pad=0.3", edgecolor="black", facecolor="white"))
plt.tight_layout()
plt.savefig(f"{label.lower()}_ogt_prediction_binary_log.png")
plt.close()

# Plot top 20 important features
importances = best_model.feature_importances_
feature_names = X.columns
sorted_idx = importances.argsort()[::-1][:20]

plt.figure(figsize=(12, 6))
plt.bar(range(20), importances[sorted_idx])
plt.xticks(range(20), feature_names[sorted_idx], rotation=90)
plt.title("Top 20 Most Important Pfam Features (log OGT model)")
plt.tight_layout()
plt.savefig("top20_feature_importance_binary_log_model.png")
plt.close()

# Save model
joblib.dump(best_model, "best_rf_binary_log_model.pkl")
print("Model saved as best_rf_binary_log_model.pkl")