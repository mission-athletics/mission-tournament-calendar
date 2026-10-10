-- Mission Athletics Tournament Calendar: one-time Supabase setup
-- Paste this whole file into Supabase > SQL Editor > New query, then click Run.
-- It is safe to run again; it will not create duplicates.

-- 1. Tables ---------------------------------------------------------------
create table if not exists public.coaches (
  email text primary key
);

create table if not exists public.tournaments (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.wrestlers (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

-- 2. Who counts as a coach (anyone whose sign-in email is in the coaches table)
create or replace function public.is_coach()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.coaches
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
grant execute on function public.is_coach() to anon, authenticated;

-- 3. Security rules: everyone can read the schedule, only coaches can change it
alter table public.coaches     enable row level security;
alter table public.tournaments enable row level security;
alter table public.wrestlers   enable row level security;

drop policy if exists "Anyone can read tournaments" on public.tournaments;
create policy "Anyone can read tournaments" on public.tournaments
  for select using (true);
drop policy if exists "Coaches can change tournaments" on public.tournaments;
create policy "Coaches can change tournaments" on public.tournaments
  for all to authenticated using (public.is_coach()) with check (public.is_coach());

drop policy if exists "Anyone can read wrestlers" on public.wrestlers;
create policy "Anyone can read wrestlers" on public.wrestlers
  for select using (true);
drop policy if exists "Coaches can change wrestlers" on public.wrestlers;
create policy "Coaches can change wrestlers" on public.wrestlers
  for all to authenticated using (public.is_coach()) with check (public.is_coach());
-- (coaches table has no policies on purpose: it can only be edited here in Supabase.)

-- 4. Live updates, so open pages refresh when a coach saves
do $$
begin
  begin alter publication supabase_realtime add table public.tournaments; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.wrestlers;   exception when duplicate_object then null; end;
end $$;

-- 5. Approved coaches. Add one line per coach email (lowercase is fine).
insert into public.coaches (email) values
  ('george@missionathletics.com')
on conflict (email) do nothing;

-- 6. Your current calendar data, moved over from the Claude version
insert into public.wrestlers (id, data) values
  ('klqnokd6', $mtc${"id": "klqnokd6", "name": "Brooke Walrath", "weight": "100", "age": "17", "grade": "12th", "aau": true, "usa": true}$mtc$::jsonb),
  ('i2zzwteg', $mtc${"id": "i2zzwteg", "name": "Kaylin Goodwin", "weight": "105", "age": "17", "grade": "12th", "aau": false, "usa": false}$mtc$::jsonb),
  ('lmbhk2u1', $mtc${"id": "lmbhk2u1", "name": "Lucas Blackford", "weight": "", "age": "", "grade": "", "aau": false, "usa": false}$mtc$::jsonb),
  ('x0e31xzw', $mtc${"id": "x0e31xzw", "name": "Lauren Blackford", "weight": "", "age": "", "grade": "", "aau": false, "usa": false}$mtc$::jsonb),
  ('pmlzll44', $mtc${"id": "pmlzll44", "name": "Ava Johnson", "weight": "110", "age": "", "grade": "8th", "aau": false, "usa": false}$mtc$::jsonb),
  ('j9tf31z8', $mtc${"id": "j9tf31z8", "name": "Timmy Zackar", "weight": "", "age": "", "grade": "", "aau": false, "usa": false}$mtc$::jsonb),
  ('wuqhi8i5', $mtc${"id": "wuqhi8i5", "name": "Brock Wensel", "weight": "", "age": "", "grade": "", "aau": false, "usa": false}$mtc$::jsonb),
  ('u749oi9p', $mtc${"id": "u749oi9p", "name": "Avery Paustian", "weight": "", "age": "", "grade": "", "aau": false, "usa": false}$mtc$::jsonb),
  ('hbwmzpes', $mtc${"id": "hbwmzpes", "name": "Anthony Noriega", "weight": "", "age": "", "grade": "", "aau": false, "usa": false}$mtc$::jsonb)
on conflict (id) do update set data = excluded.data, updated_at = now();

insert into public.tournaments (id, data) values
  ('9pai57sr', $mtc${"id": "9pai57sr", "name": "Corncob Classic", "date": "2026-10-11", "endDate": "", "venue": "Iowa Event Center", "address": "730 3rd St", "city": "Des Moines", "state": "IA", "hotelName": "Hilton Garden Inn - Urbandale", "hotelAddress": "8600 Northpark Dr, Johnston, IA 50131", "hotelPhone": "515-270-8890", "hotelDeadline": "2026-10-05", "hotelLink": "", "hotelNotes": "", "multiDay": false, "weighins": [{"division": "Everyone", "date": "2026-10-10", "time": "18:00", "end": "19:30"}], "divisions": [], "entries": [{"wid": "klqnokd6", "weight": "100"}, {"wid": "i2zzwteg", "weight": "105"}, {"wid": "lmbhk2u1", "weight": ""}, {"wid": "x0e31xzw", "weight": ""}, {"wid": "pmlzll44", "weight": "110"}, {"wid": "j9tf31z8", "weight": ""}, {"wid": "wuqhi8i5", "weight": "HWY"}], "messages": [], "coaches": ["Max Murin", "Gracie Figueroa", "Anthony Gallagher", "Scott Scheidecker", "Ethan Diaz"], "notes": "We will have dinner at Texas Roadhouse (same parking lot as hotel) after weigh ins for anyone interested.", "styles": ["Folkstyle"]}$mtc$::jsonb),
  ('z494wraq', $mtc${"id": "z494wraq", "name": "Iowa Barn Battle", "date": "2026-10-18", "endDate": "", "venue": "Green State Family Fieldhouse", "address": "811 E 2nd Ave", "city": "Coralville", "state": "IA", "hotelName": "", "hotelAddress": "", "hotelPhone": "", "hotelDeadline": "", "hotelLink": "", "hotelNotes": "", "notes": "", "multiDay": false, "weighins": [{"division": "Everyone", "date": "2026-10-18", "time": "06:00", "end": "07:00"}], "divisions": [], "entries": [{"wid": "u749oi9p", "weight": ""}, {"wid": "hbwmzpes", "weight": ""}], "messages": [], "styles": ["Folkstyle"]}$mtc$::jsonb)
on conflict (id) do update set data = excluded.data, updated_at = now();
