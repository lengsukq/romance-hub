/** @type {import('next').NextConfig} */
const nextConfig = {
    output: "standalone",
    experimental: {
        serverComponentsExternalPackages: ['@prisma/client', 'prisma']
    },
    webpack: (config, { isServer }) => {
        if (isServer) {
            // 对于服务器端，不压缩以避免 Prisma 问题
            config.optimization.minimize = false;
        }
        
        // 处理 Prisma 客户端
        config.externals.push({
            '@prisma/client': '@prisma/client',
        });
        
        return config;
    },
    reactStrictMode: true,
    // 跳过构建时的静态页面生成，避免 API 路由在构建时被调用
    trailingSlash: false,
    skipTrailingSlashRedirect: true,
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
