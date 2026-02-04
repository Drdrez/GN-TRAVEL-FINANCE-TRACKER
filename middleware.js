export const config = {
  // Matcher: Protect the dashboard, the html file, and all API routes
  matcher: ['/', '/index.html', '/api/:path*'],
};

export default function middleware(request) {
  // 1. Get the Authorization header from the request
  const basicAuth = request.headers.get('authorization');

  if (basicAuth) {
    // 2. Decode the Base64 username:password
    const authValue = basicAuth.split(' ')[1];
    // atob decodes Base64 in the Edge Runtime
    const [user, pwd] = atob(authValue).split(':');

    // 3. Check credentials against Environment Variables
    if (user === process.env.AUTH_USER && pwd === process.env.AUTH_PASS) {
      // Authentication successful, allow the request to pass
      return new Response(null, {
        headers: { 'x-middleware-next': '1' },
      });
    }
  }

  // 4. If no auth or wrong password, return 401 to trigger the browser popup
  return new Response('Access Denied: Please log in.', {
    status: 401,
    headers: {
      // This header triggers the browser's native login prompt
      'WWW-Authenticate': 'Basic realm="GN Finance Tracker"',
    },
  });
}
