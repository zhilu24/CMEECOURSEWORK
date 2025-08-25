import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.metrics import mean_squared_error, r2_score
from scipy.stats import randint
import matplotlib.pyplot as plt
import joblib
import numpy as np

# Load data
df = pd.read_csv("normalized_count_matrix.csv")
y = df["temperature"]
X = df.drop(columns=["temperature"])

# Split only train/test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Hyperparameter grid
param_dist = {
    "n_estimators": randint(100, 300),
    "max_depth": [10, 20, None],
    "min_samples_split": randint(2, 10),
}

# Randomized Search with 5-fold CV on training set
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

# Evaluate and Plot
def evaluate_and_plot(X, y, label):
    y_pred = best_model.predict(X)
    
    # calculate RMSE and R^2
    rmse = np.sqrt(mean_squared_error(y, y_pred))
    r2 = r2_score(y, y_pred)

    print(f"{label} RMSE: {rmse:.2f}, R²: {r2:.3f}")

    plt.figure(figsize=(6, 6))
    plt.scatter(y, y_pred, alpha=0.6, edgecolors='k')
    plt.plot([y.min(), y.max()], [y.min(), y.max()], 'r--')
    plt.xlabel("Measured OGT (°C)")
    plt.ylabel("Predicted OGT (°C)")
    plt.title(f"{label} dataset")
    plt.text(0.05, 0.95, f"RMSE = {rmse:.2f}\nR² = {r2:.3f}", transform=plt.gca().transAxes,
             fontsize=12, verticalalignment='top',
             bbox=dict(boxstyle="round,pad=0.3", edgecolor="black", facecolor="white"))
    plt.tight_layout()
    plt.savefig(f"{label.lower()}_ogt_prediction.png")
    plt.close()


# Evaluate on Training and Test sets
evaluate_and_plot(X_train, y_train, "Training")
evaluate_and_plot(X_test, y_test, "Test")

# Feature Importance
importances = best_model.feature_importances_
feature_names = X.columns
sorted_idx = importances.argsort()[::-1][:20]

plt.figure(figsize=(12, 6))
plt.bar(range(20), importances[sorted_idx])
plt.xticks(range(20), feature_names[sorted_idx], rotation=90)
plt.title("Top 20 Most Important Pfam Features")
plt.tight_layout()
plt.savefig("top20_feature_importance_count.png")
plt.close()

# Save model
joblib.dump(best_model, "best_rf_count_model.pkl")
print("✅ Model saved as best_rf_count_model.pkl")