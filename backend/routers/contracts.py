from fastapi import APIRouter, HTTPException
from supabase import create_client
from config import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
from models import CreateContractRequest, UpdateContractStatus

router = APIRouter(prefix="/contracts", tags=["Artist Contracts"])

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


@router.post("/")
async def create_contract(user_id: str, req: CreateContractRequest):
    """User creates a contract for an artist."""
    try:
        # Verify artist exists
        artist = supabase.table("profiles").select("role").eq(
            "id", req.artist_id
        ).single().execute()

        if artist.data["role"] != "artist":
            raise HTTPException(status_code=400, detail="Target user is not an artist")

        data = {
            "user_id": user_id,
            "artist_id": req.artist_id,
            "description": req.description,
            "scrap_type": req.scrap_type.value if req.scrap_type else None,
            "budget_coins": req.budget_coins,
            "budget_money": req.budget_money,
            "status": "pending",
        }

        result = supabase.table("artist_contracts").insert(data).execute()
        return {"message": "Contract created", "data": result.data}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/")
async def get_contracts(user_id: str = None, artist_id: str = None):
    """Get contracts for a user or artist."""
    try:
        query = supabase.table("artist_contracts").select(
            "*, user:profiles!artist_contracts_user_id_fkey(name), artist:profiles!artist_contracts_artist_id_fkey(name)"
        )

        if user_id:
            query = query.eq("user_id", user_id)
        if artist_id:
            query = query.eq("artist_id", artist_id)

        result = query.order("created_at", desc=True).execute()
        return result.data

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{contract_id}/status")
async def update_contract_status(contract_id: str, req: UpdateContractStatus):
    """Update contract status (accept, reject, complete)."""
    try:
        valid_statuses = ["accepted", "rejected", "in_progress", "completed"]
        if req.status not in valid_statuses:
            raise HTTPException(status_code=400, detail=f"Status must be one of {valid_statuses}")

        result = supabase.table("artist_contracts").update({
            "status": req.status,
        }).eq("id", contract_id).execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Contract not found")

        # If completed and has budget_coins, transfer coins
        if req.status == "completed":
            contract = result.data[0]
            if contract.get("budget_coins", 0) > 0:
                # Deduct from user
                user = supabase.table("profiles").select("scrap_coins").eq(
                    "id", contract["user_id"]
                ).single().execute()

                if user.data["scrap_coins"] >= contract["budget_coins"]:
                    supabase.table("profiles").update({
                        "scrap_coins": user.data["scrap_coins"] - contract["budget_coins"],
                    }).eq("id", contract["user_id"]).execute()

                    # Credit to artist
                    artist = supabase.table("profiles").select("scrap_coins").eq(
                        "id", contract["artist_id"]
                    ).single().execute()

                    supabase.table("profiles").update({
                        "scrap_coins": artist.data["scrap_coins"] + contract["budget_coins"],
                    }).eq("id", contract["artist_id"]).execute()

                    # Record transactions
                    supabase.table("transactions").insert({
                        "user_id": contract["user_id"],
                        "amount": -contract["budget_coins"],
                        "type": "contract_payment",
                        "reference_id": contract_id,
                        "description": f"Paid {contract['budget_coins']} coins for contract",
                    }).execute()

                    supabase.table("transactions").insert({
                        "user_id": contract["artist_id"],
                        "amount": contract["budget_coins"],
                        "type": "contract_payment",
                        "reference_id": contract_id,
                        "description": f"Earned {contract['budget_coins']} coins from contract",
                    }).execute()

        return {"message": f"Contract status updated to {req.status}", "data": result.data}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
