with first_enabled_admin as (
  select device_id
  from public.admin_devices
  where enabled = true
  order by created_at
  limit 1
)
update public.point_images
set uploaded_by_device_id = (select device_id from first_enabled_admin)
where uploaded_by_device_id is null
  and exists (select 1 from first_enabled_admin);

drop policy if exists "Admin devices can delete point images" on public.point_images;
drop policy if exists "Admin devices can delete point image files" on storage.objects;

create policy "Admin devices can delete point images"
on public.point_images for delete
to anon
using (
  uploaded_by_device_id is not null
  and exists (
    select 1
    from public.admin_devices
    where admin_devices.device_id = point_images.uploaded_by_device_id
      and admin_devices.enabled = true
  )
);

create policy "Admin devices can delete point image files"
on storage.objects for delete
to anon
using (
  bucket_id = 'point-images'
  and (
    (
      (storage.foldername(name))[1] = 'admin_uploads'
      and exists (
        select 1
        from public.admin_devices
        where admin_devices.device_id = (storage.foldername(name))[2]
          and admin_devices.enabled = true
      )
    )
    or exists (
      select 1
      from public.point_images
      where point_images.storage_path = storage.objects.name
        and point_images.uploaded_by_device_id is not null
        and exists (
          select 1
          from public.admin_devices
          where admin_devices.device_id = point_images.uploaded_by_device_id
            and admin_devices.enabled = true
        )
    )
  )
);
