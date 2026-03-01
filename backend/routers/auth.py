from fastapi import APIRouter, HTTPException
from supabase import create_client
from config import SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY
from models import SignupRequest, LoginRequest

router = APIRouter(prefix="/auth", tags=["Authentication"])

# Use service role for admin operations (creating profiles)
supabase_admin = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)


@router.post("/signup")
async def signup(req: SignupRequest):
    try:
        # Create user in Supabase Auth
        auth_response = supabase.auth.sign_up({
            "email": req.email,
            "password": req.password,
        })

        if not auth_response.user:
            raise HTTPException(status_code=400, detail="Signup failed")

        user_id = auth_response.user.id

        # Create profile with service role (bypasses RLS)
        profile_data = {
            "id": user_id,
            "name": req.name,
            "email": req.email,
            "phone": req.phone,
            "location": req.location,
            "role": req.role.value,
            "scrap_coins": 0,
        }

        if req.organization_name:
            profile_data["organization_name"] = req.organization_name

        supabase_admin.table("profiles").insert(profile_data).execute()

        return {
            "message": "Signup successful",
            "user_id": user_id,
            "email": req.email,
            "role": req.role.value,
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/login")
async def login(req: LoginRequest):
    try:
        auth_response = supabase.auth.sign_in_with_password({
            "email": req.email,
            "password": req.password,
        })

        if not auth_response.user:
            raise HTTPException(status_code=401, detail="Invalid credentials")

        # Fetch profile
        profile = supabase_admin.table("profiles").select("*").eq(
            "id", auth_response.user.id
        ).single().execute()

        return {
            "message": "Login successful",
            "access_token": auth_response.session.access_token,
            "refresh_token": auth_response.session.refresh_token,
            "user": profile.data,
        }

    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))


@router.get("/profile/{user_id}")
async def get_profile(user_id: str):
    try:
        profile = supabase_admin.table("profiles").select("*").eq(
            "id", user_id
        ).single().execute()
        return profile.data
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.put("/profile/{user_id}")
async def update_profile(user_id: str, data: dict):
    try:
        allowed_fields = ["name", "phone", "location", "avatar_url", "organization_name"]
        update_data = {k: v for k, v in data.items() if k in allowed_fields}

        result = supabase_admin.table("profiles").update(update_data).eq(
            "id", user_id
        ).execute()
        return {"message": "Profile updated", "data": result.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
