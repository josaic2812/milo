create extension if not exists pgcrypto;

create table if not exists public.families (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.family_members (
  family_id uuid not null references public.families(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  role text not null default 'member',
  created_at timestamptz not null default now(),
  primary key (family_id, user_id)
);

create table if not exists public.items (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  title text not null,
  detail text not null default '',
  type text not null default 'task',
  assignee_name text not null default 'Familie',
  due_label text,
  due_at timestamptz,
  amount numeric,
  status text not null default 'open',
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.family_invites (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  code text unique not null,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

alter table public.families enable row level security;
alter table public.family_members enable row level security;
alter table public.items enable row level security;
alter table public.family_invites enable row level security;

create or replace function public.is_family_member(target_family uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.family_members fm where fm.family_id = target_family and fm.user_id = auth.uid());
$$;

create policy "members can read their families" on public.families for select using (public.is_family_member(id));
create policy "members can read family members" on public.family_members for select using (public.is_family_member(family_id));
create policy "members can manage family items" on public.items for all using (public.is_family_member(family_id)) with check (public.is_family_member(family_id));
create policy "members can read invites" on public.family_invites for select using (public.is_family_member(family_id));

alter publication supabase_realtime add table public.items;
