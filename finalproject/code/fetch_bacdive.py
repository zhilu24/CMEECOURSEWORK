
def fetch_bacdive_optimum_traits(email, password, save_path="bacdive_optimum_traits.csv", limit=1000):
    """
    Fetches BacDive strains that have both optimum growth temperature and pH,
    and returns them as a DataFrame.

    Parameters:
    - email: BacDive account email address
    - password: BacDive account password
    - limit: Number of entries to retrieve per request (default is 100)

    Returns:
    - pd.DataFrame: DataFrame with BacDive ID, optimum temperature and optimum pH
    """
    # Log in to the BacDive API
    client = BacdiveClient(user=email, password=password)


    print("Successfully logged in.")

    # Construct search query for optimum temperature and optimum pH
 
    query = {
            "AND": [
                {"culture_temp-test_type": {"value": "optimum"}},
                {"culture_pH-test_type": {"value": "optimum"}}
            ]
},
      

    strain_data = []
    offset = 0
    limit_per_call = 100

    while True:
       results = client.search(query=query, limit=limit_per_call, offset=offset)
       if not results:
            break
       

       for entry in results:
            strain_id = entry.get("id")
            opt_temp = entry.get("culture_temp", {}).get("value")
            opt_ph = entry.get("culture_pH", {}).get("value")
            strain_data.append({
                "BacDive_ID": strain_id,
                "Optimum_Temperature": opt_temp,
                "Optimum_pH": opt_ph
            })
       offset += limit_per_call
       print(f"Collected: {len(strain_data)} strains")
       time.sleep(1.2)
       
       if len(strain_data) >= limit:
           break

    df = pd.DataFrame(strain_data)
    df.to_csv(save_path, index=False)
    print(f"Data saved to {save_path}")
    return df


if __name__ == "__main__":
    email = "z1849361659@gmail.com"
    password = "666002270"

    df = fetch_bacdive_optimum_traits(email, password)
    print(df.head())