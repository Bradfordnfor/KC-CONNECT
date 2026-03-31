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

    if (type === 'otp' && otp) {
      // Admin approved — send OTP to user's email
      if (RESEND_API_KEY) {
        await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: 'KC Connect <noreply@kcconnect.app>',
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
      }
    } else if (type === 'rejection') {
      // Admin rejected — send rejection email with reason
      if (RESEND_API_KEY) {
        await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: 'KC Connect <noreply@kcconnect.app>',
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
