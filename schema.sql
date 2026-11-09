-- Manifesto Outreach Hub: Supabase schema and user-isolation policies.
-- Run this once in Supabase Dashboard > SQL Editor as the project owner.
-- The application must use the browser-safe publishable/anon key only.
-- Do NOT expose a service_role key in config.js or GitHub Pages.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 200),
  organization text not null default '' check (char_length(organization) <= 300),
  title text not null default '' check (char_length(title) <= 200),
  audience text not null default 'Other' check (audience in (
    'Think tank', 'Politician', 'NGO / NPO', 'Company', 'VC / Angel investor',
    'Foreign foundation', 'University / Academic', 'Media / Journalist',
    'Mentor / Founder', 'Other'
  )),
  goal text not null default 'Idea discussion' check (goal in (
    'Idea discussion', 'Beta onboarding', 'Feedback', 'Partnership', 'Funding', 'Advice'
  )),
  stage text not null default 'Not contacted' check (stage in (
    'Not contacted', 'Contacted', 'Replied', 'Meeting scheduled', 'In discussion',
    'Pilot interested', 'Partnership agreed', 'Not interested'
  )),
  channel text not null default 'Email' check (channel in ('Email', 'WhatsApp', 'LinkedIn', 'Phone call')),
  email text not null default '' check (char_length(email) <= 320),
  phone text not null default '' check (char_length(phone) <= 80),
  linkedin text not null default '' check (char_length(linkedin) <= 2048),
  last_contact date,
  next_followup date,
  notes text not null default '' check (char_length(notes) <= 20000),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  contact_id uuid not null references public.contacts(id) on delete cascade,
  activity_date date not null default current_date,
  activity_type text not null check (activity_type in (
    'Email sent', 'WhatsApp sent', 'LinkedIn message', 'Phone call', 'Meeting', 'Reply received', 'Other'
  )),
  notes text not null check (char_length(trim(notes)) between 1 and 20000),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.templates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 160),
  audience text not null default 'Other',
  channel text not null default 'Email',
  aim text not null default 'Idea discussion',
  subject text not null default '' check (char_length(subject) <= 500),
  body text not null check (char_length(trim(body)) between 1 and 30000),
  is_builtin boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_settings (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  sender_name text not null default '' check (char_length(sender_name) <= 160),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists contacts_user_followup_idx on public.contacts (user_id, next_followup);
create index if not exists activities_user_contact_date_idx on public.activities (user_id, contact_id, activity_date desc);
create index if not exists templates_user_updated_idx on public.templates (user_id, updated_at desc);

drop trigger if exists contacts_set_updated_at on public.contacts;
create trigger contacts_set_updated_at before update on public.contacts
for each row execute function public.set_updated_at();
drop trigger if exists activities_set_updated_at on public.activities;
create trigger activities_set_updated_at before update on public.activities
for each row execute function public.set_updated_at();
drop trigger if exists templates_set_updated_at on public.templates;
create trigger templates_set_updated_at before update on public.templates
for each row execute function public.set_updated_at();
drop trigger if exists user_settings_set_updated_at on public.user_settings;
create trigger user_settings_set_updated_at before update on public.user_settings
for each row execute function public.set_updated_at();

alter table public.contacts enable row level security;
alter table public.activities enable row level security;
alter table public.templates enable row level security;
alter table public.user_settings enable row level security;

-- Re-running this script is safe: replace policies instead of accumulating them.
drop policy if exists "contacts: own rows" on public.contacts;
create policy "contacts: own rows" on public.contacts
for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "activities: own rows and own contacts" on public.activities;
create policy "activities: own rows and own contacts" on public.activities
for all to authenticated
using (
  user_id = auth.uid()
  and exists (select 1 from public.contacts c where c.id = contact_id and c.user_id = auth.uid())
)
with check (
  user_id = auth.uid()
  and exists (select 1 from public.contacts c where c.id = contact_id and c.user_id = auth.uid())
);

drop policy if exists "templates: own rows" on public.templates;
create policy "templates: own rows" on public.templates
for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "settings: own row" on public.user_settings;
create policy "settings: own row" on public.user_settings
for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

revoke all on public.contacts, public.activities, public.templates, public.user_settings from anon;
grant select, insert, update, delete on public.contacts, public.activities, public.templates, public.user_settings to authenticated;
