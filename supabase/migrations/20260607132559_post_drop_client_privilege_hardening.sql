-- Post-drop progression lockdown follow-up.
-- Clients may read through RLS, but reward-bearing and drop/feed tables must
-- not expose direct mutation/destructive privileges outside Edge/RPC paths.
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON TABLE
  public.designs,
  public.feed_posts,
  public.garment_drops,
  public.brand_state,
  public.players
FROM anon, authenticated;
