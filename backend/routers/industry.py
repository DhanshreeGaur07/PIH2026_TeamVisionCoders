from fastapi import APIRouter, HTTPException
from supabase import create_client
from config import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
from models import CreateRequirementRequest, FulfillRequirementRequest

router = APIRouter(prefix="/industry", tags=["Industry"])

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


@router.post("/requirements")
async def create_requirement(industry_id: str, req: CreateRequirementRequest):
    """Industry posts a scrap requirement."""
    try:
        # Verify industry role
        profile = supabase.table("profiles").select("role").eq(
            "id", industry_id
        ).single().execute()

        if profile.data["role"] != "industry":
            raise HTTPException(status_code=403, detail="Only industries can post requirements")

        data = {
            "industry_id": industry_id,
            "scrap_type": req.scrap_type.value,
            "required_kg": req.required_kg,
            "price_per_kg": req.price_per_kg,
            "description": req.description,
            "status": "open",
            "fulfilled_kg": 0,
        }

        result = supabase.table("industry_requirements").insert(data).execute()
        return {"message": "Requirement posted", "data": result.data}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/requirements")
async def get_requirements(status: str = None, industry_id: str = None, scrap_type: str = None):
    """Get industry requirements with optional filters."""
    try:
        query = supabase.table("industry_requirements").select(
            "*, profiles!industry_requirements_industry_id_fkey(name, organization_name, location)"
        )

        if status:
            query = query.eq("status", status)
        if industry_id:
            query = query.eq("industry_id", industry_id)
        if scrap_type:
            query = query.eq("scrap_type", scrap_type)

        result = query.order("created_at", desc=True).execute()
        return result.data

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/requirements/{requirement_id}")
async def get_requirement_detail(requirement_id: str):
    """Get single requirement with fulfillment details."""
    try:
        req = supabase.table("industry_requirements").select(
            "*, profiles!industry_requirements_industry_id_fkey(name, organization_name, location)"
        ).eq("id", requirement_id).single().execute()

        # Get fulfillments
        fulfillments = supabase.table("requirement_fulfillments").select(
            "*, profiles!requirement_fulfillments_dealer_id_fkey(name, location)"
        ).eq("requirement_id", requirement_id).execute()

        return {
            "requirement": req.data,
            "fulfillments": fulfillments.data,
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/requirements/{requirement_id}/fulfill")
async def fulfill_requirement(requirement_id: str, req: FulfillRequirementRequest):
    """Dealer fulfills (partially or fully) an industry requirement."""
    try:
        # Verify dealer role
        dealer = supabase.table("profiles").select("role").eq(
            "id", req.dealer_id
        ).single().execute()

        if dealer.data["role"] != "dealer":
            raise HTTPException(status_code=403, detail="Only dealers can fulfill requirements")

        # Get current requirement
        requirement = supabase.table("industry_requirements").select("*").eq(
            "id", requirement_id
        ).single().execute()

        if not requirement.data:
            raise HTTPException(status_code=404, detail="Requirement not found")

        if requirement.data["status"] == "closed":
            raise HTTPException(status_code=400, detail="Requirement already closed")

        remaining = float(requirement.data["required_kg"]) - float(requirement.data["fulfilled_kg"])
        actual_qty = min(req.quantity_kg, remaining)

        if actual_qty <= 0:
            raise HTTPException(status_code=400, detail="Requirement already fulfilled")

        # Check dealer inventory
        inventory = supabase.table("dealer_inventory").select("*").eq(
            "dealer_id", req.dealer_id
        ).eq("scrap_type", requirement.data["scrap_type"]).execute()

        if not inventory.data or float(inventory.data[0]["quantity_kg"]) < actual_qty:
            raise HTTPException(status_code=400, detail="Insufficient inventory")

        # Create fulfillment record
        supabase.table("requirement_fulfillments").insert({
            "requirement_id": requirement_id,
            "dealer_id": req.dealer_id,
            "quantity_kg": actual_qty,
            "status": "completed",
        }).execute()

        # Update dealer inventory
        new_inventory_qty = float(inventory.data[0]["quantity_kg"]) - actual_qty
        supabase.table("dealer_inventory").update({
            "quantity_kg": new_inventory_qty,
        }).eq("id", inventory.data[0]["id"]).execute()

        # Update requirement fulfilled amount
        new_fulfilled = float(requirement.data["fulfilled_kg"]) + actual_qty
        new_status = "closed" if new_fulfilled >= float(requirement.data["required_kg"]) else "partially_fulfilled"

        supabase.table("industry_requirements").update({
            "fulfilled_kg": new_fulfilled,
            "status": new_status,
        }).eq("id", requirement_id).execute()

        return {
            "message": f"Fulfilled {actual_qty}kg",
            "fulfilled_kg": new_fulfilled,
            "required_kg": float(requirement.data["required_kg"]),
            "remaining_kg": float(requirement.data["required_kg"]) - new_fulfilled,
            "status": new_status,
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/dealers/match/{requirement_id}")
async def match_dealers(requirement_id: str):
    """Smart matching: find best dealers for a requirement based on scrap type and availability."""
    try:
        requirement = supabase.table("industry_requirements").select("*").eq(
            "id", requirement_id
        ).single().execute()

        if not requirement.data:
            raise HTTPException(status_code=404, detail="Requirement not found")

        scrap_type = requirement.data["scrap_type"]
        remaining = float(requirement.data["required_kg"]) - float(requirement.data["fulfilled_kg"])

        # Find dealers with matching inventory
        dealers_with_inventory = supabase.table("dealer_inventory").select(
            "*, profiles!dealer_inventory_dealer_id_fkey(name, location, phone)"
        ).eq("scrap_type", scrap_type).gt("quantity_kg", 0).execute()

        # Rank dealers by availability (simplified smart matching)
        ranked = []
        for d in dealers_with_inventory.data:
            qty = float(d["quantity_kg"])
            score = min(qty / remaining, 1.0) * 100  # availability score (0-100)
            ranked.append({
                "dealer_id": d["dealer_id"],
                "dealer_name": d["profiles"]["name"] if d.get("profiles") else "Unknown",
                "location": d["profiles"]["location"] if d.get("profiles") else None,
                "phone": d["profiles"]["phone"] if d.get("profiles") else None,
                "available_kg": qty,
                "match_score": round(score, 1),
            })

        ranked.sort(key=lambda x: x["match_score"], reverse=True)

        return {
            "requirement_scrap_type": scrap_type,
            "remaining_kg": remaining,
            "matched_dealers": ranked,
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
