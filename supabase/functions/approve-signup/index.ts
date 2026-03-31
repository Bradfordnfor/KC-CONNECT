// supabase/functions/approve-signup/index.ts
// Called when admin approves a pending signup.
// Sends the OTP to the user's email and marks admin_approved = true.
// The user account is created later in complete-signup (after user enters the OTP).

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { signup_id } = await req.json();
    if (!signup_id) {
      return new Response(JSON.stringify({ error: 'signup_id is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      { auth: { autoRefreshToken: false, persistSession: false } }
    );

    // Fetch the pending signup
    const { data: signup, error: fetchError } = await adminClient
      .from('pending_signups')
      .select('*')
      .eq('id', signup_id)
      .eq('is_active', true)
      .single();

    if (fetchError || !signup) {
      return new Response(JSON.stringify({ error: 'Signup not found or already processed' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Mark as admin_approved so the user can now enter the OTP
    const { error: updateError } = await adminClient
      .from('pending_signups')
      .update({ admin_approved: true })
      .eq('id', signup_id);

    if (updateError) {
      return new Response(JSON.stringify({ error: updateError.message }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Send OTP to user's email
    await adminClient.functions.invoke('send-otp-email', {
      body: {
        email: signup.email,
        name: signup.name,
        otp: signup.otp,
        type: 'otp',
      },
    });

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
