create table if not exists public.device_registry (
  device_id text primary key,
  label text not null default '',
  notes text,
  last_active_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.admin_devices (
  device_id text primary key references public.device_registry(device_id) on delete cascade,
  label text,
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.device_registry enable row level security;
alter table public.admin_devices enable row level security;

create policy "Public can register current devices"
on public.device_registry for insert
to anon
with check (true);

create policy "Public can update seen devices"
on public.device_registry for update
to anon
using (true)
with check (true);

create policy "Public can read device registry"
on public.device_registry for select
to anon
using (true);

create policy "Public can read enabled admin devices"
on public.admin_devices for select
to anon
using (enabled = true);
