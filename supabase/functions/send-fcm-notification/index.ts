// Supabase Edge Function: send-fcm-notification
// GDD §8.14 — FCM Push Notifications via Database Webhooks
//
// Triggered by database webhooks on:
// - archive_listings.status = 'sold' (resale alert to seller)
// - trend_tsunamis announcements (6h warning)
// - rival attacks / eclipse events
//
// Never called directly from SQL RPCs — always via webhook

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.21.0';

// Firebase Admin SDK (service account required)
// Note: In production, store service account JSON in Supabase secrets
const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID') || 'the-styliste';
const FIREBASE_SERVICE_ACCOUNT = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');

interface WebhookPayload {
  type: 'INSERT' | 'UPDATE' | 'DELETE';
  table: string;
  record: Record<string, unknown>;
  schema: string;
  old_record?: Record<string, unknown>;
}

interface FCMMessage {
  message: {
    token?: string;
    topic?: string;
    notification?: {
      title: string;
      body: string;
      imageUrl?: string;
    };
    data?: Record<string, string>;
    android?: {
      priority: 'high' | 'normal';
      notification?: {
        channelId: string;
        sound: string;
        priority: 'high' | 'max' | 'default';
      };
    };
    apns?: {
      headers: {
        'apns-priority': string;
      };
      payload: {
        aps: {
          alert: {
            title: string;
            body: string;
          };
          badge?: number;
          sound: string;
        };
      };
    };
  };
}

serve(async (req: Request) => {
  try {
    // Verify webhook secret
    const webhookSecret = req.headers.get('x-webhook-secret');
    const expectedSecret = Deno.env.get('WEBHOOK_SECRET');
    
    if (expectedSecret && webhookSecret !== expectedSecret) {
      return new Response('Unauthorized', { status: 401 });
    }

    const payload: WebhookPayload = await req.json();
    
    // Route by table and event type
    const notification = await buildNotification(payload);
    
    if (!notification) {
      return new Response('No notification needed', { status: 200 });
    }

    // Send FCM notification
    const result = await sendFCM(notification);
    
    // Log telemetry event
    await logNotificationSent(notification);

    return new Response(
      JSON.stringify({ success: true, result }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('FCM notification failed:', error);
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});

async function buildNotification(payload: WebhookPayload): Promise<FCMMessage | null> {
  const { table, record, old_record, type } = payload;

  // Handle archive_listings status change to 'sold'
  if (table === 'archive_listings' && type === 'UPDATE') {
    const oldStatus = old_record?.status;
    const newStatus = record.status;

    if (oldStatus === 'active' && newStatus === 'sold') {
      // Item sold — notify seller
      const sellerId = record.seller_id as string;
      const token = await getFCMToken(sellerId);
      
      if (!token) return null;

      const designName = await getDesignName(record.design_id as string);
      const salePrice = record.listing_price as number;

      return {
        message: {
          token,
          notification: {
            title: '💰 Item Sold on The Archive',
            body: `"${designName}" sold for $${salePrice}. Your cut is ready.`,
          },
          data: {
            type: 'resale_sold',
            listing_id: record.id as string,
            design_id: record.design_id as string,
            sale_price: salePrice.toString(),
            deep_link: `/archive/listing/${record.id}`,
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'resale_alerts',
              sound: 'default',
              priority: 'high',
            },
          },
          apns: {
            headers: { 'apns-priority': '10' },
            payload: {
              aps: {
                alert: {
                  title: '💰 Item Sold',
                  body: `"${designName}" sold for $${salePrice}`,
                },
                sound: 'default',
              },
            },
          },
        },
      };
    }
  }

  // Handle trend_tsunamis 6h warning
  if (table === 'trend_tsunamis' && type === 'INSERT') {
    // Broadcast to all players via topic
    const theme = record.theme as string;
    const windowOpenAt = record.window_opens_at as string;
    const hoursUntil = Math.floor((new Date(windowOpenAt).getTime() - Date.now()) / 3600000);

    if (hoursUntil <= 6 && hoursUntil > 0) {
      return {
        message: {
          topic: 'all_players',
          notification: {
            title: '🌊 Trend Tsunami Incoming',
            body: `"${theme}" wave arrives in ${hoursUntil}h. Prepare your designs.`,
          },
          data: {
            type: 'trend_tsunami',
            theme,
            window_opens_at: windowOpenAt,
            deep_link: '/atelier',
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'trend_tsunami',
              sound: 'default',
              priority: 'max',
            },
          },
          apns: {
            headers: { 'apns-priority': '10' },
            payload: {
              aps: {
                alert: {
                  title: '🌊 Trend Tsunami',
                  body: `"${theme}" arrives in ${hoursUntil}h`,
                },
                badge: 1,
                sound: 'default',
              },
            },
          },
        },
      };
    }
  }

  // Handle rival attacks (district_control changes)
  if (table === 'district_control' && type === 'UPDATE') {
    const oldController = old_record?.controller_id;
    const newController = record.controller_id;
    const attackedPlayerId = old_controller as string;

    if (oldController !== newController && attackedPlayerId) {
      const token = await getFCMToken(attackedPlayerId);
      if (!token) return null;

      const districtName = await getDistrictName(record.district_id as string);

      return {
        message: {
          token,
          notification: {
            title: '⚔️ Territory Under Attack',
            body: `A rival is contesting your control of ${districtName}!`,
          },
          data: {
            type: 'rival_attack',
            district_id: record.district_id as string,
            deep_link: '/district-map',
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'rival_alerts',
              sound: 'default',
              priority: 'high',
            },
          },
          apns: {
            headers: { 'apns-priority': '10' },
            payload: {
              aps: {
                alert: {
                  title: '⚔️ Territory Attacked',
                  body: `Defend your control of ${districtName}`,
                },
                badge: 1,
                sound: 'default',
              },
            },
          },
        },
      };
    }
  }

  return null;
}

async function sendFCM(message: FCMMessage): Promise<unknown> {
  // Get OAuth2 access token from service account
  const accessToken = await getFirebaseAccessToken();

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(message),
    }
  );

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`FCM send failed: ${error}`);
  }

  return response.json();
}

async function getFirebaseAccessToken(): Promise<string> {
  // In production, use Firebase Admin SDK's credential mechanism
  // This is a simplified placeholder
  if (!FIREBASE_SERVICE_ACCOUNT) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT not configured');
  }

  // Parse service account and generate JWT
  const serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT);
  
  // Implementation: Generate JWT with service account credentials
  // Request token from Google OAuth2 token endpoint
  // Return access token
  
  // Placeholder return
  return 'placeholder_token';
}

async function getFCMToken(playerId: string): Promise<string | null> {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') || '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
  );

  const { data, error } = await supabase
    .from('fcm_tokens')
    .select('token')
    .eq('player_id', playerId)
    .eq('is_active', true)
    .order('last_used_at', { ascending: false })
    .limit(1)
    .single();

  if (error || !data) return null;
  return data.token as string;
}

async function getDesignName(designId: string): Promise<string> {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') || '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
  );

  const { data } = await supabase
    .from('designs')
    .select('name')
    .eq('id', designId)
    .single();

  return (data?.name as string) || 'Unknown Design';
}

async function getDistrictName(districtId: string): Promise<string> {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') || '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
  );

  const { data } = await supabase
    .from('districts')
    .select('name')
    .eq('id', districtId)
    .single();

  return (data?.name as string) || 'Unknown District';
}

async function logNotificationSent(message: FCMMessage): Promise<void> {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') || '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
  );

  // Determine recipient
  const recipient = message.message.token || message.message.topic || 'unknown';
  const notificationType = message.message.data?.type || 'general';

  await supabase.rpc('log_telemetry_event', {
    p_player_id: null, // System event
    p_event_type: 'notification',
    p_event_name: 'notification_sent',
    p_payload: {
      notification_type: notificationType,
      notification_id: `${notificationType}_${Date.now()}`,
      recipient_type: message.message.topic ? 'topic' : 'token',
      recipient: recipient.substring(0, 20) + '...', // Truncate for privacy
      title: message.message.notification?.title,
    },
  });
}
