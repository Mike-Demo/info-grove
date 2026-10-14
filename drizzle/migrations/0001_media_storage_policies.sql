-- Signed-in users can work with files in the private media bucket.
create policy "Authenticated read media files"
  on storage.objects for select to authenticated
  using (bucket_id = 'media');

create policy "Authenticated upload media files"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'media');

create policy "Authenticated replace media files"
  on storage.objects for update to authenticated
  using (bucket_id = 'media') with check (bucket_id = 'media');

create policy "Authenticated remove media files"
  on storage.objects for delete to authenticated
  using (bucket_id = 'media');
