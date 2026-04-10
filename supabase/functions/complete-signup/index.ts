// supabase/functions/complete-signup/index.ts
// Called after user enters the OTP. Creates the auth user, sets their password
// to the stored password_hash so the client can sign in immediately with
// signInWithPassword — avoids magic-link token expiry issues entirely.

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

    // password_hash is a 64-char SHA-256 hex string — use it as the auth
    // password so the client can sign in immediately without magic-link tokens.
    const authPassword = signup.password_hash;

    // 2. Create the auth user (or recover existing one on double-submit)
    let userId: string;
    const { data: authData, error: createError } = await adminClient.auth.admin.createUser({
      email: signup.email,
      password: authPassword,
      email_confirm: true,
      user_metadata: {
        full_name: signup.name,
        phone_number: signup.phone ?? '',
        role: signup.role?.toLowerCase() ?? 'staff',
      },
    });

    if (createError) {
      if (createError.message?.includes('already been registered')) {
        // User already exists — update their password and continue
        const { data: listData } = await adminClient.auth.admin.listUsers();
        const existing = listData?.users?.find((u: { email: string }) => u.email === email);
        if (!existing) {
          return new Response(JSON.stringify({ error: createError.message }), {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          });
        }
        await adminClient.auth.admin.updateUserById(existing.id, { password: authPassword });
        userId = existing.id;
      } else {
        return new Response(JSON.stringify({ error: createError.message ?? 'Failed to create user' }), {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
    } else {
      userId = authData.user!.id;
    }

    // 3. Upsert into users table — always update role/status so that even if
    //    the handle_new_user trigger already inserted a row with a default role,
    //    we overwrite it with the correct role from pending_signups.
    await adminClient.from('users').upsert({
      id: userId,
      email: signup.email,
      full_name: signup.name,
      phone_number: signup.phone ?? '',
      role: signup.role?.toLowerCase() ?? 'staff',
      status: 'active',
      updated_at: new Date().toISOString(),
    }, { onConflict: 'id' });

    // 4. Deactivate the pending signup record
    await adminClient
      .from('pending_signups')
      .update({ is_active: false })
      .eq('id', signup.id);

    // 5. Return the password_hash so Flutter can call signInWithPassword directly
    //    — no magic-link token, no expiry risk.
    return new Response(JSON.stringify({
      success: true,
      credential: authPassword,
    }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error('complete-signup error:', err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
