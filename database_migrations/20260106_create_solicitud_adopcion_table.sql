-- Crear tabla de solicitudes de adopción
CREATE TABLE IF NOT EXISTS solicitud_adopcion (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mascota_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  estado TEXT NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aprobada', 'rechazada')),
  fecha_solicitud TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  fecha_aprobacion TIMESTAMP WITH TIME ZONE,
  notas TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_solicitud_usuario_id ON solicitud_adopcion(usuario_id);
CREATE INDEX IF NOT EXISTS idx_solicitud_mascota_id ON solicitud_adopcion(mascota_id);
CREATE INDEX IF NOT EXISTS idx_solicitud_estado ON solicitud_adopcion(estado);
CREATE INDEX IF NOT EXISTS idx_solicitud_fecha ON solicitud_adopcion(fecha_solicitud);

-- Habilitar RLS en la tabla
ALTER TABLE solicitud_adopcion ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios pueden ver sus propias solicitudes
CREATE POLICY "Users can view their own requests"
  ON solicitud_adopcion
  FOR SELECT
  USING (auth.uid() = usuario_id);

-- Política: Los refugios pueden ver las solicitudes de sus mascotas
CREATE POLICY "Shelters can view requests for their pets"
  ON solicitud_adopcion
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM pets 
      WHERE pets.id = solicitud_adopcion.mascota_id 
      AND pets.refugio_id = auth.uid()
    )
  );

-- Política: Los usuarios pueden crear solicitudes
CREATE POLICY "Users can create adoption requests"
  ON solicitud_adopcion
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

-- Política: Los refugios pueden actualizar el estado de las solicitudes
CREATE POLICY "Shelters can update request status"
  ON solicitud_adopcion
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM pets 
      WHERE pets.id = solicitud_adopcion.mascota_id 
      AND pets.refugio_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM pets 
      WHERE pets.id = solicitud_adopcion.mascota_id 
      AND pets.refugio_id = auth.uid()
    )
  );

-- Política: Los usuarios pueden eliminar sus propias solicitudes
CREATE POLICY "Users can delete their own requests"
  ON solicitud_adopcion
  FOR DELETE
  USING (auth.uid() = usuario_id);

-- Crear trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_solicitud_adopcion_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER solicitud_adopcion_updated_at_trigger
BEFORE UPDATE ON solicitud_adopcion
FOR EACH ROW
EXECUTE FUNCTION update_solicitud_adopcion_updated_at();
