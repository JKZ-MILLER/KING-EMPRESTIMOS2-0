-- KING CONTROL: STORAGE PARA FOTOS DE CLIENTES
-- Execute este arquivo no Supabase > SQL Editor

insert into storage.buckets (id, name, public)
values ('client-photos', 'client-photos', false)
on conflict (id) do update set public = false;

drop policy if exists "client_photos_select_own" on storage.objects;
create policy "client_photos_select_own"
on storage.objects for select to authenticated
using (bucket_id = 'client-photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "client_photos_insert_own" on storage.objects;
create policy "client_photos_insert_own"
on storage.objects for insert to authenticated
with check (bucket_id = 'client-photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "client_photos_update_own" on storage.objects;
create policy "client_photos_update_own"
on storage.objects for update to authenticated
using (bucket_id = 'client-photos' and (storage.foldername(name))[1] = auth.uid()::text)
with check (bucket_id = 'client-photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "client_photos_delete_own" on storage.objects;
create policy "client_photos_delete_own"
on storage.objects for delete to authenticated
using (bucket_id = 'client-photos' and (storage.foldername(name))[1] = auth.uid()::text);
