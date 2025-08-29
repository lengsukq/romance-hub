/** @type {import('next').NextConfig} */
const nextConfig = {
    experimental: {
        serverComponentsExternalPackages: ['@prisma/client', 'prisma']
    },
    webpack: (config) => {
        // 处理 Prisma 客户端
        config.externals.push({
            '@prisma/client': '@prisma/client',
        });
        
        return config;
    },
    reactStrictMode: true,
    async redirects() {
        return [
            {
                source: '/trick/:path*',
                destination: '/',
                permanent: false,
                missing: [
                    {
                        type: 'header',
                        key: 'cookie',
                    },
                ],
            },
        ];
    },
    // 环境变量
    env: {
        DATABASE_URL: process.env.DATABASE_URL,
        DATABASE_PROVIDER: process.env.DATABASE_PROVIDER,
    },
}

module.exports = nextConfig
