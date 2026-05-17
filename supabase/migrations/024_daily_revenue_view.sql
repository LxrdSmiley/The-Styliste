CREATE OR REPLACE VIEW public.daily_revenue_ledger AS
SELECT
  player_id,
  date_trunc('day', computed_at)::date AS revenue_date,
  SUM(amount) AS revenue_total
FROM public.idle_income_log
GROUP BY player_id, date_trunc('day', computed_at)::date;

GRANT SELECT ON public.daily_revenue_ledger TO authenticated;
