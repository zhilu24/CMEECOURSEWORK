import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.metrics import mean_squared_error, r2_score
from scipy.stats import randint
import matplotlib.pyplot as plt
import joblib  


# Load data
df = pd.read_csv("binary_cleaned_matrix.csv")
y = df["temperature"]
X = df.drop(columns=["temperature"])

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Define parameter grid
param_dist = {
    "n_estimators": randint(100, 300),
    "max_depth": [10, 20, None],
    "min_samples_split": randint(2, 10),
}

# Train with RandomizedSearchCV
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

# Evaluate model
best_model = random_search.best_estimator_
print(" Best Parameters:", random_search.best_params_)

y_pred = best_model.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print(f"MSE: {mse:.2f}")
print(f"R² Score: {r2:.2f}")

# Visualize top 20 important features
importances = best_model.feature_importances_
feature_names = X.columns
sorted_idx = importances.argsort()[::-1][:20]

plt.figure(figsize=(12, 6))
plt.bar(range(20), importances[sorted_idx])
plt.xticks(range(20), feature_names[sorted_idx], rotation=90)
plt.title("Top 20 Most Important Pfam Features")
plt.tight_layout()
plt.savefig("top20_feature_importance_binary.png") 
plt.close()

# Save model
joblib.dump(best_model, "best_rf_binary_model.pkl")
print("Model saved as best_r_binary_model.pkl")