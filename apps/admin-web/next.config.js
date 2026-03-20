/** @type {import('next').NextConfig} */
const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3003/api';
const useProxy = apiUrl.includes('onrender.com');

const nextConfig = {
  reactStrictMode: true,
  output: 'standalone',
  /** Allow slower static generation on CI (e.g. Render) where metadata or data fetches can be slow. */
  staticPageGenerationTimeout: 120,
  async rewrites() {
    if (!useProxy) return [];
    return [
      {
        source: '/api-proxy/:path*',
        destination: `${apiUrl.replace(/\/$/, '')}/:path*`,
      },
    ];
  },
};

module.exports = nextConfig;
