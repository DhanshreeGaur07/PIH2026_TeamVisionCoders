from fastapi import APIRouter, HTTPException
from supabase import create_client
from config import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, COIN_MULTIPLIERS
from models import DonateScrapRequest
import math

router = APIRouter(prefix="/scrap", tags=["Scrap Management"])

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


@router.post("/donate")
async def donate_scrap(user_id: str, req: DonateScrapRequest):
    """User donates scrap — creates request, no coins awarded until completed."""
    try:
        data = {
            "user_id": user_id,
            "scrap_type": req.scrap_type.value,
            "weight_kg": req.weight_kg,
            "description": req.description,
            "pickup_address": req.pickup_address,
            "image_url": req.image_url,
            "status": "pending",
        }

        result = supabase.table("scrap_requests").insert(data).execute()
        return {"message": "Scrap donation request created", "data": result.data}

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/requests")
async def get_scrap_requests(status: str = None, user_id: str = None):
    """Get scrap requests filtered by status and/or user."""
    try:
        query = supabase.table("scrap_requests").select("*, profiles!scrap_requests_user_id_fkey(name, location)")

        if status:
            query = query.eq("status", status)
        if user_id:
            query = query.eq("user_id", user_id)

        result = query.order("created_at", desc=True).execute()
        return result.data

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/requests/available")
async def get_available_requests():
    """Get all pending scrap requests for partners to accept."""
    try:
        result = supabase.table("scrap_requests").select(
            "*, profiles!scrap_requests_user_id_fkey(name, location, phone)"
        ).eq("status", "pending").order("created_at", desc=True).execute()
        return result.data

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/requests/{request_id}/accept")
async def accept_scrap_request(request_id: str, partner_id: str):
    """Partner accepts a scrap pickup request."""
    try:
        # Verify partner is dealer or artist
        partner = supabase.table("profiles").select("role").eq(
            "id", partner_id
        ).single().execute()

        if partner.data["role"] not in ["dealer", "artist"]:
            raise HTTPException(status_code=403, detail="Only dealers/artists can accept requests")

        result = supabase.table("scrap_requests").update({
            "partner_id": partner_id,
            "status": "accepted",
        }).eq("id", request_id).eq("status", "pending").execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Request not found or already accepted")

        return {"message": "Request accepted", "data": result.data}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/requests/{request_id}/complete")
async def complete_scrap_request(request_id: str, partner_id: str):
    """Mark a scrap request as completed. Awards Scrap Coins to the user."""
    try:
        # Get the request
        req = supabase.table("scrap_requests").select("*").eq(
            "id", request_id
        ).eq("partner_id", partner_id).eq("status", "accepted").single().execute()

        if not req.data:
            raise HTTPException(status_code=404, detail="Request not found")

        scrap_type = req.data["scrap_type"]
        weight_kg = float(req.data["weight_kg"])
        user_id = req.data["user_id"]

        # Calculate coins: weight * multiplier
        multiplier = COIN_MULTIPLIERS.get(scrap_type, 10)
        coins_earned = math.floor(weight_kg * multiplier)

        # Update request status
        supabase.table("scrap_requests").update({
            "status": "completed",
            "coins_awarded": coins_earned,
        }).eq("id", request_id).execute()

        # Award coins to user
        current_profile = supabase.table("profiles").select("scrap_coins").eq(
            "id", user_id
        ).single().execute()
        new_balance = current_profile.data["scrap_coins"] + coins_earned

        supabase.table("profiles").update({
            "scrap_coins": new_balance,
        }).eq("id", user_id).execute()

        # Record transaction
        supabase.table("transactions").insert({
            "user_id": user_id,
            "amount": coins_earned,
            "type": "donation_reward",
            "reference_id": request_id,
            "description": f"Earned {coins_earned} coins for donating {weight_kg}kg of {scrap_type}",
        }).execute()

        # If partner is dealer, add to inventory
        partner = supabase.table("profiles").select("role").eq(
            "id", partner_id
        ).single().execute()

        if partner.data["role"] == "dealer":
            # Upsert dealer inventory
            existing = supabase.table("dealer_inventory").select("*").eq(
                "dealer_id", partner_id
            ).eq("scrap_type", scrap_type).execute()

            if existing.data:
                new_qty = float(existing.data[0]["quantity_kg"]) + weight_kg
                supabase.table("dealer_inventory").update({
                    "quantity_kg": new_qty,
                }).eq("id", existing.data[0]["id"]).execute()
            else:
                supabase.table("dealer_inventory").insert({
                    "dealer_id": partner_id,
                    "scrap_type": scrap_type,
                    "quantity_kg": weight_kg,
                }).execute()

        return {
            "message": "Request completed",
            "coins_earned": coins_earned,
            "new_balance": new_balance,
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
