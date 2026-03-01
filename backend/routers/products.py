import traceback
from fastapi import APIRouter, HTTPException
from supabase import create_client
from config import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
from models import CreateProductRequest, PurchaseProductRequest

router = APIRouter(prefix="/products", tags=["Products & Marketplace"])

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)


@router.post("/")
async def create_product(artist_id: str, req: CreateProductRequest):
    """Artist lists a product on the marketplace with stock quantity."""
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
            "stock_quantity": req.stock_quantity,
            "is_available": req.stock_quantity > 0,
        }

        result = supabase.table("products").insert(data).execute()
        return {"message": "Product listed", "data": result.data}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/")
async def list_products(available_only: bool = True):
    """Browse marketplace products (only in-stock ones by default)."""
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
    """Purchase a product: deduct coins from buyer, add to artist, reduce stock.
    
    Flow:
    1. Get product and validate stock
    2. Check buyer has enough coins (price × quantity)
    3. Deduct coins from buyer
    4. Add coins to artist
    5. Log transactions for both parties
    6. Reduce stock (hide product when stock reaches 0)
    """
    try:
        print(f"[PURCHASE] Starting: product={product_id}, buyer={req.buyer_id}, qty={req.quantity}")

        # 1. Get product
        product = supabase.table("products").select("*").eq(
            "id", product_id
        ).single().execute()

        if not product.data:
            raise HTTPException(status_code=404, detail="Product not found")

        stock = product.data.get("stock_quantity", 0) or 0
        if stock <= 0:
            raise HTTPException(status_code=400, detail="Product is out of stock")

        if req.quantity > stock:
            raise HTTPException(
                status_code=400,
                detail=f"Only {stock} units available. You requested {req.quantity}."
            )

        if req.quantity <= 0:
            raise HTTPException(status_code=400, detail="Quantity must be at least 1")

        unit_price = product.data.get("price_coins", 0) or 0
        total_cost = unit_price * req.quantity
        artist_id = product.data["artist_id"]

        print(f"[PURCHASE] unit_price={unit_price}, total={total_cost}, stock={stock}")

        # 2. Check buyer coins
        if req.pay_with_coins and total_cost > 0:
            buyer = supabase.table("profiles").select("scrap_coins").eq(
                "id", req.buyer_id
            ).single().execute()
            buyer_coins = buyer.data.get("scrap_coins", 0) or 0

            if buyer_coins < total_cost:
                raise HTTPException(
                    status_code=400,
                    detail=f"Insufficient coins. You have {buyer_coins} but need {total_cost} ({unit_price} × {req.quantity})."
                )

            # 3. Deduct from buyer
            supabase.table("profiles").update({
                "scrap_coins": buyer_coins - total_cost,
            }).eq("id", req.buyer_id).execute()

            # 4. Add to artist
            artist_profile = supabase.table("profiles").select("scrap_coins").eq(
                "id", artist_id
            ).single().execute()
            artist_coins = artist_profile.data.get("scrap_coins", 0) or 0
            supabase.table("profiles").update({
                "scrap_coins": artist_coins + total_cost,
            }).eq("id", artist_id).execute()

            # 5. Log transactions for both
            supabase.table("transactions").insert([
                {
                    "user_id": req.buyer_id,
                    "amount": -total_cost,
                    "type": "purchase",
                    "reference_id": product_id,
                    "description": f"Bought {req.quantity}× '{product.data['name']}' for {total_cost} coins"
                },
                {
                    "user_id": artist_id,
                    "amount": total_cost,
                    "type": "purchase",
                    "reference_id": product_id,
                    "description": f"Sold {req.quantity}× '{product.data['name']}' for {total_cost} coins"
                },
            ]).execute()
            print(f"[PURCHASE] Coins: buyer -{total_cost}, artist +{total_cost}")

        # 6. Reduce stock
        new_stock = stock - req.quantity
        supabase.table("products").update({
            "stock_quantity": new_stock,
            "is_available": new_stock > 0,
        }).eq("id", product_id).execute()
        print(f"[PURCHASE] Stock: {stock} -> {new_stock}")

        return {
            "message": f"Purchased {req.quantity}× {product.data['name']}!",
            "total_paid": total_cost,
            "remaining_stock": new_stock,
        }

    except HTTPException:
        raise
    except Exception as e:
        print(f"[PURCHASE] ERROR: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
