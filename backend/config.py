import os
from dotenv import load_dotenv

# Load .env from project root
load_dotenv(os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"))

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

# Scrap coin multipliers
COIN_MULTIPLIERS = {
    "iron": 30,
    "plastic": 20,
    "copper": 40,
    "glass": 20,
    "ewaste": 50,
    "other": 10,
}
