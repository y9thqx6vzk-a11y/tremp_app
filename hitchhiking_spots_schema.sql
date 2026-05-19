-- Enable PostGIS extension if not already enabled
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the hitchhiking_spots table
CREATE TABLE hitchhiking_spots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    location GEOMETRY(POINT, 4326) NOT NULL, -- WGS 84 coordinate system
    category TEXT NOT NULL,
    name TEXT NOT NULL,
    brooms_score INT DEFAULT 0,
    total_votes INT DEFAULT 0
);

-- Create a spatial index for efficient geographic queries
CREATE INDEX hitchhiking_spots_location_idx ON hitchhiking_spots USING GIST (location);
