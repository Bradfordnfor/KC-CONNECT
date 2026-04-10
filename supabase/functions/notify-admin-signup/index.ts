// supabase/functions/notify-admin-signup/index.ts
// Sends an email to the admin when a new staff/admin signup request is submitted.
// Includes the OTP so admin can manually relay it during testing without needing
// to be logged into the app.

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
    const { applicant_name, applicant_email, applicant_role, signup_id } = await req.json();

    const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');
    const ADMIN_EMAIL = Deno.env.get('ADMIN_EMAIL');

    if (!RESEND_API_KEY || !ADMIN_EMAIL) {
      console.log('RESEND_API_KEY or ADMIN_EMAIL not set — skipping admin email');
      return new Response(JSON.stringify({ success: true, skipped: true }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Fetch the OTP from pending_signups using service role so admin can relay it
    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      { auth: { autoRefreshToken: false, persistSession: false } }
    );

    const { data: signup } = await adminClient
      .from('pending_signups')
      .select('otp')
      .eq('id', signup_id)
      .single();

    const otp = signup?.otp ?? '(not available)';
    const roleLabel = applicant_role === 'admin' ? 'Admin' : 'Staff';

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: Deno.env.get('EMAIL_FROM') ?? 'KC Connect <onboarding@resend.dev>',
        to: [ADMIN_EMAIL],
        subject: `[KC Connect] New ${roleLabel} Signup — ${applicant_name}`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #1565C0;">New ${roleLabel} Signup Request</h2>
            <p><strong>${applicant_name}</strong> (${applicant_email}) has requested to join as <strong>${roleLabel}</strong>.</p>

            <div style="background: #E3F2FD; border-radius: 8px; padding: 20px; margin: 16px 0;">
              <p style="margin: 0 0 8px; color: #555; font-size: 13px;">OTP for this applicant (share after approving in app):</p>
              <span style="font-size: 28px; font-weight: bold; letter-spacing: 8px; color: #1565C0;">${otp}</span>
            </div>

            <p style="color: #666; font-size: 13px;">
              Open KC Connect → Notifications → Approve or Reject.<br/>
              Once approved, the OTP above is sent automatically to the applicant's email.
            </p>
            <p style="color: #999; font-size: 11px;">Request ID: ${signup_id}</p>
          </div>
        `,
      }),
    });

    const resBody = await res.json();
    console.log('Resend response:', JSON.stringify(resBody));

    if (!res.ok) {
      console.error('Resend error:', resBody);
    }

    return new Response(JSON.stringify({ success: res.ok, resend: resBody }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error('Admin email notification error:', err);
    return new Response(JSON.stringify({ success: false, error: String(err) }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
