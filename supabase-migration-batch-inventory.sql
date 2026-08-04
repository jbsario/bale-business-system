-- ============================================================
-- Migration: switch inventory from one-row-per-piece to
-- one-row-per-batch with a quantity counter.
-- Run this once against the schema created by supabase-schema.sql.
-- Safe to run even if `inventory`/`sales` already have rows —
-- existing per-piece rows are treated as quantity-1 batches.
-- ============================================================

alter table public.inventory
  add column if not exists quantity_received integer not null default 1,
  add column if not exists quantity_available integer not null default 1;

-- backfill from the old status column: in_stock -> qty 1 available, sold -> 0
update public.inventory
  set quantity_received = 1,
      quantity_available = case when status = 'in_stock' then 1 else 0 end;

alter table public.inventory
  drop column if exists status;

alter table public.sales
  add column if not exists quantity integer not null default 1 check (quantity > 0);
