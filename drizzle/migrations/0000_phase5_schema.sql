-- App roles kept in a dedicated table, never on profile rows.
create type public.app_role as enum ('admin', 'moderator', 'user');

create table public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  role public.app_role not null,
  unique (user_id, role)
);
grant select on public.user_roles to authenticated;
grant all on public.user_roles to service_role;
alter table public.user_roles enable row level security;
create policy "Users read own roles"
  on public.user_roles for select to authenticated
  using (user_id = auth.uid());

create or replace function public.has_role(_user_id uuid, _role public.app_role)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.user_roles where user_id = _user_id and role = _role
  )
$$;

create policy "Admins read all roles"
  on public.user_roles for select to authenticated
  using (public.has_role(auth.uid(), 'admin'));

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text not null,
  bio text,
  website text,
  avatar_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select, update on public.profiles to authenticated;
grant all on public.profiles to service_role;
alter table public.profiles enable row level security;
create policy "Users read own profile"
  on public.profiles for select to authenticated
  using (id = auth.uid() or public.has_role(auth.uid(), 'admin'));
create policy "Users update own profile"
  on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

create table public.settings (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  theme text not null default 'system',
  locale text not null default 'en',
  email_notifications boolean not null default true,
  product_updates boolean not null default false,
  digest_frequency text not null default 'weekly',
  updated_at timestamptz not null default now()
);
grant select, update on public.settings to authenticated;
grant all on public.settings to service_role;
alter table public.settings enable row level security;
create policy "Users read own settings"
  on public.settings for select to authenticated
  using (user_id = auth.uid());
create policy "Users update own settings"
  on public.settings for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)), new.email)
  on conflict (id) do nothing;
  insert into public.settings (user_id) values (new.id) on conflict (user_id) do nothing;
  insert into public.user_roles (user_id, role) values (new.id, 'user') on conflict (user_id, role) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();


create table public.media_assets (
  id text primary key,
  path text not null,
  mime_type text not null,
  alt text not null,
  caption text,
  size_bytes bigint not null default 0,
  width integer not null default 0,
  height integer not null default 0,
  focal_point jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.media_assets to anon, authenticated;
grant insert, update, delete on public.media_assets to authenticated;
grant all on public.media_assets to service_role;
alter table public.media_assets enable row level security;
create policy "Public read media_assets"
  on public.media_assets for select to anon, authenticated
  using (true);
create policy "Admins insert media_assets"
  on public.media_assets for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update media_assets"
  on public.media_assets for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete media_assets"
  on public.media_assets for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.authors (
  id text primary key,
  slug text not null unique,
  name text not null,
  bio text,
  avatar_id text,
  social jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.authors to anon, authenticated;
grant insert, update, delete on public.authors to authenticated;
grant all on public.authors to service_role;
alter table public.authors enable row level security;
create policy "Public read authors"
  on public.authors for select to anon, authenticated
  using (true);
create policy "Admins insert authors"
  on public.authors for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update authors"
  on public.authors for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete authors"
  on public.authors for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.categories (
  id text primary key,
  slug text not null unique,
  name text not null,
  description text,
  parent_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.categories to anon, authenticated;
grant insert, update, delete on public.categories to authenticated;
grant all on public.categories to service_role;
alter table public.categories enable row level security;
create policy "Public read categories"
  on public.categories for select to anon, authenticated
  using (true);
create policy "Admins insert categories"
  on public.categories for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update categories"
  on public.categories for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete categories"
  on public.categories for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.tags (
  id text primary key,
  slug text not null unique,
  name text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.tags to anon, authenticated;
grant insert, update, delete on public.tags to authenticated;
grant all on public.tags to service_role;
alter table public.tags enable row level security;
create policy "Public read tags"
  on public.tags for select to anon, authenticated
  using (true);
create policy "Admins insert tags"
  on public.tags for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update tags"
  on public.tags for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete tags"
  on public.tags for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.posts (
  id text primary key,
  slug text not null unique,
  status text not null default 'draft',
  published_at timestamptz,
  scheduled_at timestamptz,
  seo_title text,
  seo_description text,
  seo_image text,
  title text not null,
  excerpt text,
  body jsonb not null default '[]'::jsonb,
  author_id text,
  category_ids text[] not null default '{}',
  tag_ids text[] not null default '{}',
  hero_id text,
  related_post_ids text[] not null default '{}',
  locale text not null default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.posts to anon, authenticated;
grant insert, update, delete on public.posts to authenticated;
grant all on public.posts to service_role;
alter table public.posts enable row level security;
create policy "Public read posts"
  on public.posts for select to anon, authenticated
  using (true);
create policy "Admins insert posts"
  on public.posts for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update posts"
  on public.posts for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete posts"
  on public.posts for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.products (
  id text primary key,
  slug text not null unique,
  status text not null default 'draft',
  published_at timestamptz,
  scheduled_at timestamptz,
  seo_title text,
  seo_description text,
  seo_image text,
  name text not null,
  description jsonb not null default '[]'::jsonb,
  gallery_ids text[] not null default '{}',
  category_ids text[] not null default '{}',
  tag_ids text[] not null default '{}',
  related_product_ids text[] not null default '{}',
  availability text not null default 'in-stock',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.products to anon, authenticated;
grant insert, update, delete on public.products to authenticated;
grant all on public.products to service_role;
alter table public.products enable row level security;
create policy "Public read products"
  on public.products for select to anon, authenticated
  using (true);
create policy "Admins insert products"
  on public.products for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update products"
  on public.products for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete products"
  on public.products for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.product_variants (
  id text primary key,
  product_id text not null references public.products(id) on delete cascade,
  sku text not null unique,
  options jsonb not null default '{}'::jsonb,
  price_minor bigint not null,
  currency text not null default 'USD',
  stock integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.product_variants to anon, authenticated;
grant insert, update, delete on public.product_variants to authenticated;
grant all on public.product_variants to service_role;
alter table public.product_variants enable row level security;
create policy "Public read product_variants"
  on public.product_variants for select to anon, authenticated
  using (true);
create policy "Admins insert product_variants"
  on public.product_variants for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update product_variants"
  on public.product_variants for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete product_variants"
  on public.product_variants for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.product_reviews (
  id text primary key,
  product_id text not null references public.products(id) on delete cascade,
  reviewer_name text not null,
  rating integer not null,
  title text,
  body text,
  moderation text not null default 'pending',
  user_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.product_reviews to anon, authenticated;
grant insert, update, delete on public.product_reviews to authenticated;
grant all on public.product_reviews to service_role;
alter table public.product_reviews enable row level security;
create policy "Public read product_reviews"
  on public.product_reviews for select to anon, authenticated
  using (true);
create policy "Admins insert product_reviews"
  on public.product_reviews for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update product_reviews"
  on public.product_reviews for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete product_reviews"
  on public.product_reviews for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));
create policy "Users submit reviews"
  on public.product_reviews for insert to authenticated
  with check (user_id = auth.uid() and moderation = 'pending');


create table public.events (
  id text primary key,
  slug text not null unique,
  status text not null default 'draft',
  published_at timestamptz,
  scheduled_at timestamptz,
  seo_title text,
  seo_description text,
  seo_image text,
  title text not null,
  description jsonb not null default '[]'::jsonb,
  start_at timestamptz not null,
  end_at timestamptz not null,
  timezone text not null default 'UTC',
  venue text,
  online_url text,
  speaker_ids text[] not null default '{}',
  capacity integer not null default 0,
  registration_open boolean not null default true,
  hero_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.events to anon, authenticated;
grant insert, update, delete on public.events to authenticated;
grant all on public.events to service_role;
alter table public.events enable row level security;
create policy "Public read events"
  on public.events for select to anon, authenticated
  using (true);
create policy "Admins insert events"
  on public.events for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update events"
  on public.events for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete events"
  on public.events for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.resources (
  id text primary key,
  slug text not null unique,
  status text not null default 'draft',
  published_at timestamptz,
  scheduled_at timestamptz,
  seo_title text,
  seo_description text,
  seo_image text,
  title text not null,
  type text not null default 'article',
  summary text,
  body jsonb not null default '[]'::jsonb,
  media_id text,
  file_path text,
  category_ids text[] not null default '{}',
  tag_ids text[] not null default '{}',
  access text not null default 'public',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.resources to anon, authenticated;
grant insert, update, delete on public.resources to authenticated;
grant all on public.resources to service_role;
alter table public.resources enable row level security;
create policy "Public read resources"
  on public.resources for select to anon, authenticated
  using (true);
create policy "Admins insert resources"
  on public.resources for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update resources"
  on public.resources for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete resources"
  on public.resources for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.team_members (
  id text primary key,
  name text not null,
  role text not null,
  bio text,
  portrait_id text,
  social jsonb,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.team_members to anon, authenticated;
grant insert, update, delete on public.team_members to authenticated;
grant all on public.team_members to service_role;
alter table public.team_members enable row level security;
create policy "Public read team_members"
  on public.team_members for select to anon, authenticated
  using (true);
create policy "Admins insert team_members"
  on public.team_members for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update team_members"
  on public.team_members for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete team_members"
  on public.team_members for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.testimonials (
  id text primary key,
  quote text not null,
  attribution text not null,
  company text,
  featured boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.testimonials to anon, authenticated;
grant insert, update, delete on public.testimonials to authenticated;
grant all on public.testimonials to service_role;
alter table public.testimonials enable row level security;
create policy "Public read testimonials"
  on public.testimonials for select to anon, authenticated
  using (true);
create policy "Admins insert testimonials"
  on public.testimonials for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update testimonials"
  on public.testimonials for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete testimonials"
  on public.testimonials for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.customer_stories (
  id text primary key,
  slug text not null unique,
  status text not null default 'draft',
  published_at timestamptz,
  scheduled_at timestamptz,
  seo_title text,
  seo_description text,
  seo_image text,
  title text not null,
  company text,
  body jsonb not null default '[]'::jsonb,
  related_product_ids text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.customer_stories to anon, authenticated;
grant insert, update, delete on public.customer_stories to authenticated;
grant all on public.customer_stories to service_role;
alter table public.customer_stories enable row level security;
create policy "Public read customer_stories"
  on public.customer_stories for select to anon, authenticated
  using (true);
create policy "Admins insert customer_stories"
  on public.customer_stories for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update customer_stories"
  on public.customer_stories for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete customer_stories"
  on public.customer_stories for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.faqs (
  id text primary key,
  question text not null,
  answer jsonb not null default '[]'::jsonb,
  category_id text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.faqs to anon, authenticated;
grant insert, update, delete on public.faqs to authenticated;
grant all on public.faqs to service_role;
alter table public.faqs enable row level security;
create policy "Public read faqs"
  on public.faqs for select to anon, authenticated
  using (true);
create policy "Admins insert faqs"
  on public.faqs for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update faqs"
  on public.faqs for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete faqs"
  on public.faqs for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.jobs (
  id text primary key,
  slug text not null unique,
  title text not null,
  department text,
  location text,
  description text,
  open boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.jobs to anon, authenticated;
grant insert, update, delete on public.jobs to authenticated;
grant all on public.jobs to service_role;
alter table public.jobs enable row level security;
create policy "Public read jobs"
  on public.jobs for select to anon, authenticated
  using (true);
create policy "Admins insert jobs"
  on public.jobs for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update jobs"
  on public.jobs for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete jobs"
  on public.jobs for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.pages (
  id text primary key,
  slug text not null unique,
  status text not null default 'draft',
  published_at timestamptz,
  scheduled_at timestamptz,
  seo_title text,
  seo_description text,
  seo_image text,
  title text not null,
  summary text,
  template text not null default 'basic',
  locale text not null default 'en',
  blocks jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select on public.pages to anon, authenticated;
grant insert, update, delete on public.pages to authenticated;
grant all on public.pages to service_role;
alter table public.pages enable row level security;
create policy "Public read pages"
  on public.pages for select to anon, authenticated
  using (true);
create policy "Admins insert pages"
  on public.pages for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins update pages"
  on public.pages for update to authenticated
  using (public.has_role(auth.uid(), 'admin')) with check (public.has_role(auth.uid(), 'admin'));
create policy "Admins delete pages"
  on public.pages for delete to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.orders (
  id text primary key,
  owner_email text not null,
  name text not null,
  items jsonb not null default '[]'::jsonb,
  currency text not null default 'USD',
  subtotal_minor bigint not null default 0,
  tax_minor bigint not null default 0,
  shipping_minor bigint not null default 0,
  total_minor bigint not null default 0,
  shipping_address jsonb not null default '{}'::jsonb,
  order_state text not null default 'pending',
  payment_state text not null default 'unpaid',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant insert on public.orders to anon, authenticated;
grant all on public.orders to service_role;
alter table public.orders enable row level security;
create policy "Anyone can place an order"
  on public.orders for insert to anon, authenticated
  with check (true);
create policy "Admins read all orders"
  on public.orders for select to authenticated
  using (public.has_role(auth.uid(), 'admin'));
create policy "Order owners read their orders"
  on public.orders for select to authenticated
  using (lower(owner_email) = lower(auth.jwt() ->> 'email'));


create table public.contact_submissions (
  id text primary key,
  name text not null,
  email text not null,
  topic text,
  message text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant insert on public.contact_submissions to anon, authenticated;
grant all on public.contact_submissions to service_role;
alter table public.contact_submissions enable row level security;
create policy "Anyone can submit contact_submissions"
  on public.contact_submissions for insert to anon, authenticated
  with check (true);
create policy "Admins read contact_submissions"
  on public.contact_submissions for select to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.newsletter_subscriptions (
  id text primary key,
  email text not null unique,
  consent boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant insert on public.newsletter_subscriptions to anon, authenticated;
grant all on public.newsletter_subscriptions to service_role;
alter table public.newsletter_subscriptions enable row level security;
create policy "Anyone can submit newsletter_subscriptions"
  on public.newsletter_subscriptions for insert to anon, authenticated
  with check (true);
create policy "Admins read newsletter_subscriptions"
  on public.newsletter_subscriptions for select to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create table public.event_registrations (
  id text primary key,
  event_id text not null references public.events(id) on delete cascade,
  user_id uuid,
  name text not null,
  email text not null,
  attendance text not null default 'in-person',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant insert on public.event_registrations to anon, authenticated;
grant all on public.event_registrations to service_role;
alter table public.event_registrations enable row level security;
create policy "Anyone can register event_registrations"
  on public.event_registrations for insert to anon, authenticated
  with check (true);
create policy "Admins read event_registrations"
  on public.event_registrations for select to authenticated
  using (public.has_role(auth.uid(), 'admin'));
create policy "Owners read event_registrations"
  on public.event_registrations for select to authenticated
  using (user_id = auth.uid());


create table public.job_applications (
  id text primary key,
  job_id text not null references public.jobs(id) on delete cascade,
  user_id uuid,
  name text not null,
  email text not null,
  portfolio_url text,
  cover_letter text,
  resume_file_name text,
  consent boolean not null default true,
  state text not null default 'received',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant insert on public.job_applications to anon, authenticated;
grant all on public.job_applications to service_role;
alter table public.job_applications enable row level security;
create policy "Anyone can register job_applications"
  on public.job_applications for insert to anon, authenticated
  with check (true);
create policy "Admins read job_applications"
  on public.job_applications for select to authenticated
  using (public.has_role(auth.uid(), 'admin'));
create policy "Owners read job_applications"
  on public.job_applications for select to authenticated
  using (user_id = auth.uid());


create table public.notifications (
  id text primary key,
  user_id uuid not null,
  title text not null,
  body text,
  type text not null default 'system',
  href text,
  read_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant insert, update on public.notifications to authenticated;
grant all on public.notifications to service_role;
alter table public.notifications enable row level security;
create policy "Users read own notifications"
  on public.notifications for select to authenticated
  using (user_id = auth.uid() or public.has_role(auth.uid(), 'admin'));
create policy "Users update own notifications"
  on public.notifications for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Admins manage notifications"
  on public.notifications for insert to authenticated
  with check (public.has_role(auth.uid(), 'admin'));


create table public.support_tickets (
  id text primary key,
  user_id uuid not null,
  subject text not null,
  category text,
  priority text not null default 'normal',
  messages jsonb not null default '[]'::jsonb,
  state text not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant insert, update on public.support_tickets to authenticated;
grant all on public.support_tickets to service_role;
alter table public.support_tickets enable row level security;
create policy "Users read own tickets"
  on public.support_tickets for select to authenticated
  using (user_id = auth.uid() or public.has_role(auth.uid(), 'admin'));
create policy "Users create own tickets"
  on public.support_tickets for insert to authenticated
  with check (user_id = auth.uid());
create policy "Users update own tickets"
  on public.support_tickets for update to authenticated
  using (user_id = auth.uid() or public.has_role(auth.uid(), 'admin')) with check (user_id = auth.uid() or public.has_role(auth.uid(), 'admin'));


create table public.surveys (
  id text primary key,
  user_id uuid not null,
  satisfaction integer not null,
  most_used text,
  comments text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant insert on public.surveys to authenticated;
grant all on public.surveys to service_role;
alter table public.surveys enable row level security;
create policy "Users read own surveys"
  on public.surveys for select to authenticated
  using (user_id = auth.uid() or public.has_role(auth.uid(), 'admin'));
create policy "Users create own surveys"
  on public.surveys for insert to authenticated
  with check (user_id = auth.uid());


create table public.feedback (
  id text primary key,
  user_id uuid,
  page text,
  sentiment text,
  message text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant insert on public.feedback to anon, authenticated;
grant all on public.feedback to service_role;
alter table public.feedback enable row level security;
create policy "Anyone can send feedback"
  on public.feedback for insert to anon, authenticated
  with check (true);
create policy "Admins read feedback"
  on public.feedback for select to authenticated
  using (public.has_role(auth.uid(), 'admin'));


create index posts_status_idx on public.posts (status, published_at);
create index posts_categories_idx on public.posts using gin (category_ids);
create index products_status_idx on public.products (status, published_at);
create index events_start_idx on public.events (start_at);
create index resources_status_idx on public.resources (status, published_at);
create index orders_owner_email_idx on public.orders (lower(owner_email));
create index notifications_user_idx on public.notifications (user_id, created_at);

alter table public.posts add column search tsvector
  generated always as (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(excerpt, '')), 'B')
  ) stored;
create index posts_search_idx on public.posts using gin (search);

create or replace function public.place_order(
  _lines jsonb,
  _name text,
  _email text,
  _address jsonb
)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  line jsonb;
  v public.product_variants%rowtype;
  qty integer;
  items jsonb := '[]'::jsonb;
  subtotal bigint := 0;
  tax bigint := 0;
  shipping bigint := 0;
  total bigint := 0;
  ord public.orders%rowtype;
begin
  if _lines is null or jsonb_array_length(_lines) = 0 then
    raise exception 'Cart is empty';
  end if;
  if _name is null or length(trim(_name)) < 2 then
    raise exception 'A name is required';
  end if;
  if _email is null or position('@' in _email) < 2 then
    raise exception 'A valid email is required';
  end if;

  for line in select * from jsonb_array_elements(_lines) loop
    select * into v from public.product_variants where id = line->>'variantId';
    if not found then
      raise exception 'Unknown variant %', line->>'variantId';
    end if;
    qty := coalesce((line->>'quantity')::int, 1);
    if qty < 1 or qty > 99 then
      raise exception 'Quantity out of range';
    end if;
    if v.stock < qty then
      raise exception 'Insufficient stock for %', v.sku;
    end if;
    update public.product_variants
      set stock = stock - qty, updated_at = now()
      where id = v.id;
    subtotal := subtotal + v.price_minor * qty;
    items := items || jsonb_build_object(
      'variantId', v.id, 'productId', v.product_id, 'sku', v.sku,
      'quantity', qty, 'unitPriceMinor', v.price_minor, 'currency', v.currency,
      'options', v.options, 'title', line->>'title'
    );
  end loop;

  tax := round(subtotal * 800.0 / 10000.0);
  shipping := case when subtotal >= 10000 then 0 else 800 end;
  total := subtotal + tax + shipping;

  insert into public.orders (
    id, owner_email, name, items, currency, subtotal_minor, tax_minor,
    shipping_minor, total_minor, shipping_address, order_state, payment_state
  ) values (
    gen_random_uuid()::text, lower(_email), _name, items, 'USD',
    subtotal, tax, shipping, total, coalesce(_address, '{}'::jsonb), 'pending', 'unpaid'
  ) returning * into ord;

  return to_json(ord);
end;
$$;
grant execute on function public.place_order(jsonb, text, text, jsonb) to anon, authenticated;

create or replace function public.register_for_event(
  _event_id text,
  _name text,
  _email text,
  _attendance text
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  ev public.events%rowtype;
  taken integer;
  new_id text;
begin
  select * into ev from public.events where id = _event_id;
  if not found then
    raise exception 'Unknown event';
  end if;
  if not ev.registration_open then
    raise exception 'Registration is closed';
  end if;
  select count(*) into taken from public.event_registrations where event_id = _event_id;
  if ev.capacity > 0 and taken >= ev.capacity then
    raise exception 'Event is full';
  end if;
  new_id := gen_random_uuid()::text;
  insert into public.event_registrations (id, event_id, user_id, name, email, attendance)
  values (new_id, _event_id, nullif(auth.uid()::text, '')::uuid, _name, lower(_email), coalesce(_attendance, 'in-person'));
  return new_id;
end;
$$;
grant execute on function public.register_for_event(text, text, text, text) to anon, authenticated;
