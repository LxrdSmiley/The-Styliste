-- GDD v6 §12.2.2: Staff Rally and Supplier Raid are community events,
-- not standalone mini-games.

CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated;

UPDATE public.mini_game_attempts
SET claimed_at = COALESCE(claimed_at, NOW()),
    result_key = COALESCE(result_key, 'feature_retired'),
    reward = COALESCE(reward, '{}'::JSONB)
WHERE game_key IN ('staff_rally', 'supplier_raid')
  AND claimed_at IS NULL;

CREATE OR REPLACE FUNCTION private.reject_retired_standalone_mini_games()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
  IF NEW.game_key IN ('staff_rally', 'supplier_raid') THEN
    RAISE EXCEPTION 'STANDALONE_GAME_RETIRED';
  END IF;
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION private.reject_retired_standalone_mini_games()
  FROM PUBLIC;

DROP TRIGGER IF EXISTS mini_game_attempts_reject_retired
  ON public.mini_game_attempts;
CREATE TRIGGER mini_game_attempts_reject_retired
BEFORE INSERT OR UPDATE OF game_key ON public.mini_game_attempts
FOR EACH ROW
EXECUTE FUNCTION private.reject_retired_standalone_mini_games();

DROP FUNCTION IF EXISTS public.apply_logistics_discount(UUID, NUMERIC, INT);
DROP FUNCTION IF EXISTS public.halt_supply_chain(UUID);
