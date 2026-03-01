-- Add stock_quantity column to products table
-- Run this in Supabase SQL Editor

ALTER TABLE products ADD COLUMN IF NOT EXISTS stock_quantity INTEGER NOT NULL DEFAULT 1;

-- Update existing products to have stock = 1 if they are available, 0 if not
UPDATE products SET stock_quantity = CASE WHEN is_available THEN 1 ELSE 0 END;
