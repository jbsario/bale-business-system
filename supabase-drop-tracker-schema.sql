-- ============================================================
-- Drop script for the "Bale-to-TikTok-Live Business Tracker" schema
-- (profiles / suppliers / sellers / purchase_lots / inventory_batches / ...)
-- Run in the Supabase SQL editor to fully remove it, including the
-- auth.users trigger, views, and standalone functions that a plain
-- `drop table cascade` on the tables alone would miss.
-- ============================================================

-- ---- trigger on auth.users (not owned by any table we're dropping) ----
drop trigger if exists on_auth_user_created on auth.users;

-- ---- reporting views (depend on the tables, drop first) ----
drop view if exists annual_summary cascade;
drop view if exists monthly_summary cascade;
drop view if exists daily_summary cascade;
drop view if exists daily_expenses cascade;
drop view if exists daily_labor cascade;
drop view if exists daily_revenue cascade;
drop view if exists inventory_batches_view cascade;

-- ---- tables (cascade drops their own triggers, policies, indexes, FKs) ----
drop table if exists sale_items cascade;
drop table if exists sales cascade;
drop table if exists seller_shifts cascade;
drop table if exists inventory_batches cascade;
drop table if exists purchase_lots cascade;
drop table if exists pricing_rules cascade;
drop table if exists profit_targets cascade;
drop table if exists investments cascade;
drop table if exists expenses cascade;
drop table if exists product_categories cascade;
drop table if exists sellers cascade;
drop table if exists suppliers cascade;
drop table if exists profiles cascade;

-- ---- standalone functions (not auto-dropped once their tables are gone) ----
drop function if exists handle_new_user() cascade;
drop function if exists auth_role() cascade;
drop function if exists apply_sale_item() cascade;
drop function if exists revert_sale_item() cascade;
drop function if exists recalc_lot_unit_costs() cascade;
drop function if exists recalc_lot_unit_costs_from_lot() cascade;
drop function if exists default_quantity_available() cascade;
