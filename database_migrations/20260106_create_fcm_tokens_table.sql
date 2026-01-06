-- Tabla para almacenar tokens FCM de usuarios
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token text NOT NULL,
  device_info text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  UNIQUE(user_id, fcm_token)
);

-- Crear índice para búsquedas más rápidas
CREATE INDEX idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);
CREATE INDEX idx_user_fcm_tokens_fcm_token ON user_fcm_tokens(fcm_token);

-- Crear tabla para historial de notificaciones
CREATE TABLE IF NOT EXISTS notification_history (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notification_type varchar(50) NOT NULL,
  title text NOT NULL,
  body text,
  data jsonb,
  read_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now()
);

-- Crear índice para notificaciones
CREATE INDEX idx_notification_history_user_id ON notification_history(user_id);
CREATE INDEX idx_notification_history_created_at ON notification_history(created_at DESC);

-- Habilitar RLS (Row Level Security) en user_fcm_tokens
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios solo vean sus propios tokens
CREATE POLICY "Users can view their own FCM tokens"
  ON user_fcm_tokens
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política para que los usuarios solo inserten sus propios tokens
CREATE POLICY "Users can insert their own FCM tokens"
  ON user_fcm_tokens
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política para que los usuarios actualicen sus propios tokens
CREATE POLICY "Users can update their own FCM tokens"
  ON user_fcm_tokens
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política para que los usuarios eliminen sus propios tokens
CREATE POLICY "Users can delete their own FCM tokens"
  ON user_fcm_tokens
  FOR DELETE
  USING (auth.uid() = user_id);

-- RLS para notification_history
ALTER TABLE notification_history ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios vean sus propias notificaciones
CREATE POLICY "Users can view their own notifications"
  ON notification_history
  FOR SELECT
  USING (auth.uid() = user_id);
