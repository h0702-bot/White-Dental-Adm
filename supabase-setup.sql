-- White Dental Clinic: run this whole file once in Supabase -> SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  full_name text not null check (char_length(full_name) between 2 and 120),
  phone text not null check (char_length(phone) between 8 and 30),
  email text check (email is null or char_length(email) <= 160),
  preferred_date date not null,
  preferred_time time not null,
  service text not null check (char_length(service) <= 120),
  message text check (message is null or char_length(message) <= 1000),
  lang text check (lang in ('fr','ar','en')),
  status text not null default 'new' check (status in ('new','confirmed','rejected','completed')),
  status_updated_at timestamptz
);
create index if not exists appointments_status_date_idx on public.appointments (status, preferred_date);

-- Admin whitelist: being logged in is NOT enough, the user must be listed here.
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

alter table public.appointments enable row level security;
alter table public.admins enable row level security;

create or replace function public.is_admin() returns boolean
language sql security definer stable set search_path = public as
$$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;
revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

-- Visitors (anon): may ONLY insert a new request. No select/update/delete.
revoke all on public.appointments from anon;
grant insert on public.appointments to anon;
drop policy if exists "visitors can request" on public.appointments;
create policy "visitors can request" on public.appointments
  for insert to anon with check (status = 'new' and status_updated_at is null);

-- Admins: full management.
revoke all on public.appointments from authenticated;
grant select, insert, update, delete on public.appointments to authenticated;
drop policy if exists "admins read" on public.appointments;
drop policy if exists "admins update" on public.appointments;
drop policy if exists "admins delete" on public.appointments;
create policy "admins read" on public.appointments for select to authenticated using (public.is_admin());
create policy "admins update" on public.appointments for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admins delete" on public.appointments for delete to authenticated using (public.is_admin());

-- admins table: a user can only see their own row; rows are added ONLY from the SQL editor.
revoke all on public.admins from anon, authenticated;
grant select on public.admins to authenticated;
drop policy if exists "read own admin row" on public.admins;
create policy "read own admin row" on public.admins for select to authenticated using (user_id = auth.uid());

-- AFTER creating the admin user in Authentication -> Users, run (replace the email):
-- insert into public.admins (user_id) select id from auth.users where email = 'whiteclinic.dr@gmail.com';
