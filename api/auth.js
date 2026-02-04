// api/auth.js

export default function handler(req, res) {
  // Allow the login page to verify credentials
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { password } = req.body;
  
  // CHECK: Does the password match your Vercel Environment Variable?
  if (password === process.env.AUTH_PASS) {
    
    // Set a "session" cookie that lasts for 1 day (86400 seconds)
    // We create a simple token value (you could make this random, but for simple auth, a fixed valid string works)
    const token = 'valid-session'; 

    // Determine if we are in production (Secure cookie) or dev
    const isProd = process.env.NODE_ENV === 'production';
    
    res.setHeader('Set-Cookie', [
      `auth_token=${token}; Path=/; HttpOnly; SameSite=Strict; Max-Age=86400; ${isProd ? 'Secure' : ''}`
    ]);

    return res.status(200).json({ success: true });
  }

  return res.status(401).json({ success: false, error: 'Unauthorized' });
}
