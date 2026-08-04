-- ============================================================
-- Bale Live Sell — Supabase schema (multi-user, RLS-secured)
-- Run this once in your Supabase project's SQL editor.
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- PURCHASES ----------
create table if not exists public.purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date date not null,
  supplier text not null,
  description text,
  total_cost numeric(12,2) not null default 0,
  piece_count integer not null default 1,
  created_at timestamptz not null default now()
);

-- ---------- INVENTORY ----------
-- One row per BATCH, not per physical piece — a 100-piece bale becomes
-- one inventory row with quantity_received/quantity_available=100,
-- instead of 100 individual rows to manage.
create table if not exists public.inventory (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  purchase_id uuid references public.purchases(id) on delete set null,
  name text not null,
  category text,
  cost numeric(12,2) not null default 0,
  price numeric(12,2) not null default 0,
  quantity_received integer not null default 1 check (quantity_received >= 0),
  quantity_available integer not null default 1 check (quantity_available >= 0),
  date_added date not null default current_date,
  created_at timestamptz not null default now()
);

-- ---------- SALES ----------
create table if not exists public.sales (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  item_id uuid references public.inventory(id) on delete set null,
  date date not null,
  item_name text not null,
  quantity integer not null default 1 check (quantity > 0),
  cost numeric(12,2) not null default 0,
  price numeric(12,2) not null default 0,
  live_seller text,
  platform text,
  buyer text,
  created_at timestamptz not null default now()
);

-- ---------- SALARY / PAYOUTS ----------
create table if not exists public.salary (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date date not null,
  live_seller text not null,
  type text not null default 'Fixed',
  amount numeric(12,2) not null default 0,
  notes text,
  created_at timestamptz not null default now()
);

-- ---------- EXPENSES ----------
create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date date not null,
  category text not null,
  amount numeric(12,2) not null default 0,
  notes text,
  created_at timestamptz not null default now()
);

-- ---------- INVESTMENTS / CAPITAL MOVEMENTS ----------
create table if not exists public.investments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date date not null,
  type text not null,
  amount numeric(12,2) not null default 0,
  source text,
  notes text,
  created_at timestamptz not null default now()
);

-- ---------- TARGETS (one row per user) ----------
create table if not exists public.targets (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  daily_net_profit numeric(12,2) not null default 2000,
  monthly_net_profit numeric(12,2) not null default 50000,
  annual_net_profit numeric(12,2) not null default 600000,
  target_markup_percent numeric(6,2) not null default 120,
  avg_items_per_day numeric(6,2) not null default 15,
  updated_at timestamptz not null default now()
);

-- ---------- INDEXES ----------
create index if not exists purchases_user_date_idx on public.purchases(user_id, date);
create index if not exists inventory_user_qty_idx on public.inventory(user_id, quantity_available);
create index if not exists sales_user_date_idx on public.sales(user_id, date);
create index if not exists salary_user_date_idx on public.salary(user_id, date);
create index if not exists expenses_user_date_idx on public.expenses(user_id, date);
create index if not exists investments_user_date_idx on public.investments(user_id, date);

-- ============================================================
-- ROW LEVEL SECURITY — every user can only see/change their own rows
-- ============================================================
alter table public.purchases   enable row level security;
alter table public.inventory   enable row level security;
alter table public.sales       enable row level security;
alter table public.salary      enable row level security;
alter table public.expenses    enable row level security;
alter table public.investments enable row level security;
alter table public.targets     enable row level security;

create policy "purchases_owner"   on public.purchases   for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "inventory_owner"   on public.inventory   for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "sales_owner"       on public.sales       for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "salary_owner"      on public.salary      for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "expenses_owner"    on public.expenses    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "investments_owner" on public.investments for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "targets_owner"     on public.targets     for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
