-- Migración: Agregar columnas de ubicación GPS a profiles
-- Fecha: 2026-01-11
-- Descripción: Agregar lat y long para almacenar coordenadas GPS de usuarios y refugios

-- Agregar columnas a profiles si no existen
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS lat DOUBLE PRECISION DEFAULT NULL,
ADD COLUMN IF NOT EXISTS long DOUBLE PRECISION DEFAULT NULL;

-- Agregar columnas a shelters si no existen
ALTER TABLE shelters 
ADD COLUMN IF NOT EXISTS lat DOUBLE PRECISION DEFAULT NULL,
ADD COLUMN IF NOT EXISTS long DOUBLE PRECISION DEFAULT NULL;

-- Crear índices para búsquedas geográficas más eficientes
CREATE INDEX IF NOT EXISTS idx_profiles_location ON profiles(lat, long);
CREATE INDEX IF NOT EXISTS idx_shelters_location ON shelters(lat, long);
