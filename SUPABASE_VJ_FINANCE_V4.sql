
-- VJ CENTRAL V4 — financeiro persistente
create table if not exists public.vj_financial_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('income','expense','saving')),
  amount numeric(14,2) not null check (amount >= 0),
  category text not null default 'Outros',
  description text,
  payment_method text,
  occurred_at date not null default current_date,
  created_at timestamptz not null default now()
);

create table if not exists public.vj_financial_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  monthly_budget numeric(14,2) not null default 0,
  daily_budget numeric(14,2) not null default 0,
  savings_goal numeric(14,2) not null default 20000,
  savings_target_date date default '2027-01-01',
  updated_at timestamptz not null default now()
);

alter table public.vj_financial_entries enable row level security;
alter table public.vj_financial_settings enable row level security;

drop policy if exists "vj entries own" on public.vj_financial_entries;
create policy "vj entries own" on public.vj_financial_entries
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "vj settings own" on public.vj_financial_settings;
create policy "vj settings own" on public.vj_financial_settings
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create index if not exists vj_financial_entries_user_date_idx
on public.vj_financial_entries(user_id, occurred_at desc);
