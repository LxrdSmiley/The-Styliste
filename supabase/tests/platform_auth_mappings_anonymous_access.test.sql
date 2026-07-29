-- GDD v8 §19: platform identity mappings are security data, not a client
-- projection. Anonymous and permanent players receive no raw table access.

BEGIN;

SELECT plan(9);

SELECT ok(
  NOT has_table_privilege('anon', 'public.platform_auth_mappings', 'SELECT'),
  'anonymous database role cannot read platform mappings'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'SELECT'),
  'authenticated players cannot read raw platform mappings'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'INSERT')
    AND NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'UPDATE')
    AND NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'DELETE'),
  'authenticated players cannot mutate platform mappings'
);
SELECT ok(
  has_table_privilege('service_role', 'public.platform_auth_mappings', 'SELECT')
    AND has_table_privilege('service_role', 'public.platform_auth_mappings', 'INSERT')
    AND has_table_privilege('service_role', 'public.platform_auth_mappings', 'UPDATE')
    AND has_table_privilege('service_role', 'public.platform_auth_mappings', 'DELETE'),
  'only the server linking path retains table privileges'
);
SELECT ok(
  NOT EXISTS (
    SELECT 1
    FROM pg_class AS relation
    JOIN pg_namespace AS schema ON schema.oid = relation.relnamespace
    WHERE schema.nspname = 'api' AND relation.relname = 'platform_auth_mappings'
  ),
  'no raw platform-mapping projection is exposed in the API schema'
);
SELECT ok(
  NOT has_schema_privilege('authenticated', 'public', 'USAGE'),
  'authenticated players cannot use the internal public schema'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'private.auth_player_identities', 'SELECT'),
  'authenticated players cannot read the private identity mapping table'
);

SET LOCAL ROLE authenticated;
DO $$
BEGIN
  BEGIN
    PERFORM 1 FROM public.platform_auth_mappings;
    RAISE EXCEPTION 'AUTHENTICATED_PLATFORM_MAPPING_READ_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    INSERT INTO public.platform_auth_mappings(player_id, platform, platform_user_id)
    VALUES ('00000000-0000-4000-8000-00000000a901', 'game_center', 'client-write');
    RAISE EXCEPTION 'AUTHENTICATED_PLATFORM_MAPPING_WRITE_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$$;
RESET ROLE;
SELECT pass('authenticated identity access remains server-owned');

SET LOCAL ROLE anon;
DO $$
BEGIN
  BEGIN
    PERFORM 1 FROM public.platform_auth_mappings;
    RAISE EXCEPTION 'ANON_PLATFORM_MAPPING_READ_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$$;
RESET ROLE;
SELECT pass('anonymous identity access remains blocked');

SELECT * FROM finish();
ROLLBACK;
