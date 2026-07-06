-- Supabase schema for Recorridos Patrimoniales.
-- Public users can read published content; authenticated users can manage data.

create table if not exists public.points (
  id text primary key,
  name text not null,
  address text default '',
  description text default '',
  lat double precision not null,
  lng double precision not null,
  audio_url text,
  image_urls text[] default '{}',
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.point_images (
  id uuid primary key default gen_random_uuid(),
  point_id text not null references public.points(id) on delete cascade,
  storage_path text,
  public_url text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.points enable row level security;
alter table public.point_images enable row level security;

create policy "Public can read active points"
on public.points for select
using (is_active = true);

create policy "Authenticated users can manage points"
on public.points for all
to authenticated
using (true)
with check (true);

create policy "Public can read point images"
on public.point_images for select
using (
  exists (
    select 1
    from public.points
    where points.id = point_images.point_id
      and points.is_active = true
  )
);

create policy "Authenticated users can manage point images"
on public.point_images for all
to authenticated
using (true)
with check (true);

insert into storage.buckets (id, name, public)
values ('point-images', 'point-images', true)
on conflict (id) do update set public = excluded.public;

create policy "Public can read point image files"
on storage.objects for select
using (bucket_id = 'point-images');

create policy "Authenticated users can manage point image files"
on storage.objects for all
to authenticated
using (bucket_id = 'point-images')
with check (bucket_id = 'point-images');
