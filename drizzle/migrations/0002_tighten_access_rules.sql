CREATE OR REPLACE FUNCTION public.is_public_record(_status text, _published_at timestamptz, _scheduled_at timestamptz)
RETURNS boolean LANGUAGE sql STABLE SET search_path = public AS $$
  select (_status = 'published' and _published_at is not null and _published_at <= now())
      or (_status = 'scheduled' and _scheduled_at is not null and _scheduled_at <= now())
$$;

-- Publishable content: only visible rows, admins see everything
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['posts','products','events','resources','pages','customer_stories'] LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Public read %1$s" ON public.%1$I', t);
    EXECUTE format('CREATE POLICY "Public read %1$s" ON public.%1$I FOR SELECT TO anon, authenticated USING (public.is_public_record(status, published_at, scheduled_at) OR public.has_role(auth.uid(), ''admin''))', t);
  END LOOP;
  FOREACH t IN ARRAY ARRAY['authors','categories','tags','team_members','testimonials','faqs','media_assets'] LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Public read %1$s" ON public.%1$I', t);
    EXECUTE format('CREATE POLICY "Public read %1$s" ON public.%1$I FOR SELECT TO anon, authenticated USING (id IS NOT NULL AND length(id) > 0)', t);
  END LOOP;
END $$;

DROP POLICY IF EXISTS "Public read jobs" ON public.jobs;
CREATE POLICY "Public read jobs" ON public.jobs FOR SELECT TO anon, authenticated
  USING (open OR public.has_role(auth.uid(), 'admin'));

DROP POLICY IF EXISTS "Public read product_variants" ON public.product_variants;
CREATE POLICY "Public read product_variants" ON public.product_variants FOR SELECT TO anon, authenticated
  USING (public.has_role(auth.uid(), 'admin') OR EXISTS (
    SELECT 1 FROM public.products p WHERE p.id = product_id AND public.is_public_record(p.status, p.published_at, p.scheduled_at)));

DROP POLICY IF EXISTS "Public read product_reviews" ON public.product_reviews;
CREATE POLICY "Public read product_reviews" ON public.product_reviews FOR SELECT TO anon, authenticated
  USING (moderation = 'approved' OR (auth.uid() IS NOT NULL AND user_id = auth.uid()) OR public.has_role(auth.uid(), 'admin'));

-- Public submissions: validated inserts
DROP POLICY IF EXISTS "Anyone can submit contact_submissions" ON public.contact_submissions;
CREATE POLICY "Anyone can submit contact_submissions" ON public.contact_submissions FOR INSERT TO anon, authenticated
  WITH CHECK (length(trim(name)) BETWEEN 1 AND 200 AND position('@' in email) > 1 AND length(email) <= 320 AND length(message) BETWEEN 1 AND 5000);

DROP POLICY IF EXISTS "Anyone can submit newsletter_subscriptions" ON public.newsletter_subscriptions;
CREATE POLICY "Anyone can submit newsletter_subscriptions" ON public.newsletter_subscriptions FOR INSERT TO anon, authenticated
  WITH CHECK (consent AND position('@' in email) > 1 AND length(email) <= 320);

DROP POLICY IF EXISTS "Anyone can register event_registrations" ON public.event_registrations;
CREATE POLICY "Anyone can register event_registrations" ON public.event_registrations FOR INSERT TO anon, authenticated
  WITH CHECK (position('@' in email) > 1 AND length(email) <= 320 AND length(trim(name)) BETWEEN 1 AND 200
    AND (user_id IS NULL OR user_id = auth.uid())
    AND EXISTS (SELECT 1 FROM public.events e WHERE e.id = event_id AND e.registration_open));

DROP POLICY IF EXISTS "Anyone can register job_applications" ON public.job_applications;
CREATE POLICY "Anyone can register job_applications" ON public.job_applications FOR INSERT TO anon, authenticated
  WITH CHECK (consent AND position('@' in email) > 1 AND length(email) <= 320 AND length(trim(name)) BETWEEN 1 AND 200
    AND (user_id IS NULL OR user_id = auth.uid())
    AND EXISTS (SELECT 1 FROM public.jobs j WHERE j.id = job_id AND j.open));

DROP POLICY IF EXISTS "Anyone can send feedback" ON public.feedback;
CREATE POLICY "Anyone can send feedback" ON public.feedback FOR INSERT TO anon, authenticated
  WITH CHECK ((user_id IS NULL OR user_id = auth.uid()) AND coalesce(length(message), 0) <= 5000);

-- Orders must go through place_order (server-side pricing); no direct inserts
DROP POLICY IF EXISTS "Anyone can place an order" ON public.orders;
CREATE POLICY "Admins can insert orders" ON public.orders FOR INSERT TO authenticated
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

-- Media bucket: signed-in read, admin-only writes
DROP POLICY IF EXISTS "Authenticated upload media files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated replace media files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated remove media files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated read media files" ON storage.objects;
CREATE POLICY "Authenticated read media files" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'media' AND (owner_id = auth.uid()::text OR public.has_role(auth.uid(), 'admin')));
CREATE POLICY "Admins upload media files" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'media' AND public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins replace media files" ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'media' AND public.has_role(auth.uid(), 'admin'))
  WITH CHECK (bucket_id = 'media' AND public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins remove media files" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'media' AND public.has_role(auth.uid(), 'admin'));