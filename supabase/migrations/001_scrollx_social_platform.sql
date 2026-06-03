create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null default 'Player',
  avatar_initials text not null default 'PL',
  avatar_url text,
  bio text not null default '',
  total_xp integer not null default 0,
  games_won integer not null default 0,
  games_played integer not null default 0,
  followers_count integer not null default 0,
  following_count integer not null default 0,
  likes_received integer not null default 0,
  streak_days integer not null default 0,
  best_scores jsonb not null default '{}'::jsonb,
  badges text[] not null default '{}'::text[],
  region text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.games (
  id text primary key,
  name text not null,
  description text not null default '',
  emoji text not null default '',
  tag text not null default 'GAME',
  rating numeric not null default 4.0,
  thumbnail_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.game_social_stats (
  game_id text primary key references public.games(id) on delete cascade,
  likes_count integer not null default 0,
  comments_count integer not null default 0,
  saves_count integer not null default 0,
  shares_count integer not null default 0,
  plays_count integer not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.game_user_states (
  game_id text not null references public.games(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  liked boolean not null default false,
  saved boolean not null default false,
  share_count integer not null default 0,
  last_shared_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (game_id, user_id)
);

create table if not exists public.game_likes (
  game_id text not null references public.games(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (game_id, user_id)
);

create table if not exists public.game_saves (
  game_id text not null references public.games(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (game_id, user_id)
);

create table if not exists public.game_shares (
  id uuid primary key default gen_random_uuid(),
  game_id text not null references public.games(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  username text not null default 'Player',
  created_at timestamptz not null default now()
);

create table if not exists public.game_plays (
  id uuid primary key default gen_random_uuid(),
  game_id text not null references public.games(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.game_comments (
  id uuid primary key default gen_random_uuid(),
  game_id text not null references public.games(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  parent_comment_id uuid references public.game_comments(id) on delete cascade,
  username text not null default 'Player',
  avatar_initials text not null default 'PL',
  text text not null check (char_length(text) between 1 and 500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.followers (
  follower_id uuid not null references auth.users(id) on delete cascade,
  following_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, following_id),
  check (follower_id <> following_id)
);

create table if not exists public.achievements (
  id text primary key,
  title text not null,
  description text not null default '',
  icon_url text,
  xp_reward integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.user_achievements (
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_id text not null references public.achievements(id) on delete cascade,
  unlocked_at timestamptz not null default now(),
  primary key (user_id, achievement_id)
);

create table if not exists public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id) on delete set null,
  target_user_id uuid references auth.users(id) on delete set null,
  type text not null,
  message text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  actor_id uuid references auth.users(id) on delete set null,
  type text not null,
  title text not null,
  body text not null default '',
  metadata jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.chats (
  id uuid primary key default gen_random_uuid(),
  created_by uuid references auth.users(id) on delete set null,
  title text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.chat_members (
  chat_id uuid not null references public.chats(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  last_read_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (chat_id, user_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid not null references public.chats(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  text text not null check (char_length(text) between 1 and 1000),
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create table if not exists public.user_presence (
  user_id uuid primary key references auth.users(id) on delete cascade,
  online boolean not null default false,
  current_game_id text references public.games(id) on delete set null,
  last_seen_at timestamptz not null default now()
);

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.bump_game_stat()
returns trigger language plpgsql security definer as $$
begin
  if tg_op = 'INSERT' then
    insert into public.game_social_stats(game_id) values (new.game_id)
    on conflict (game_id) do nothing;

    if tg_table_name = 'game_likes' then
      update public.game_social_stats set likes_count = likes_count + 1, updated_at = now() where game_id = new.game_id;
    elsif tg_table_name = 'game_saves' then
      update public.game_social_stats set saves_count = saves_count + 1, updated_at = now() where game_id = new.game_id;
    elsif tg_table_name = 'game_shares' then
      update public.game_social_stats set shares_count = shares_count + 1, updated_at = now() where game_id = new.game_id;
      update public.game_user_states set share_count = share_count + 1, last_shared_at = now(), updated_at = now()
        where game_id = new.game_id and user_id = new.user_id;
    elsif tg_table_name = 'game_plays' then
      update public.game_social_stats set plays_count = plays_count + 1, updated_at = now() where game_id = new.game_id;
    elsif tg_table_name = 'game_comments' then
      update public.game_social_stats set comments_count = comments_count + 1, updated_at = now() where game_id = new.game_id;
    end if;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if tg_table_name = 'game_likes' then
      update public.game_social_stats set likes_count = greatest(likes_count - 1, 0), updated_at = now() where game_id = old.game_id;
    elsif tg_table_name = 'game_saves' then
      update public.game_social_stats set saves_count = greatest(saves_count - 1, 0), updated_at = now() where game_id = old.game_id;
    elsif tg_table_name = 'game_comments' then
      update public.game_social_stats set comments_count = greatest(comments_count - 1, 0), updated_at = now() where game_id = old.game_id;
    end if;
    return old;
  end if;

  return null;
end;
$$;

create or replace function public.bump_follow_counts()
returns trigger language plpgsql security definer as $$
begin
  if tg_op = 'INSERT' then
    update public.profiles set following_count = following_count + 1 where id = new.follower_id;
    update public.profiles set followers_count = followers_count + 1 where id = new.following_id;
    return new;
  end if;
  update public.profiles set following_count = greatest(following_count - 1, 0) where id = old.follower_id;
  update public.profiles set followers_count = greatest(followers_count - 1, 0) where id = old.following_id;
  return old;
end;
$$;

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at before update on public.profiles
for each row execute function public.touch_updated_at();

drop trigger if exists games_touch_updated_at on public.games;
create trigger games_touch_updated_at before update on public.games
for each row execute function public.touch_updated_at();

drop trigger if exists game_likes_bump on public.game_likes;
create trigger game_likes_bump after insert or delete on public.game_likes
for each row execute function public.bump_game_stat();

drop trigger if exists game_saves_bump on public.game_saves;
create trigger game_saves_bump after insert or delete on public.game_saves
for each row execute function public.bump_game_stat();

drop trigger if exists game_shares_bump on public.game_shares;
create trigger game_shares_bump after insert on public.game_shares
for each row execute function public.bump_game_stat();

drop trigger if exists game_plays_bump on public.game_plays;
create trigger game_plays_bump after insert on public.game_plays
for each row execute function public.bump_game_stat();

drop trigger if exists game_comments_bump on public.game_comments;
create trigger game_comments_bump after insert or delete on public.game_comments
for each row execute function public.bump_game_stat();

drop trigger if exists followers_bump on public.followers;
create trigger followers_bump after insert or delete on public.followers
for each row execute function public.bump_follow_counts();

alter table public.profiles enable row level security;
alter table public.games enable row level security;
alter table public.game_social_stats enable row level security;
alter table public.game_user_states enable row level security;
alter table public.game_likes enable row level security;
alter table public.game_saves enable row level security;
alter table public.game_shares enable row level security;
alter table public.game_plays enable row level security;
alter table public.game_comments enable row level security;
alter table public.followers enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.activity_logs enable row level security;
alter table public.notifications enable row level security;
alter table public.chats enable row level security;
alter table public.chat_members enable row level security;
alter table public.messages enable row level security;
alter table public.user_presence enable row level security;

do $$
declare
  existing_policy record;
begin
  for existing_policy in
    select schemaname, tablename, policyname
    from pg_policies
    where schemaname = 'public'
      and policyname in (
        'profiles readable',
        'profiles self write',
        'profiles self update',
        'games readable',
        'authenticated game seed',
        'game stats readable',
        'authenticated stats seed',
        'state self read',
        'state self insert',
        'state self update',
        'likes readable',
        'likes self insert',
        'likes self delete',
        'saves self read',
        'saves self insert',
        'saves self delete',
        'shares readable',
        'shares self insert',
        'plays readable',
        'plays self insert',
        'comments readable',
        'comments self insert',
        'followers readable',
        'followers self insert',
        'followers self delete',
        'achievements readable',
        'user achievements readable',
        'user achievements self insert',
        'activity readable',
        'activity self insert',
        'notifications self read',
        'notifications self update',
        'notifications actor insert',
        'chat members read own',
        'chats read through membership',
        'chats self create',
        'chat members self insert',
        'messages read through membership',
        'messages self insert',
        'presence readable',
        'presence self insert',
        'presence self update'
      )
  loop
    execute format(
      'drop policy if exists %I on %I.%I',
      existing_policy.policyname,
      existing_policy.schemaname,
      existing_policy.tablename
    );
  end loop;
end $$;

create policy "profiles readable" on public.profiles for select using (true);
create policy "profiles self write" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles self update" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

create policy "games readable" on public.games for select using (true);
create policy "authenticated game seed" on public.games for insert with check (auth.role() = 'authenticated');
create policy "game stats readable" on public.game_social_stats for select using (true);
create policy "authenticated stats seed" on public.game_social_stats for insert with check (auth.role() = 'authenticated');

create policy "state self read" on public.game_user_states for select using (auth.uid() = user_id);
create policy "state self insert" on public.game_user_states for insert with check (auth.uid() = user_id);
create policy "state self update" on public.game_user_states for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "likes readable" on public.game_likes for select using (true);
create policy "likes self insert" on public.game_likes for insert with check (auth.uid() = user_id);
create policy "likes self delete" on public.game_likes for delete using (auth.uid() = user_id);

create policy "saves self read" on public.game_saves for select using (auth.uid() = user_id);
create policy "saves self insert" on public.game_saves for insert with check (auth.uid() = user_id);
create policy "saves self delete" on public.game_saves for delete using (auth.uid() = user_id);

create policy "shares readable" on public.game_shares for select using (true);
create policy "shares self insert" on public.game_shares for insert with check (auth.uid() = user_id);

create policy "plays readable" on public.game_plays for select using (true);
create policy "plays self insert" on public.game_plays for insert with check (user_id is null or auth.uid() = user_id);

create policy "comments readable" on public.game_comments for select using (true);
create policy "comments self insert" on public.game_comments for insert with check (auth.uid() = user_id);

create policy "followers readable" on public.followers for select using (true);
create policy "followers self insert" on public.followers for insert with check (auth.uid() = follower_id);
create policy "followers self delete" on public.followers for delete using (auth.uid() = follower_id);

create policy "achievements readable" on public.achievements for select using (true);
create policy "user achievements readable" on public.user_achievements for select using (true);
create policy "user achievements self insert" on public.user_achievements for insert with check (auth.uid() = user_id);

create policy "activity readable" on public.activity_logs for select using (true);
create policy "activity self insert" on public.activity_logs for insert with check (auth.uid() = actor_id);

create policy "notifications self read" on public.notifications for select using (auth.uid() = user_id);
create policy "notifications self update" on public.notifications for update using (auth.uid() = user_id);
create policy "notifications actor insert" on public.notifications for insert with check (auth.uid() = actor_id);

create policy "chat members read own" on public.chat_members for select using (auth.uid() = user_id);
create policy "chats read through membership" on public.chats for select using (
  exists (select 1 from public.chat_members cm where cm.chat_id = id and cm.user_id = auth.uid())
);
create policy "chats self create" on public.chats for insert with check (auth.uid() = created_by);
create policy "chat members self insert" on public.chat_members for insert with check (auth.uid() = user_id);
create policy "messages read through membership" on public.messages for select using (
  exists (select 1 from public.chat_members cm where cm.chat_id = messages.chat_id and cm.user_id = auth.uid())
);
create policy "messages self insert" on public.messages for insert with check (auth.uid() = sender_id);

create policy "presence readable" on public.user_presence for select using (true);
create policy "presence self insert" on public.user_presence for insert with check (auth.uid() = user_id);
create policy "presence self update" on public.user_presence for update using (auth.uid() = user_id);

do $$
declare
  realtime_table text;
begin
  foreach realtime_table in array array[
    'profiles',
    'games',
    'game_social_stats',
    'game_user_states',
    'game_likes',
    'game_saves',
    'game_shares',
    'game_comments',
    'followers',
    'activity_logs',
    'notifications',
    'messages',
    'user_presence'
  ]
  loop
    if not exists (
      select 1
      from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = realtime_table
    ) then
      execute format('alter publication supabase_realtime add table public.%I', realtime_table);
    end if;
  end loop;
end $$;
