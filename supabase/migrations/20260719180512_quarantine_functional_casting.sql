-- Directive 26: quarantine the noncompliant Luxe-funded functional Talent
-- Casting loop. GDD v7 §§2.5, 8.3, 10.2, 15.1, 15.2, 17, 19.2, 19.3,
-- and 22 remain authoritative. This migration intentionally preserves every
-- historical balance, pity, roster, banner, and acquisition row.

-- Remove any legacy overload while retaining the current two-argument return
-- contract for forward migration compatibility.
DO $$
DECLARE
  v_signature TEXT;
BEGIN
  FOR v_signature IN
    SELECT p.oid::REGPROCEDURE::TEXT
    FROM pg_catalog.pg_proc AS p
    JOIN pg_catalog.pg_namespace AS n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname = 'execute_casting_pull'
      AND p.oid <> COALESCE(
        pg_catalog.to_regprocedure(
          'public.execute_casting_pull(text,boolean)'
        )::OID,
        0::OID
      )
  LOOP
    EXECUTE pg_catalog.format(
      'REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon, authenticated, service_role',
      v_signature
    );
    EXECUTE pg_catalog.format('DROP FUNCTION %s', v_signature);
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION public.execute_casting_pull(
  p_banner_id TEXT DEFAULT 'standard',
  p_is_ten_pull BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
  success BOOLEAN,
  pulls JSONB,
  luxe_spent INTEGER,
  prestige_earned INTEGER,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
BEGIN
  -- Reference the compatibility parameters without reading any application
  -- table. The exception is raised before every economic or ownership action.
  PERFORM p_banner_id, p_is_ten_pull;
  RAISE EXCEPTION 'CASTING_UNAVAILABLE';
END;
$$;

REVOKE ALL ON FUNCTION public.execute_casting_pull(TEXT, BOOLEAN)
  FROM PUBLIC, anon, authenticated, service_role;

COMMENT ON FUNCTION public.execute_casting_pull(TEXT, BOOLEAN) IS
  'Quarantined: functional Talent Casting is unavailable pending a GDD v7-compliant redesign.';
