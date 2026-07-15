BEGIN;

-- GDD v7 §§19.2–19.3, 22: platform identifiers require server verification.
-- Preserve all existing rows and retain only authenticated self-read access.
REVOKE ALL PRIVILEGES ON TABLE public.platform_auth_mappings
FROM PUBLIC, anon, authenticated;

GRANT SELECT ON TABLE public.platform_auth_mappings TO authenticated;

-- Reserved for a future server-verified linking flow. No client role receives
-- INSERT, UPDATE, or DELETE access through this migration.
GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLE public.platform_auth_mappings
TO service_role;

DROP POLICY IF EXISTS "Users can insert own platform mappings"
ON public.platform_auth_mappings;

DROP POLICY IF EXISTS "Users can read own platform mappings"
ON public.platform_auth_mappings;

CREATE POLICY "Users can read own platform mappings"
ON public.platform_auth_mappings
FOR SELECT
TO authenticated
USING ((SELECT auth.uid()) = player_id);

COMMENT ON TABLE public.platform_auth_mappings IS
  'Platform identifiers are server-verified only; Flutter clients cannot write mappings.';

COMMENT ON COLUMN public.platform_auth_mappings.platform_user_id IS
  'Opaque platform identifier accepted only from a future server-verified linking flow.';

COMMIT;
