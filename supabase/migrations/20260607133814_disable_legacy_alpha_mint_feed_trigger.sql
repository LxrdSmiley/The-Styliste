-- The authoritative post-drop path now publishes Alpha feed posts through
-- public.edge_drop_design. The legacy mint trigger created a design_flex post
-- on design insert, which caused a pre-drop feed card and a second card after
-- DROP TO FEED. Keep the function for compatibility, but disable the trigger.
DROP TRIGGER IF EXISTS on_design_minted ON public.designs;

COMMENT ON FUNCTION public.fn_on_design_minted() IS
  'Legacy Alpha mint feed publisher disabled by migration 20260607133814. Alpha drop feed posts are published by edge_drop_design only.';
