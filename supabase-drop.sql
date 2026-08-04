-- ============================================================
-- Bale Live Sell — drop all tables created by supabase-schema.sql
-- Run in the Supabase SQL editor to reset before re-running the schema.
-- CASCADE also drops dependent policies, indexes, and FK constraints.
-- ============================================================

drop table if exists public.sales       cascade;
drop table if exists public.inventory   cascade;
drop table if exists public.purchases   cascade;
drop table if exists public.salary      cascade;
drop table if exists public.expenses    cascade;
drop table if exists public.investments cascade;
drop table if exists public.targets     cascade;
