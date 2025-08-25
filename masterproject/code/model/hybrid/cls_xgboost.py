import pandas as pd
import json
import numpy as np
from xgboost import XGBRegressor
from sklearn.model_selection import RandomizedSearchCV
from sklearn.metrics import r2_score, mean_squared_error
from scipy.stats import uniform, randint
import matplotlib.pyplot as plt
import sys

# Configuration
PFAM_CSV = "pfam_matrix_new.csv"
CLS_TRAIN_JSON = "cls_avg_by_strain_train.json"
CLS_TEST_JSON  = "cls_avg_by_strain_test.json"
PLOT_PNG = "xgboost_ogt_prediction_plot.png"

top20_pfam = [
    "PF02676", "PF01881", "PF03587", "PF01972", "PF01950",
    "PF09382", "PF00160", "PF05833", "PF00270", "PF01558",
    "PF03466", "PF01494", "PF04458", "PF00005", "PF08704",
    "PF01131", "PF00561", "PF05167", "PF01926", "PF00106"
]

# Load Pfam features
df_pfam = pd.read_csv(PFAM_CSV)
df_pfam["taxid"] = df_pfam["taxid"].astype(str)
need_cols = ["taxid", "temperature"] + top20_pfam
missing = [c for c in need_cols if c not in df_pfam.columns]
if missing:
    raise ValueError(f"Pfam file is missing required columns: {missing}")
df_top20 = df_pfam[need_cols]

# Load train/test CLS embeddings
with open(CLS_TRAIN_JSON, "r") as f:
    cls_train = json.load(f)
with open(CLS_TEST_JSON, "r") as f:
    cls_test = json.load(f)

cls_train_dict = {str(e["strain_id"]): np.array(e["cls_embedding"], dtype=float) for e in cls_train}
cls_test_dict  = {str(e["strain_id"]): np.array(e["cls_embedding"], dtype=float) for e in cls_test}

dims = set(v.shape[0] for v in list(cls_train_dict.values()) + list(cls_test_dict.values()))
if len(dims) != 1:
    raise ValueError(f"Inconsistent CLS vector dimensions: {dims}")
CLS_DIM = list(dims)[0]

# Build X/y
def build_Xy(df_top20, cls_dict, top20_pfam):
    X_list, y_list = [], []
    miss = 0
    for _, row in df_top20.iterrows():
        taxid = str(row["taxid"])
        if taxid not in cls_dict:
            miss += 1
            continue
        pfam_vec = row[top20_pfam].values.astype(float)
        cls_vec = cls_dict[taxid]
        combined_vec = np.concatenate([pfam_vec, cls_vec])
        X_list.append(combined_vec)

        # log-transform target
        temp = float(row["temperature"])
        y_list.append(np.log(temp))

    X = np.array(X_list, dtype=float)
    y = np.array(y_list, dtype=float)
    return X, y, miss

X_train, y_train, miss_train = build_Xy(df_top20, cls_train_dict, top20_pfam)
X_test,  y_test,  miss_test  = build_Xy(df_top20, cls_test_dict,  top20_pfam)

print(f"Train set: {X_train.shape[0]} samples (skipped {miss_train} rows missing CLS), feature dim {X_train.shape[1]}")
print(f"Test set:  {X_test.shape[0]} samples (skipped {miss_test} rows missing CLS), feature dim {X_test.shape[1]}")

if X_train.shape[0] == 0 or X_test.shape[0] == 0:
    sys.exit("Train or test set is empty. Please check inputs.")

# Define model
xgb = XGBRegressor(objective="reg:squarederror", random_state=42)

param_dist = {
    "n_estimators": randint(200, 600),
    "max_depth": randint(3, 12),
    "learning_rate": uniform(0.01, 0.3),
    "subsample": uniform(0.7, 0.3),
    "colsample_bytree": uniform(0.7, 0.3),
    "reg_alpha": uniform(0, 1.0),
    "reg_lambda": uniform(0, 1.0),
}

random_search = RandomizedSearchCV(
    estimator=xgb,
    param_distributions=param_dist,
    n_iter=30,
    scoring="r2",
    cv=5,
    verbose=1,
    n_jobs=-1,
    random_state=42
)

# Train
random_search.fit(X_train, y_train)
print("Best CV R²:", random_search.best_score_)
print("Best Parameters:", random_search.best_params_)

best_model = random_search.best_estimator_

# Predict and inverse-transform
y_pred = best_model.predict(X_test)

# inverse log transform
y_pred = np.exp(y_pred)
y_test = np.exp(y_test)

r2 = r2_score(y_test, y_pred)
mse = mean_squared_error(y_test, y_pred)
rmse = np.sqrt(mse)

print(f"Test R²:  {r2:.4f}")
print(f"Test MSE: {mse:.4f}")
print(f"Test RMSE:{rmse:.4f}")

# Plot
plt.figure(figsize=(7, 6))
plt.scatter(y_test, y_pred, alpha=0.6, edgecolors="k", label="XGBoost: Predicted vs Actual")

min_val = float(min(np.min(y_test), np.min(y_pred)))
max_val = float(max(np.max(y_test), np.max(y_pred)))
plt.plot([min_val, max_val], [min_val, max_val], 'r--', label="Perfect Prediction")

textstr = f"$R^2 = {r2:.2f}$\n$RMSE = {rmse:.2f}$"
plt.text(0.05, 0.95, textstr, transform=plt.gca().transAxes,
         fontsize=12, verticalalignment='top',
         bbox=dict(boxstyle="round", facecolor="white", edgecolor="gray"))

plt.xlabel("Experimental growth temperature (°C)", fontsize=12)
plt.ylabel("Predicted growth temperature (°C)", fontsize=12)
plt.title("XGBoost model: Predicted vs Actual OGT", fontsize=14)
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig(PLOT_PNG, dpi=300)
plt.show()
print(f"Figure saved to: {PLOT_PNG}")
