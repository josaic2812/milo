-- Minimaler Start für die spätere Familien-Cloud.
create table if not exists families (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists family_members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references families(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  role text not null default 'member',
  created_at timestamptz not null default now()
);

create table if not exists items (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references families(id) on delete cascade,
  title text not null,
  detail text,
  type text not null default 'task',
  assignee_name text,
  due_label text,
  due_at timestamptz,
  amount numeric,
  status text not null default 'open',
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

alter table families enable row level security;
alter table family_members enable row level security;
alter table items enable row level security;

-- Before production, replace these broad policies with membership-based policies.
-- They are intentionally NOT created here to avoid accidentally granting access.
