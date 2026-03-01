
-- Add Haversine distance function
CREATE OR REPLACE FUNCTION calculate_distance(lat1 FLOAT, lon1 FLOAT, lat2 FLOAT, lon2 FLOAT)
RETURNS FLOAT AS $$
DECLARE
    radius FLOAT := 6371; -- Earth radius in kilometers
    dlat FLOAT;
    dlon FLOAT;
    a FLOAT;
    c FLOAT;
BEGIN
    -- Convert degrees to radians
    dlat := radians(lat2 - lat1);
    dlon := radians(lon2 - lon1);
    lat1 := radians(lat1);
    lat2 := radians(lat2);

    -- Haversine formula
    a := sin(dlat/2)^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2;
    c := 2 * asin(sqrt(a));

    RETURN radius * c;
END;
$$ LANGUAGE plpgsql;

-- Add coordinate columns if they don't exist
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS latitude FLOAT,
ADD COLUMN IF NOT EXISTS longitude FLOAT;

ALTER TABLE scrap_requests 
ADD COLUMN IF NOT EXISTS latitude FLOAT,
ADD COLUMN IF NOT EXISTS longitude FLOAT;

