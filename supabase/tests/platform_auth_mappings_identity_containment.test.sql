-- GDD v8 §19: a client cannot use raw platform mappings to enumerate, link,
-- or alter another player identity.

BEGIN;

SELECT plan(9);

SELECT ok(
  NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'SELECT'),
  'authenticated retains no raw mapping read privilege'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'INSERT'),
  'authenticated cannot insert mappings'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'UPDATE'),
  'authenticated cannot update mappings'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'DELETE'),
  'authenticated cannot delete mappings'
);
SELECT ok(
  NOT has_table_privilege('anon', 'public.platform_auth_mappings', 'SELECT'),
  'anonymous callers cannot select mappings'
);
SELECT ok(
  has_table_privilege('service_role', 'public.platform_auth_mappings', 'INSERT'),
  'service role retains server-side linking capability'
);
SELECT ok(
  NOT EXISTS (
    SELECT 1
    FROM pg_class AS relation
    JOIN pg_namespace AS schema ON schema.oid = relation.relnamespace
    WHERE schema.nspname = 'api' AND relation.relname = 'platform_auth_mappings'
  ),
  'API schema contains no platform identity relation'
);

SET LOCAL ROLE authenticated;
DO $$
BEGIN
  BEGIN
    PERFORM 1 FROM public.platform_auth_mappings
    WHERE player_id = '00000000-0000-4000-8000-0000000000a1';
    RAISE EXCEPTION 'AUTHENTICATED_MAPPING_ENUMERATION_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    UPDATE public.platform_auth_mappings
    SET platform_user_id = 'client-update'
    WHERE player_id = '00000000-0000-4000-8000-0000000000a1';
    RAISE EXCEPTION 'AUTHENTICATED_MAPPING_UPDATE_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$$;
RESET ROLE;
SELECT pass('authenticated enumeration and ownership-change attempts are rejected');

SET LOCAL ROLE anon;
DO $$
BEGIN
  BEGIN
    PERFORM 1 FROM public.platform_auth_mappings;
    RAISE EXCEPTION 'ANON_MAPPING_ENUMERATION_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$$;
RESET ROLE;
SELECT pass('anonymous enumeration attempt is rejected');

SELECT * FROM finish();
ROLLBACK;
