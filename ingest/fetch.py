import io
import requests
import pandas as pd
from pathlib import Path
from tqdm import tqdm

TOTAAL = 16_980_762
LIMIT = 50_000
PAGINAGROOTTE = 1_000

stap = TOTAAL // (LIMIT // PAGINAGROOTTE)
offsets = range(0, TOTAAL, stap)

frames = []
for offset in tqdm(offsets, desc="Data ophalen bij RDW"):
    url = f"https://opendata.rdw.nl/resource/8ys7-d773.csv?$limit={PAGINAGROOTTE}&$offset={offset}&$order=:id"
    
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    
    df_chunk = pd.read_csv(io.StringIO(response.text), dtype=str)
    frames.append(df_chunk)

df_sample = pd.concat(frames, ignore_index=True)

# Path(__file__).resolve().parent is de 'ingest' map.
# .parent.parent is de projectroot -> van daaruit naar 'data/raw'
BASE_DIR = Path(__file__).resolve().parent.parent
output_path = BASE_DIR / "data" / "raw" / "rdw_brandstof_raw.parquet"

output_path.parent.mkdir(parents=True, exist_ok=True)
df_sample.to_parquet(output_path, index=False)

print(f"Klaar! {len(df_sample)} rijen opgeslagen in {output_path}")