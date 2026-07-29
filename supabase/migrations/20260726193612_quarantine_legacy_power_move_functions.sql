-- GDD v8 §19 / PROJECT_RULES §3.
-- Power Moves are not authorized in the Kingston Gate A surface. Retire their
-- public-schema execution grants rather than preserving an unreviewed server
-- bypass. A future approved feature must introduce a scoped private authority
-- function and an audited API/Edge caller contract.

REVOKE ALL ON FUNCTION public.execute_power_move(UUID, TEXT)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION public.apply_public_apology(UUID)
  FROM PUBLIC, anon, authenticated, service_role;
