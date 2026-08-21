create table if not exists public.profiles (id uuid primary key references auth.users(id) on delete cascade,full_name text,email text,role text not null default 'user' check(role in('admin','user')),status text not null default 'active' check(status in('active','blocked')),created_at timestamptz not null default now());
insert into public.profiles(id,full_name,email) select id,coalesce(raw_user_meta_data->>'full_name',''),email from auth.users on conflict(id) do update set email=excluded.email;
update public.profiles set role='admin' where email='juancarlosdasilva2021@gmail.com';
alter table public.profiles enable row level security;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin') $$;
drop policy if exists users_read_own_or_admin on public.profiles;
create policy users_read_own_or_admin on public.profiles for select using(id=auth.uid() or public.is_admin());
drop policy if exists admins_update_profiles on public.profiles;
create policy admins_update_profiles on public.profiles for update using(public.is_admin()) with check(public.is_admin());