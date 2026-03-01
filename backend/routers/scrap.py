from fastapi import APIRouter, HTTPException
from supabase import create_client
from config import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, COIN_MULTIPLIERS
from models import DonateScrapRequest, AcceptScrapRequest
import math
from datetime import datetime, timezone

router = APIRouter(prefix="/scrap", tags=["Scrap Management"])

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

def haversine_distance(lat1, lon1, lat2, lon2):
    if lat1 is None or lon1 is None or lat2 is None or lon2 is None:
        return float('inf')
    radius = 6371 # km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    return radius * c



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
            "latitude": req.latitude,
            "longitude": req.longitude,
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
async def get_available_requests(partner_id: str):
    """Get all pending scrap requests for partners with intelligent geographic routing."""
    try:
        # Get partner's location
        partner_res = supabase.table("profiles").select("latitude, longitude").eq("id", partner_id).single().execute()
        partner_lat = partner_res.data.get("latitude")
        partner_lon = partner_res.data.get("longitude")

        # Fetch pending requests
        result = supabase.table("scrap_requests").select(
            "*, profiles!scrap_requests_user_id_fkey(name, location, phone)"
        ).eq("status", "pending").order("created_at", desc=True).execute()
        
        pending_requests = result.data

        # If partner has no location recorded, return all pending requests as a fallback
        if not partner_lat or not partner_lon:
            return pending_requests

        filtered_requests = []
        now = datetime.now(timezone.utc)

        for req in pending_requests:
            req_lat = req.get("latitude")
            req_lon = req.get("longitude")

            # Fallback if request has no location, always show it to prevent lost requests
            if not req_lat or not req_lon:
                filtered_requests.append(req)
                continue

            dist_km = haversine_distance(partner_lat, partner_lon, req_lat, req_lon)

            # Extract created_at to determine request age
            created_at_str = req.get("created_at")
            try:
                # Handle Supabase ISO format
                created_dt = datetime.fromisoformat(created_at_str.replace("Z", "+00:00"))
                age_minutes = (now - created_dt).total_seconds() / 60.0
            except Exception:
                age_minutes = 60 # Default fallback if parsing fails

            # ---- TIME DECAY ALGORITHM ----
            # Initial radius: 5 km. Expands by 0.5 km per minute unaccepted. Max cap: 50 km.
            allowed_radius = min(50, 5 + (max(0, age_minutes) * 0.5))

            if dist_km <= allowed_radius:
                req['distance_km'] = round(dist_km, 1) # Annotate distance for frontend
                filtered_requests.append(req)

        return filtered_requests

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/requests/{request_id}/accept")
async def accept_scrap_request(request_id: str, req: AcceptScrapRequest):
    """Partner accepts a scrap pickup request."""
    try:
        # Verify partner is dealer or artist
        partner = supabase.table("profiles").select("role").eq(
            "id", req.partner_id
        ).single().execute()

        if partner.data["role"] not in ["dealer", "artist"]:
            raise HTTPException(status_code=403, detail="Only dealers/artists can accept requests")

        # Verify partner has enough coins to pay for this scrap
        request_record = supabase.table("scrap_requests").select("*").eq("id", request_id).single().execute()
        if not request_record.data:
            raise HTTPException(status_code=404, detail="Request not found")

        scrap_type = request_record.data.get("scrap_type", "other")
        weight_kg = float(request_record.data.get("weight_kg", 0))
        multiplier = COIN_MULTIPLIERS.get(scrap_type, 10)
        required_coins = math.floor(weight_kg * multiplier)

        partner_profile = supabase.table("profiles").select("scrap_coins").eq("id", req.partner_id).single().execute()
        partner_coins = partner_profile.data.get("scrap_coins", 0) or 0

        if partner_coins < required_coins:
            raise HTTPException(
                status_code=400, 
                detail=f"Insufficient coins. You need {required_coins} coins to accept this pickup, but you have {partner_coins}."
            )

        result = supabase.table("scrap_requests").update({
            "partner_id": req.partner_id,
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
async def complete_scrap_request(request_id: str, req: AcceptScrapRequest):
    """Mark a scrap request as completed. Awards Scrap Coins to the user."""
    try:
        # Get the request
        request_record = supabase.table("scrap_requests").select("*").eq(
            "id", request_id
        ).eq("partner_id", req.partner_id).eq("status", "accepted").single().execute()

        if not request_record.data:
            raise HTTPException(status_code=404, detail="Request not found")

        scrap_type = request_record.data["scrap_type"]
        weight_kg = float(request_record.data["weight_kg"])
        user_id = request_record.data["user_id"]

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

        # Record transaction for user
        supabase.table("transactions").insert({
            "user_id": user_id,
            "amount": coins_earned,
            "type": "donation_reward",
            "reference_id": request_id,
            "description": f"Earned {coins_earned} coins for donating {weight_kg}kg of {scrap_type}",
        }).execute()

        # Deduct coins from partner
        partner_profile = supabase.table("profiles").select("scrap_coins").eq(
            "id", req.partner_id
        ).single().execute()
        partner_coins = partner_profile.data.get("scrap_coins", 0) or 0
        new_partner_balance = partner_coins - coins_earned

        supabase.table("profiles").update({
            "scrap_coins": new_partner_balance,
        }).eq("id", req.partner_id).execute()

        # Record transaction for partner
        supabase.table("transactions").insert({
            "user_id": req.partner_id,
            "amount": -coins_earned,
            "type": "pickup_cost",
            "reference_id": request_id,
            "description": f"Spent {coins_earned} coins to collect {weight_kg}kg of {scrap_type}",
        }).execute()

        # If partner is dealer, add to inventory
        partner = supabase.table("profiles").select("role").eq(
            "id", req.partner_id
        ).single().execute()

        if partner.data["role"] == "dealer":
            # Upsert dealer inventory
            existing = supabase.table("dealer_inventory").select("*").eq(
                "dealer_id", req.partner_id
            ).eq("scrap_type", scrap_type).execute()

            if existing.data:
                new_qty = float(existing.data[0]["quantity_kg"]) + weight_kg
                supabase.table("dealer_inventory").update({
                    "quantity_kg": new_qty,
                }).eq("id", existing.data[0]["id"]).execute()
            else:
                supabase.table("dealer_inventory").insert({
                    "dealer_id": req.partner_id,
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
