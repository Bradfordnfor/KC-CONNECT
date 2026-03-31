// supabase/functions/complete-signup/index.ts
// Called after user enters the OTP that was sent to their email by the admin.
// Creates the auth user, inserts into users table, returns a magic-link token
// so the client can sign in immediately without a password.

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
    const { email, otp } = await req.json();
    if (!email || !otp) {
      return new Response(JSON.stringify({ error: 'email and otp are required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      { auth: { autoRefreshToken: false, persistSession: false } }
    );

    // 1. Verify OTP is correct, active, and admin-approved
    const { data: signup, error: fetchError } = await adminClient
      .from('pending_signups')
      .select('*')
      .eq('email', email)
      .eq('otp', otp)
      .eq('is_active', true)
      .eq('admin_approved', true)
      .single();

    if (fetchError || !signup) {
      return new Response(JSON.stringify({ error: 'Invalid or expired OTP' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 2. Create the auth user
    const { data: authData, error: createError } = await adminClient.auth.admin.createUser({
      email: signup.email,
      email_confirm: true,
      user_metadata: { full_name: signup.name },
    });

    if (createError || !authData.user) {
      // If user already exists (e.g. double submit), fetch existing user
      if (createError?.message?.includes('already been registered')) {
        const { data: existingUsers } = await adminClient.auth.admin.listUsers();
        const existingUser = existingUsers?.users?.find((u: { email: string }) => u.email === email);
        if (!existingUser) {
          return new Response(JSON.stringify({ error: createError?.message }), {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          });
        }
        authData.user = existingUser;
      } else {
        return new Response(JSON.stringify({ error: createError?.message ?? 'Failed to create user' }), {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
    }

    const userId = authData.user!.id;

    // 3. Insert into users table (ignore if already exists)
    await adminClient.from('users').upsert({
      id: userId,
      email: signup.email,
      full_name: signup.name,
      phone_number: signup.phone ?? '',
      role: signup.role,
      status: 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    }, { onConflict: 'id', ignoreDuplicates: true });

    // 4. Generate a magic link so the client can sign in immediately
    const { data: linkData, error: linkError } = await adminClient.auth.admin.generateLink({
      type: 'magiclink',
      email: signup.email,
    });

    if (linkError || !linkData?.properties?.hashed_token) {
      return new Response(JSON.stringify({ error: 'Account created but sign-in link failed. Please log in manually.' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 5. Deactivate the pending signup record
    await adminClient
      .from('pending_signups')
      .update({ is_active: false })
      .eq('id', signup.id);

    return new Response(JSON.stringify({
      success: true,
      token: linkData.properties.hashed_token,
    }), {
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
