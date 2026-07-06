alter table public.point_images
add column if not exists uploaded_by_device_id text;

drop policy if exists "Admin devices can upload point image files" on storage.objects;
drop policy if exists "Admin devices can insert point images" on public.point_images;

create policy "Admin devices can upload point image files"
on storage.objects for insert
to anon
with check (
  bucket_id = 'point-images'
  and (storage.foldername(name))[1] = 'admin_uploads'
  and exists (
    select 1
    from public.admin_devices
    where admin_devices.device_id = (storage.foldername(name))[2]
      and admin_devices.enabled = true
  )
);

create policy "Admin devices can insert point images"
on public.point_images for insert
to anon
with check (
  uploaded_by_device_id is not null
  and storage_path like ('admin_uploads/' || uploaded_by_device_id || '/%')
  and exists (
    select 1
    from public.admin_devices
    where admin_devices.device_id = uploaded_by_device_id
      and admin_devices.enabled = true
  )
);
