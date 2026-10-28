-- Chinita Designs: ejecutar SOLO en su nuevo proyecto de Supabase.
create extension if not exists pgcrypto;
create table if not exists public.store_admins(user_id uuid primary key references auth.users(id) on delete cascade,created_at timestamptz not null default now());
create or replace function public.is_store_admin() returns boolean language sql stable security definer set search_path='' as $$ select exists(select 1 from public.store_admins where user_id=(select auth.uid())); $$;
revoke all on function public.is_store_admin() from public;
grant execute on function public.is_store_admin() to authenticated;
create table if not exists public.products(
 id uuid primary key default gen_random_uuid(),
 name text not null check(char_length(name) between 1 and 130),
 description text not null default '' check(char_length(description)<=1200),
 category text not null check(category in('camisetas','vasos','topper','etiquetas','papeleria','otros')),
 sale_type text not null default 'quote' check(sale_type in('quote','direct','both')),
 price numeric(10,2) check(price is null or price>=0),
 photo_url text, active boolean not null default true,featured boolean not null default false,
 created_at timestamptz not null default now(),
 constraint direct_requires_price check(sale_type='quote' or price is not null)
);
create table if not exists public.quote_requests(
 id uuid primary key default gen_random_uuid(),
 customer_name text not null check(char_length(customer_name) between 1 and 120),
 customer_phone text not null check(char_length(customer_phone) between 5 and 24),
 customer_email text check(customer_email is null or char_length(customer_email)<=200),
 needed_by date,
 item_name text not null check(char_length(item_name) between 1 and 160),
 quantity integer not null check(quantity between 1 and 5000),
 details text not null check(char_length(details) between 1 and 2500),
 quoted_price numeric(10,2) check(quoted_price is null or quoted_price>=0),
 internal_notes text check(internal_notes is null or char_length(internal_notes)<=2000),
 status text not null default 'pendiente' check(status in('pendiente','cotizada','aceptada','rechazada','cerrada')),
 created_at timestamptz not null default now()
);
create table if not exists public.orders(
 id uuid primary key default gen_random_uuid(),customer_name text not null,customer_phone text not null,customer_email text not null,
 delivery_method text not null default 'coordinar',notes text,items jsonb not null,
 total numeric(10,2) not null check(total>=0),
 status text not null default 'recibido' check(status in('recibido','confirmado','en_diseno','en_produccion','listo','entregado','cancelado')),
 payment_status text not null default 'pendiente' check(payment_status in('pendiente','pagado','fallido','reembolsado')),
 payment_provider text,payment_reference text unique,created_at timestamptz not null default now()
);
alter table public.store_admins enable row level security;
alter table public.products enable row level security;
alter table public.quote_requests enable row level security;
alter table public.orders enable row level security;
create policy "read own admin membership" on public.store_admins for select to authenticated using(user_id=(select auth.uid()));
create policy "visitor read published products" on public.products for select to anon,authenticated using(active=true);
create policy "admin read all products" on public.products for select to authenticated using(public.is_store_admin());
create policy "admin insert products" on public.products for insert to authenticated with check(public.is_store_admin());
create policy "admin update products" on public.products for update to authenticated using(public.is_store_admin()) with check(public.is_store_admin());
create policy "admin delete products" on public.products for delete to authenticated using(public.is_store_admin());
-- Visitantes solo pueden crear solicitudes; no leer los datos privados de otros clientes.
-- Agregar captcha/rate limiting en backend antes de uso comercial.
create policy "public send quote" on public.quote_requests for insert to anon,authenticated with check(status='pendiente' and quoted_price is null and internal_notes is null);
create policy "admin read quotes" on public.quote_requests for select to authenticated using(public.is_store_admin());
create policy "admin update quotes" on public.quote_requests for update to authenticated using(public.is_store_admin()) with check(public.is_store_admin());
-- Solo backend privilegiado puede crear pedidos tras verificar pagos. Sin policy pública de INSERT.
create policy "admin read orders" on public.orders for select to authenticated using(public.is_store_admin());
create policy "admin update order status" on public.orders for update to authenticated using(public.is_store_admin()) with check(public.is_store_admin());
revoke update on public.orders from authenticated;
grant update(status) on public.orders to authenticated;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('product-images','product-images',true,6291456,array['image/jpeg','image/png','image/webp']) on conflict(id) do nothing;
create policy "public view product photos" on storage.objects for select to anon,authenticated using(bucket_id='product-images');
create policy "admin upload product photos" on storage.objects for insert to authenticated with check(bucket_id='product-images' and public.is_store_admin());
create policy "admin edit product photos" on storage.objects for update to authenticated using(bucket_id='product-images' and public.is_store_admin()) with check(bucket_id='product-images' and public.is_store_admin());
create policy "admin remove product photos" on storage.objects for delete to authenticated using(bucket_id='product-images' and public.is_store_admin());
-- DESPUÉS de crear el usuario en Authentication > Users, asignarlo como administrador:
-- insert into public.store_admins(user_id) select id from auth.users where email='CORREO_CONFIRMADO_DE_LA_DUENA';
