-- Migración: Mejorar trigger para copiar coordenadas GPS
-- Fecha: 2026-01-11
-- Descripción: Actualizar el trigger create_shelter_on_refugio_insert para copiar lat y long

-- Reemplazar la función del trigger para que copie lat y long
CREATE OR REPLACE FUNCTION create_shelter_on_refugio_insert()
RETURNS TRIGGER AS $$
BEGIN
  -- Solo crear shelter si el rol es 'refugio'
  IF NEW.rol = 'refugio' THEN
    INSERT INTO public.shelters (
      profile_id,
      nombre,
      email,
      telefono,
      direccion,
      lat,
      long,
      created_at
    )
    VALUES (
      NEW.id,
      NEW.nombre,
      NEW.email,
      NEW.telefono,
      NEW.ubicacion,
      NEW.lat,
      NEW.long,
      NOW()
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
