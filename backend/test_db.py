import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
supabase = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_SERVICE_ROLE_KEY'))

user_id = "47df2cec-eff1-4630-aab2-e566a9c55dea"
data = supabase.table('scrap_requests').select('scrap_type,weight_kg,status').eq('user_id', user_id).in_("status", ["pending", "accepted"]).execute()
print("DB Data:", data.data)
