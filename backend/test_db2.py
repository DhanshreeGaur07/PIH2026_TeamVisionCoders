import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
supabase = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_SERVICE_ROLE_KEY'))

user_id = "47df2cec-eff1-4630-aab2-e566a9c55dea"
data = supabase.table('profiles').select('scrap_coins').eq('id', user_id).execute()
print("Profiles:", data.data)

txs = supabase.table('transactions').select('*').eq('user_id', user_id).execute()
print("Transactions:", txs.data)
