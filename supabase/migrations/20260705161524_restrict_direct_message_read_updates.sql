-- Restrict Direct Message updates to the read receipt column.
--
-- 029_feed_interactions created a recipient-only UPDATE policy for marking
-- messages read, but granted table-wide UPDATE. Column-level grants keep
-- recipients from rewriting message body/sender/post context through PostgREST.

REVOKE UPDATE ON public.direct_messages FROM authenticated;
GRANT UPDATE (read_at) ON public.direct_messages TO authenticated;
