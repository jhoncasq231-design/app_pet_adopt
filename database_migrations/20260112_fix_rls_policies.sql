-- ============================================
-- FIX RLS POLICIES PARA PERMISOS DE INSERT
-- ============================================

-- Habilitar RLS si no lo está
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Crear política para INSERT: Los usuarios pueden crear su propio perfil
CREATE POLICY "Users can insert their own profile" ON public.profiles
FOR INSERT
WITH CHECK (
  auth.uid() = id
);

-- Crear política para SELECT: Los usuarios pueden ver su propio perfil
CREATE POLICY "Users can select their own profile" ON public.profiles
FOR SELECT
USING (
  auth.uid() = id OR auth.role() = 'authenticated'
);

-- Crear política para UPDATE: Los usuarios pueden actualizar su propio perfil
CREATE POLICY "Users can update their own profile" ON public.profiles
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Crear un trigger que cree automáticamente el perfil en la tabla profiles
-- cuando se registra un usuario en auth.users

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    email,
    rol,
    nombre,
    ubicacion,
    telefono,
    lat,
    long,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'rol', 'adoptante'),
    COALESCE(NEW.raw_user_meta_data->>'nombre', SPLIT_PART(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'ubicacion',
    NEW.raw_user_meta_data->>'telefono',
    CASE 
      WHEN NEW.raw_user_meta_data->>'lat' IS NOT NULL 
      THEN (NEW.raw_user_meta_data->>'lat')::double precision
      ELSE NULL
    END,
    CASE 
      WHEN NEW.raw_user_meta_data->>'long' IS NOT NULL 
      THEN (NEW.raw_user_meta_data->>'long')::double precision
      ELSE NULL
    END,
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Ejecutar el trigger cuando se cree un nuevo usuario en auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- EXPLICACIÓN:
-- ============================================
-- 1. Se habilita RLS en la tabla profiles
-- 2. Se crean políticas RLS que permiten:
--    - INSERT: Cada usuario puede crear solo SU propio registro
--    - SELECT: Cada usuario puede ver su propio perfil (y usuarios autenticados pueden ver otros)
--    - UPDATE: Cada usuario puede actualizar solo su propio registro
-- 3. Se crea un trigger que:
--    - Se ejecuta cuando se inserta un nuevo usuario en auth.users
--    - Copia los datos de raw_user_meta_data (los datos enviados en signUp)
--    - Crea automáticamente el registro en la tabla profiles
--    - Convierte los strings de lat/long a números
-- ============================================
