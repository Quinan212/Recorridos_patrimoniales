-- Publications & outreach section for Recorridos Patrimoniales.
-- Admin users create posts showcasing presentations, talks at foundations,
-- institutions, schools, etc. All users can read published publications.

create table if not exists public.publications (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  event_name text not null default '',
  event_date date,
  cover_image_url text,
  is_published boolean not null default true,
  created_by_device_id text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.publication_images (
  id uuid primary key default gen_random_uuid(),
  publication_id uuid not null references public.publications(id) on delete cascade,
  storage_path text,
  public_url text,
  caption text default '',
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

-- Index for fast lookups by publication
create index if not exists idx_publication_images_publication_id
  on public.publication_images(publication_id, sort_order);

alter table public.publications enable row level security;
alter table public.publication_images enable row level security;

-- Public can read published publications
create policy "Public can read published publications"
on public.publications for select
using (is_published = true);

-- Authenticated users (admins) can manage publications
create policy "Authenticated users can manage publications"
on public.publications for all
to authenticated
using (true)
with check (true);

-- Public can read images of published publications
create policy "Public can read publication images"
on public.publication_images for select
using (
  exists (
    select 1
    from public.publications
    where publications.id = publication_images.publication_id
      and publications.is_published = true
  )
);

-- Authenticated users can manage publication images
create policy "Authenticated users can manage publication images"
on public.publication_images for all
to authenticated
using (true)
with check (true);

-- Create storage bucket for publication images
insert into storage.buckets (id, name, public)
values ('publication-images', 'publication-images', true)
on conflict (id) do update set public = excluded.public;

-- Public can read publication image files
create policy "Public can read publication images storage"
on storage.objects for select
using (bucket_id = 'publication-images');

-- Authenticated users can manage publication image files
create policy "Authenticated users can manage publication images storage"
on storage.objects for all
to authenticated
using (bucket_id = 'publication-images')
with check (bucket_id = 'publication-images');
