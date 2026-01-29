/** @type {import('next').NextConfig} */
const nextConfig = {
    serverExternalPackages: ['@prisma/client', 'prisma'],
    // Next.js 16 默认使用 Turbopack
    // serverExternalPackages 已经足够处理 Prisma 客户端，无需 webpack 配置
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
    // 移除手动环境变量配置，让 Next.js 自动处理 .env.local 文件
    // Next.js 会自动加载 .env.local 文件中的环境变量
}

module.exports = nextConfig
