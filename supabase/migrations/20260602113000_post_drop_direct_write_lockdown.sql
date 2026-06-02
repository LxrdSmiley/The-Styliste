-- Post-Drop Progression safety verification hardening.
-- Reward-bearing player and brand state writes must stay behind RPC/Edge paths.

REVOKE INSERT, UPDATE, DELETE ON public.players FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON public.brand_state FROM anon, authenticated;

GRANT SELECT ON public.players TO authenticated;
GRANT SELECT ON public.brand_state TO authenticated;

COMMENT ON TABLE public.players IS
  'Player identity/progression state. Client reads own row; reward-bearing writes are RPC/Edge-authoritative.';

COMMENT ON TABLE public.brand_state IS
  'Brand economy/reputation state. Client reads own row; reward-bearing writes are RPC/Edge-authoritative.';
