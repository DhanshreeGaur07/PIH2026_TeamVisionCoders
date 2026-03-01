from fastapi import APIRouter, HTTPException
from supabase import create_client
from config import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
from models import CreateProductRequest, PurchaseProductRequest

router = APIRouter(prefix="/products", tags=["Products & Marketplace"])

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


@router.post("/")
async def create_product(artist_id: str, req: CreateProductRequest):
    """Artist lists a product on the marketplace."""
    try:
        # Verify artist role
        profile = supabase.table("profiles").select("role").eq(
            "id", artist_id
        ).single().execute()

        if profile.data["role"] != "artist":
            raise HTTPException(status_code=403, detail="Only artists can list products")

        data = {
            "artist_id": artist_id,
            "name": req.name,
            "description": req.description,
            "price_coins": req.price_coins,
            "price_money": req.price_money,
            "image_url": req.image_url,
            "scrap_type_used": req.scrap_type_used.value if req.scrap_type_used else None,
            "is_available": True,
        }

        result = supabase.table("products").insert(data).execute()
        return {"message": "Product listed", "data": result.data}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/")
async def list_products(available_only: bool = True):
    """Browse marketplace products."""
    try:
        query = supabase.table("products").select(
            "*, profiles!products_artist_id_fkey(name)"
        )

        if available_only:
            query = query.eq("is_available", True)

        result = query.order("created_at", desc=True).execute()
        return result.data

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{product_id}")
async def get_product(product_id: str):
    """Get product details."""
    try:
        result = supabase.table("products").select(
            "*, profiles!products_artist_id_fkey(name, location)"
        ).eq("id", product_id).single().execute()
        return result.data
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/{product_id}/purchase")
async def purchase_product(product_id: str, req: PurchaseProductRequest):
    """Purchase a product using Scrap Coins or money."""
    try:
        # Get product
        product = supabase.table("products").select("*").eq(
            "id", product_id
        ).eq("is_available", True).single().execute()

        if not product.data:
            raise HTTPException(status_code=404, detail="Product not found or unavailable")

        buyer = supabase.table("profiles").select("scrap_coins").eq(
            "id", req.buyer_id
        ).single().execute()

        if req.pay_with_coins:
            if buyer.data["scrap_coins"] < product.data["price_coins"]:
                raise HTTPException(status_code=400, detail="Insufficient Scrap Coins")

            # Deduct coins
            new_balance = buyer.data["scrap_coins"] - product.data["price_coins"]
            supabase.table("profiles").update({
                "scrap_coins": new_balance,
            }).eq("id", req.buyer_id).execute()

            # Record transaction
            supabase.table("transactions").insert({
                "user_id": req.buyer_id,
                "amount": -product.data["price_coins"],
                "type": "purchase",
                "reference_id": product_id,
                "description": f"Purchased '{product.data['name']}' for {product.data['price_coins']} Scrap Coins",
            }).execute()

        # Mark product as sold
        supabase.table("products").update({
            "is_available": False,
        }).eq("id", product_id).execute()

        return {
            "message": "Product purchased successfully",
            "product": product.data["name"],
            "paid_with": "Scrap Coins" if req.pay_with_coins else "Money",
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
