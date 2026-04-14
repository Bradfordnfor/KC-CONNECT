// supabase/functions/send-otp-email/index.ts
// Sends OTP emails for signup verification and welcome emails for approved users.
// Uses Supabase's built-in SMTP (or configure your own via env vars).

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const { email, name, otp, type, reason } = body;

    const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');

    if (!RESEND_API_KEY) {
      console.warn('RESEND_API_KEY is not set — email will not be sent. type=' + type + ' to=' + email);
      return new Response(JSON.stringify({ success: false, skipped: true, reason: 'RESEND_API_KEY not set' }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (type === 'otp' && otp) {
      // Admin approved — send OTP to user's email
      const res = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${RESEND_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: Deno.env.get('EMAIL_FROM') ?? 'KC Connect <onboarding@resend.dev>',
          to: [email],
          subject: 'Your KC Connect Verification Code',
          html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
              <h2 style="color: #1565C0;">Your Signup Has Been Approved!</h2>
              <p>Hi ${name},</p>
              <p>An admin has approved your signup request. Enter the code below in the app to complete your registration:</p>
              <div style="background: #f5f5f5; border-radius: 8px; padding: 24px;
                          text-align: center; margin: 16px 0;">
                <span style="font-size: 32px; font-weight: bold; letter-spacing: 8px;
                             color: #1565C0;">${otp}</span>
              </div>
              <p style="color: #666; font-size: 12px;">This code expires in 3 days. Do not share it with anyone.</p>
            </div>
          `,
        }),
      });
      const resBody = await res.json();
      console.log('Resend OTP send result:', JSON.stringify(resBody));
      if (!res.ok) {
        console.error('Resend rejected OTP email for', email, ':', JSON.stringify(resBody));
        return new Response(JSON.stringify({ success: false, resend_error: resBody }), {
          status: 200, // non-fatal — caller decides what to do
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
    } else if (type === 'rejection') {
      // Admin rejected — send rejection email with reason
      const res = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${RESEND_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: Deno.env.get('EMAIL_FROM') ?? 'KC Connect <onboarding@resend.dev>',
          to: [email],
          subject: 'KC Connect Signup Request Update',
          html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
              <h2 style="color: #C62828;">Signup Request Not Approved</h2>
              <p>Hi ${name},</p>
              <p>Unfortunately, your signup request to KC Connect has not been approved at this time.</p>
              <div style="background: #FFF3F3; border-left: 4px solid #C62828; padding: 16px;
                          border-radius: 4px; margin: 16px 0;">
                <strong>Reason:</strong><br/>
                ${reason ?? 'No reason provided.'}
              </div>
              <p>If you believe this is a mistake, please contact your school administration.</p>
            </div>
          `,
        }),
      });
      const resBody = await res.json();
      console.log('Resend rejection send result:', JSON.stringify(resBody));
      if (!res.ok) {
        console.error('Resend rejected rejection email for', email, ':', JSON.stringify(resBody));
      }
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    // Non-fatal — log but don't break the signup flow
    console.error('Email send error:', err);
    return new Response(JSON.stringify({ success: false, error: String(err) }), {
      status: 200, // Return 200 so the caller doesn't treat email failure as signup failure
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
