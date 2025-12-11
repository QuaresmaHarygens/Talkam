-- Talkam Liberia PostgreSQL schema
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  phone TEXT UNIQUE,
  email TEXT UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'citizen',
  verified BOOLEAN DEFAULT FALSE,
  language TEXT DEFAULT 'en-LR',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE anonymous_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_hash TEXT NOT NULL,
  token TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  county TEXT,
  capabilities JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  county TEXT,
  district TEXT,
  description TEXT
);

CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  anonymous_token_id UUID REFERENCES anonymous_tokens(id),
  location_id UUID REFERENCES locations(id),
  category TEXT NOT NULL,
  severity TEXT NOT NULL,
  summary TEXT NOT NULL,
  details TEXT,
  status TEXT NOT NULL DEFAULT 'submitted',
  anonymous BOOLEAN DEFAULT FALSE,
  witness_count INTEGER DEFAULT 0,
  ai_severity_score NUMERIC,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE report_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES reports(id) ON DELETE CASCADE,
  media_key TEXT NOT NULL,
  media_type TEXT NOT NULL,
  checksum TEXT,
  blurred BOOLEAN DEFAULT TRUE,
  voice_masked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES reports(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  action TEXT NOT NULL,
  notes TEXT,
  confidence NUMERIC,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES reports(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  visibility TEXT DEFAULT 'reporter',
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES reports(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  status TEXT DEFAULT 'open',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE ngos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contact_email TEXT,
  phone TEXT,
  focus JSONB,
  verified BOOLEAN DEFAULT FALSE,
  counties JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE agencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contact_email TEXT,
  phone TEXT,
  jurisdiction TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES reports(id) ON DELETE CASCADE,
  actor_id UUID REFERENCES users(id),
  agency_id UUID REFERENCES agencies(id),
  status TEXT,
  notes TEXT,
  attachment_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  badge_type TEXT,
  issued_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE events_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT,
  entity_id UUID,
  event_name TEXT,
  payload JSONB,
  actor_id UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE analytics_events (
  id BIGSERIAL PRIMARY KEY,
  occurred_at TIMESTAMPTZ DEFAULT now(),
  event_name TEXT,
  user_id UUID,
  report_id UUID,
  metadata JSONB
);

-- SAMPLE/SEED DATA
INSERT INTO users (id, full_name, phone, password_hash, role, verified) VALUES
  ('00000000-0000-0000-0000-000000000001','SAMPLE Mary Johnson','+231777000111','hash$mary','citizen',false),
  ('00000000-0000-0000-0000-000000000002','SAMPLE Emmanuel Doe','+231555222333','hash$emmanuel','ngo',true),
  ('00000000-0000-0000-0000-000000000003','SAMPLE Insp. Kromah','+231886444555','hash$kromah','government',true);

INSERT INTO locations (id, latitude, longitude, county, district, description) VALUES
  ('00000000-0000-0000-0000-000000000101',6.312,-10.801,'Montserrado','Paynesville','SAMPLE Red Light Junction'),
  ('00000000-0000-0000-0000-000000000102',6.438,-10.612,'Bomi','Klay','SAMPLE Clay checkpoint');

INSERT INTO reports (id, user_id, location_id, category, severity, summary, details, status, anonymous, witness_count)
VALUES
  ('10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000101','infrastructure','high','SAMPLE road blockage','Taxi drivers blocking road after rain damage','submitted',false,3);

INSERT INTO report_media (id, report_id, media_key, media_type, checksum)
VALUES
  ('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','media/sample-road.jpg','photo','chk-road');

INSERT INTO ngos (id, name, contact_email, phone, focus, verified)
VALUES
  ('30000000-0000-0000-0000-000000000001','SAMPLE Relief Liberia','contact@reliefliberia.org','+231770123456','["health","infrastructure"]',true);

INSERT INTO analytics_events (event_name, user_id, report_id, metadata) VALUES
  ('report_submitted','00000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','{"channel":"mobile"}');
