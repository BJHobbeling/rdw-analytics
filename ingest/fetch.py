"""
Ingestion script for RDW datasets.
Fetches raw vehicle and fuel records from Socrata Open Data API 
and saves them directly to data/raw/ as Parquet files.
"""
import os
import requests
import pandas as pd

RDW_VOERTUIGEN_ENDPOINT = "https://opendata.rdw.nl/resource/m9d7-ebf2.json"
RDW_BRANDSTOF_ENDPOINT = "https://opendata.rdw.nl/resource/8ys7-d773.json"  # Exact Socrata ID

def fetch_socrata_dataset(endpoint: str, label: str, limit: int = 50000) -> pd.DataFrame:
    print(f"Ophalen van {limit} records uit RDW {label}...")
    
    params = {
        "$limit": limit
    }
    
    # Filter personenauto's op de hoofddataset
    if label == "voertuigen":
        params["$where"] = "voertuigsoort = 'Personenauto'"
        params["$order"] = ":id"
        
    response = requests.get(endpoint, params=params)
    response.raise_for_status()
    
    df = pd.DataFrame(response.json())
    print(f"Ophaalslag {label} geslaagd: {len(df)} rijen verkregen.")
    return df

def run_ingestion(limit: int = 50000) -> None:
    os.makedirs("data/raw", exist_ok=True)
    
    # 1. Fetch Voertuigen
    df_voertuigen = fetch_socrata_dataset(RDW_VOERTUIGEN_ENDPOINT, "voertuigen", limit)
    path_voertuigen = "data/raw/rdw_voertuigen_raw.parquet"
    df_voertuigen.to_parquet(path_voertuigen, index=False)
    
    # 2. Fetch Brandstof
    df_brandstof = fetch_socrata_dataset(RDW_BRANDSTOF_ENDPOINT, "brandstof", limit)
    path_brandstof = "data/raw/rdw_brandstof_raw.parquet"
    df_brandstof.to_parquet(path_brandstof, index=False)
    
    print(f"\nIngestie voltooid! Bestanden opgeslagen in 'data/raw/'.")

if __name__ == "__main__":
    run_ingestion(limit=50000)