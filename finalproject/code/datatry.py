import pandas as pd
import time
from bacdive import BacdiveClient

def fetch_optimum_traits_from_ids(csv_path, email, password, save_path="bacdive_optimum_traits.csv"):
    df_ids = pd.read_csv(csv_path)
    ids = df_ids['ID'].dropna().astype(int).tolist()

    client = BacdiveClient(user=email, password=password)
    print("✅ Successfully logged in.")

    extracted_data = []

    for i, bac_id in enumerate(ids, 1):
        try:
            records = client.retrieve(bac_id)
            record = next(records)  # fix: get first item from generator

            # extract optimum temperature and pH
            culture_temp = record.get("growth_temp", [])
            culture_pH = record.get("pH", [])

            opt_temp = None
            for t in culture_temp:
                if t.get("test_type") == "optimum":
                    opt_temp = t.get("value")
                    break

            opt_ph = None
            for p in culture_pH:
                if p.get("test_type") == "optimum":
                    opt_ph = p.get("value")
                    break

            extracted_data.append({
                "BacDive_ID": bac_id,
                "Optimum_Temperature": opt_temp,
                "Optimum_pH": opt_ph
            })

            print(f"[{i}/{len(ids)}] ✅ Fetched BacDive ID {bac_id}")
            time.sleep(1.2)

        except Exception as e:
            print(f"[{i}/{len(ids)}] ❌ Failed to fetch BacDive ID {bac_id}: {e}")
            continue

    result_df = pd.DataFrame(extracted_data)
    result_df.to_csv(save_path, index=False)
    print(f"✅ Data saved to {save_path}")
    return result_df


if __name__ == "__main__":
    EMAIL = "z1849361659@gmail.com"
    PASSWORD = "666002270"

    df = fetch_optimum_traits_from_ids(
        csv_path="data/advsearch.csv",
        email=EMAIL,
        password=PASSWORD
    )

    print(df.head())

records = client.retrieve(164352)  # 用一个你知道有效的 BacDive ID
record = next(records)
print(record.keys())      # 查看有哪些字段
print(record)             # 查看内容
  
