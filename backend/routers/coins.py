from fastapi import APIRouter, HTTPException
from supabase import create_client
from config import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

router = APIRouter(prefix="/coins", tags=["Scrap Coins"])

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


@router.get("/balance/{user_id}")
async def get_balance(user_id: str):
    """Get user's Scrap Coin balance."""
    try:
        profile = supabase.table("profiles").select("scrap_coins").eq(
            "id", user_id
        ).single().execute()
        return {"balance": profile.data["scrap_coins"]}
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.get("/history/{user_id}")
async def get_transaction_history(user_id: str):
    """Get user's Scrap Coin transaction history."""
    try:
        result = supabase.table("transactions").select("*").eq(
            "user_id", user_id
        ).order("created_at", desc=True).execute()
        return result.data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
