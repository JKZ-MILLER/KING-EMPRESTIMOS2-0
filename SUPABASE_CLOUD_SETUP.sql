-- CE Controle de Empréstimos — Banco em nuvem por usuário
create table if not exists public.ce_user_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.ce_user_data enable row level security;

drop policy if exists "ce_user_data_select_own" on public.ce_user_data;
create policy "ce_user_data_select_own"
on public.ce_user_data for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "ce_user_data_insert_own" on public.ce_user_data;
create policy "ce_user_data_insert_own"
on public.ce_user_data for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "ce_user_data_update_own" on public.ce_user_data;
create policy "ce_user_data_update_own"
on public.ce_user_data for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Mantém updated_at correto
create or replace function public.ce_touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists ce_user_data_touch_updated_at on public.ce_user_data;
create trigger ce_user_data_touch_updated_at
before update on public.ce_user_data
for each row execute function public.ce_touch_updated_at();
