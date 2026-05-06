-- The Styliste — Seed Data
-- Reference suppliers (GDD §5.1) for local dev / testing

INSERT INTO public.suppliers (id, name, tier, category, quality, cost, reliability, prestige)
VALUES
  (gen_random_uuid(), 'City Fabrics Co.',       'local',         'raw_materials',  40, 20, 70, 20),
  (gen_random_uuid(), 'RegioWeave',             'regional',      'raw_materials',  55, 35, 65, 35),
  (gen_random_uuid(), 'Global Thread Ltd.',     'international', 'raw_materials',  70, 55, 60, 60),
  (gen_random_uuid(), 'Maison Luxe Textiles',   'luxury',        'raw_materials',  95, 90, 85, 95),
  (gen_random_uuid(), 'QuickStitch Factory',    'local',         'manufacturing',  35, 15, 75, 15),
  (gen_random_uuid(), 'Meridian Mfg.',          'regional',      'manufacturing',  60, 40, 70, 40),
  (gen_random_uuid(), 'Apex Production Group',  'international', 'manufacturing',  75, 60, 65, 65),
  (gen_random_uuid(), 'Atelier Précis',         'luxury',        'manufacturing',  98, 88, 90, 98),
  (gen_random_uuid(), 'FastFreight Co.',        'local',         'logistics',      30, 10, 80, 10),
  (gen_random_uuid(), 'RegioRoute Logistics',   'regional',      'logistics',      55, 30, 72, 35),
  (gen_random_uuid(), 'GlobalCarrier Intl.',    'international', 'logistics',      70, 50, 68, 60),
  (gen_random_uuid(), 'Prestige Courier Elite', 'luxury',        'logistics',      90, 85, 88, 90)
ON CONFLICT DO NOTHING;
