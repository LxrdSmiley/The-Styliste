// Edge Function: eclipse-event-tick
// GDD §7.2 — Phase 8: Global Eclipse Event Broadcaster
// HTTP-invokable (pg_cron config is separate — Phase 9).
//
// Each invocation:
//   1. Selects a random event archetype from ECLIPSE_EVENTS.
//   2. Inserts a row into the events table (GDD §7.2 audit trail).
//   3. Inserts a 'system_eclipse' row into feed_posts — global announcement.
//      Flutter FeedScreen renders this as a high-contrast _SystemEclipseCard.
//
// Uses SERVICE_ROLE_KEY — no JWT required (cron/admin invocation only).

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface EclipseEvent {
  event_key: string;
  name: string;
  description: string;
  buff_multiplier: number; // >1 = buff, <1 = debuff
  duration_minutes: number;
  affected_scope: "global" | "city" | "designer" | "mogul";
  palette: "crimson" | "silver" | "gold"; // feed card palette hint
}

// GDD §7.2 — canonical Eclipse event archetypes
const ECLIPSE_EVENTS: EclipseEvent[] = [
  {
    event_key: "paris_eclipse",
    name: "PARIS ECLIPSE",
    description: "A dominant rival has saturated the Paris market. Global hype output reduced by 25% for 2 hours.",
    buff_multiplier: 0.75,
    duration_minutes: 120,
    affected_scope: "global",
    palette: "crimson",
  },
  {
    event_key: "fashion_week_surge",
    name: "FASHION WEEK SURGE",
    description: "Milan Fashion Week has electrified the industry. All designer hype scores amplified by 30% for 2 hours.",
    buff_multiplier: 1.30,
    duration_minutes: 120,
    affected_scope: "designer",
    palette: "gold",
  },
  {
    event_key: "market_crash",
    name: "MARKET CRASH",
    description: "Global markets destabilised. All store revenue reduced by 20% for 1 hour. Protect your capital.",
    buff_multiplier: 0.80,
    duration_minutes: 60,
    affected_scope: "mogul",
    palette: "crimson",
  },
  {
    event_key: "silver_rush",
    name: "SILVER RUSH",
    description: "A viral moment has flooded the feed. Every active player's hype score receives a 15% bonus for 90 minutes.",
    buff_multiplier: 1.15,
    duration_minutes: 90,
    affected_scope: "global",
    palette: "silver",
  },
  {
    event_key: "supply_crisis",
    name: "SUPPLY CHAIN CRISIS",
    description: "Global supply chain disruptions. Fabric and store costs surge 40% for 1 hour.",
    buff_multiplier: 1.40,
    duration_minutes: 60,
    affected_scope: "global",
    palette: "crimson",
  },
];

serve(async (_req: Request): Promise<Response> => {
  try {
    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    // Select a random event archetype
    const event = ECLIPSE_EVENTS[Math.floor(Math.random() * ECLIPSE_EVENTS.length)];
    const now = new Date();
    const endsAt = new Date(now.getTime() + event.duration_minutes * 60_000);

    // ── 1. Insert into events table ────────────────────────────────────────
    const { error: eventErr } = await admin.from("events").insert({
      type: "eclipse_tick",
      theme: event.name,
      starts_at: now.toISOString(),
      ends_at: endsAt.toISOString(),
      rewards: {
        buff_multiplier: event.buff_multiplier,
        affected_scope: event.affected_scope,
      },
    });
    if (eventErr) {
      console.error("eclipse events insert error:", eventErr.message);
    }

    // ── 2. Broadcast system_eclipse into feed_posts ────────────────────────
    // player_id is NULL — system-originated post. hype defaults to 0.
    const { error: feedErr } = await admin.from("feed_posts").insert({
      player_id: null,
      is_system: true,
      type: "system_eclipse",
      content: {
        event_key: event.event_key,
        name: event.name,
        description: event.description,
        buff_multiplier: event.buff_multiplier,
        duration_minutes: event.duration_minutes,
        affected_scope: event.affected_scope,
        palette: event.palette,
        ends_at: endsAt.toISOString(),
      },
      hype: 0,
    });
    if (feedErr) {
      console.error("eclipse feed_posts insert error:", feedErr.message);
    }

    console.log(`eclipse-event-tick: dispatched ${event.event_key}`);

    return new Response(
      JSON.stringify({ status: "eclipse_dispatched", event_key: event.event_key }),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("eclipse-event-tick fatal:", (err as Error).message);
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});
