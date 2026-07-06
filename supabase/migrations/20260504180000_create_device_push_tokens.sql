-- Push notification tokens for Recorridos Patrimoniales.
-- Each device stores its FCM token so the server can send push
-- notifications when new publications are created.

create table if not exists public.device_push_tokens (
  id uuid primary key default gen_random_uuid(),
  device_id text not null references public.device_registry(device_id) on delete cascade,
  fcm_token text not null,
  platform text not null default 'android', -- 'android' | 'ios' | 'web'
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (device_id, fcm_token)
);

create index if not exists idx_device_push_tokens_active
  on public.device_push_tokens(device_id)
  where is_active = true;

alter table public.device_push_tokens enable row level security;

-- Devices can manage their own tokens
create policy "Devices can insert their own push tokens"
on public.device_push_tokens for insert
to anon
with check (true);

create policy "Devices can update their own push tokens"
on public.device_push_tokens for update
to anon
using (true)
with check (true);

create policy "Devices can read their own push tokens"
on public.device_push_tokens for select
to anon
using (true);
