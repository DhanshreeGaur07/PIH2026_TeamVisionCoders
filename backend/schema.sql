-- ScrapCrafters Supabase Schema
-- Run this in the Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- ENUM TYPES
-- ==========================================

CREATE TYPE user_role AS ENUM ('user', 'dealer', 'artist', 'industry');
CREATE TYPE scrap_type AS ENUM ('iron', 'plastic', 'copper', 'glass', 'ewaste', 'other');
CREATE TYPE request_status AS ENUM ('pending', 'accepted', 'completed', 'cancelled');
CREATE TYPE requirement_status AS ENUM ('open', 'partially_fulfilled', 'closed');
CREATE TYPE contract_status AS ENUM ('pending', 'accepted', 'in_progress', 'completed', 'rejected');

-- ==========================================
-- PROFILES TABLE
-- ==========================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    location TEXT,
    role user_role NOT NULL DEFAULT 'user',
    scrap_coins INTEGER NOT NULL DEFAULT 0,
    organization_name TEXT, -- for industry
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- SCRAP REQUESTS (User donates scrap)
-- ==========================================

CREATE TABLE scrap_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    partner_id UUID REFERENCES profiles(id), -- dealer/artist who accepts
    scrap_type scrap_type NOT NULL,
    weight_kg DECIMAL(10, 2) NOT NULL,
    description TEXT,
    image_url TEXT,
    status request_status NOT NULL DEFAULT 'pending',
    pickup_address TEXT,
    coins_awarded INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- DEALER INVENTORY
-- ==========================================

CREATE TABLE dealer_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dealer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    scrap_type scrap_type NOT NULL,
    quantity_kg DECIMAL(10, 2) NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(dealer_id, scrap_type)
);

-- ==========================================
-- INDUSTRY REQUIREMENTS
-- ==========================================

CREATE TABLE industry_requirements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    industry_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    scrap_type scrap_type NOT NULL,
    required_kg DECIMAL(10, 2) NOT NULL,
    fulfilled_kg DECIMAL(10, 2) NOT NULL DEFAULT 0,
    price_per_kg DECIMAL(10, 2),
    status requirement_status NOT NULL DEFAULT 'open',
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- REQUIREMENT FULFILLMENTS (Dealer → Industry)
-- ==========================================

CREATE TABLE requirement_fulfillments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requirement_id UUID NOT NULL REFERENCES industry_requirements(id) ON DELETE CASCADE,
    dealer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    quantity_kg DECIMAL(10, 2) NOT NULL,
    status request_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- PRODUCTS (Artist marketplace)
-- ==========================================

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price_coins INTEGER NOT NULL DEFAULT 0,
    price_money DECIMAL(10, 2) DEFAULT 0,
    image_url TEXT,
    scrap_type_used scrap_type,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- ARTIST CONTRACTS (User → Artist)
-- ==========================================

CREATE TABLE artist_contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    artist_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    scrap_type scrap_type,
    budget_coins INTEGER DEFAULT 0,
    budget_money DECIMAL(10, 2) DEFAULT 0,
    status contract_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- TRANSACTIONS (Scrap Coin ledger)
-- ==========================================

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL, -- positive = earn, negative = spend
    type TEXT NOT NULL, -- 'donation_reward', 'purchase', 'contract_payment'
    reference_id UUID, -- links to scrap_request, product, or contract
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- ROW LEVEL SECURITY
-- ==========================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE scrap_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE dealer_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE industry_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE requirement_fulfillments ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE artist_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read all, update own
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Scrap requests: viewable by involved parties
CREATE POLICY "Users can view own scrap requests" ON scrap_requests FOR SELECT USING (true);
CREATE POLICY "Users can create scrap requests" ON scrap_requests FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Involved parties can update scrap requests" ON scrap_requests FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = partner_id);

-- Dealer inventory: dealers manage own
CREATE POLICY "Dealer inventory viewable by all" ON dealer_inventory FOR SELECT USING (true);
CREATE POLICY "Dealers can manage own inventory" ON dealer_inventory FOR INSERT WITH CHECK (auth.uid() = dealer_id);
CREATE POLICY "Dealers can update own inventory" ON dealer_inventory FOR UPDATE USING (auth.uid() = dealer_id);

-- Industry requirements: viewable by all
CREATE POLICY "Requirements viewable by all" ON industry_requirements FOR SELECT USING (true);
CREATE POLICY "Industry can create requirements" ON industry_requirements FOR INSERT WITH CHECK (auth.uid() = industry_id);
CREATE POLICY "Industry can update own requirements" ON industry_requirements FOR UPDATE USING (auth.uid() = industry_id);

-- Fulfillments
CREATE POLICY "Fulfillments viewable by involved" ON requirement_fulfillments FOR SELECT USING (true);
CREATE POLICY "Dealers can create fulfillments" ON requirement_fulfillments FOR INSERT WITH CHECK (auth.uid() = dealer_id);
CREATE POLICY "Fulfillments updatable by involved" ON requirement_fulfillments FOR UPDATE USING (auth.uid() = dealer_id);

-- Products: viewable by all, managed by artist
CREATE POLICY "Products viewable by all" ON products FOR SELECT USING (true);
CREATE POLICY "Artists can create products" ON products FOR INSERT WITH CHECK (auth.uid() = artist_id);
CREATE POLICY "Artists can update own products" ON products FOR UPDATE USING (auth.uid() = artist_id);

-- Contracts
CREATE POLICY "Contracts viewable by involved" ON artist_contracts FOR SELECT USING (auth.uid() = user_id OR auth.uid() = artist_id);
CREATE POLICY "Users can create contracts" ON artist_contracts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Contracts updatable by involved" ON artist_contracts FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = artist_id);

-- Transactions: users see own
CREATE POLICY "Users can view own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can insert transactions" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ==========================================
-- FUNCTIONS
-- ==========================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER scrap_requests_updated_at BEFORE UPDATE ON scrap_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER dealer_inventory_updated_at BEFORE UPDATE ON dealer_inventory FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER industry_requirements_updated_at BEFORE UPDATE ON industry_requirements FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER artist_contracts_updated_at BEFORE UPDATE ON artist_contracts FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Scrap Coin multiplier function
CREATE OR REPLACE FUNCTION get_coin_multiplier(s_type scrap_type)
RETURNS INTEGER AS $$
BEGIN
    RETURN CASE s_type
        WHEN 'iron' THEN 30
        WHEN 'plastic' THEN 20
        WHEN 'copper' THEN 40
        WHEN 'glass' THEN 20
        WHEN 'ewaste' THEN 50
        WHEN 'other' THEN 10
    END;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- STORAGE BUCKETS & POLICIES
-- ==========================================

-- Create a public bucket for storing images (products, profiles, etc.)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public read access to images
CREATE POLICY "Public Read Access" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'images');

-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload images" 
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'images');

-- Allow users to update their own uploaded images
CREATE POLICY "Users can update their own images" 
ON storage.objects FOR UPDATE 
TO authenticated 
USING (bucket_id = 'images' AND auth.uid() = owner);

-- Allow users to delete their own uploaded images
CREATE POLICY "Users can delete their own images" 
ON storage.objects FOR DELETE 
TO authenticated 
USING (bucket_id = 'images' AND auth.uid() = owner);
