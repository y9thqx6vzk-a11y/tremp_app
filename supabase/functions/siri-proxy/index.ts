import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// API keys and secrets should be managed via Supabase Secrets
const MOT_API_KEY = Deno.env.get('MOT_API_KEY') ?? '';

serve(async (req) => {
  try {
    const { originLat, originLon, destLat, destLon } = await req.json()
    
    // In a production app, we would query the real MoT SIRI / GTFS APIs here
    // e.g., fetching real-time bus locations and filtering by origin/destination proximity
    // For now, we simulate a processed real-time response:
    
    const mockBusSegment = {
      type: 'bus',
      origin: 'תחנה קרובה למוצא',
      destination: 'תחנה קרובה ליעד',
      durationMinutes: 35,
      description: 'קו אוטובוס (מידע זמן אמת עובד על ידי Supabase Edge Function)'
    };

    return new Response(
      JSON.stringify({ segments: [mockBusSegment] }),
      { headers: { "Content-Type": "application/json" } },
    )
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    })
  }
})
