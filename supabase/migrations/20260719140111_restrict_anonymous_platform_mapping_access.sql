-- The July 1 bootstrap switched first-session gameplay to
-- auth.signInAnonymously(). Supabase anonymous users use the authenticated
-- database role, so role membership alone cannot protect platform identifiers.
--
-- Platform mappings are not part of the anonymous first-loop. They must remain
-- readable only after a permanent identity is linked, while server-verified
-- linking retains its service_role write path.

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE public.platform_auth_mappings
  FROM PUBLIC, anon, authenticated, service_role;

GRANT SELECT ON TABLE public.platform_auth_mappings TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.platform_auth_mappings
  TO service_role;

DROP POLICY IF EXISTS "Users can insert own platform mappings"
  ON public.platform_auth_mappings;
DROP POLICY IF EXISTS "Users can read own platform mappings"
  ON public.platform_auth_mappings;
DROP POLICY IF EXISTS "Platform mappings: permanent identities only"
  ON public.platform_auth_mappings;

CREATE POLICY "Platform mappings: permanent identities only"
  ON public.platform_auth_mappings
  FOR SELECT
  TO authenticated
  USING (
    (SELECT auth.uid()) = player_id
    AND (SELECT (auth.jwt() ->> 'is_anonymous')::boolean) IS FALSE
  );

COMMENT ON TABLE public.platform_auth_mappings IS
  'Platform identifiers are server-verified only. Client reads require a linked, non-anonymous Supabase identity.';

COMMIT;
