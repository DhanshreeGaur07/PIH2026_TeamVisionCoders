from pydantic import BaseModel, EmailStr
from typing import Optional
from enum import Enum


class UserRole(str, Enum):
    user = "user"
    dealer = "dealer"
    artist = "artist"
    industry = "industry"


class ScrapType(str, Enum):
    iron = "iron"
    plastic = "plastic"
    copper = "copper"
    glass = "glass"
    ewaste = "ewaste"
    other = "other"


# ---- Auth ----

class SignupRequest(BaseModel):
    email: str
    password: str
    name: str
    phone: Optional[str] = None
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    role: UserRole = UserRole.user
    organization_name: Optional[str] = None


class LoginRequest(BaseModel):
    email: str
    password: str


# ---- Scrap ----

class DonateScrapRequest(BaseModel):
    scrap_type: ScrapType
    weight_kg: float
    description: Optional[str] = None
    pickup_address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    image_url: Optional[str] = None


class AcceptScrapRequest(BaseModel):
    partner_id: str


# ---- Industry ----

class CreateRequirementRequest(BaseModel):
    scrap_type: ScrapType
    required_kg: float
    price_per_kg: Optional[float] = None
    description: Optional[str] = None


class FulfillRequirementRequest(BaseModel):
    dealer_id: str
    quantity_kg: float


# ---- Products ----

class CreateProductRequest(BaseModel):
    name: str
    description: Optional[str] = None
    price_coins: int = 0
    price_money: float = 0.0
    image_url: Optional[str] = None
    scrap_type_used: Optional[ScrapType] = None


class PurchaseProductRequest(BaseModel):
    buyer_id: str
    pay_with_coins: bool = True


# ---- Contracts ----

class CreateContractRequest(BaseModel):
    artist_id: str
    description: str
    scrap_type: Optional[ScrapType] = None
    budget_coins: int = 0
    budget_money: float = 0.0


class UpdateContractStatus(BaseModel):
    status: str  # accepted, rejected, in_progress, completed
