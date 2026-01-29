/** @type {import('next').NextConfig} */
const nextConfig = {
    serverExternalPackages: ['@prisma/client', 'prisma'],
    // Next.js 16 默认使用 Turbopack，但如果有自定义 webpack 配置，会自动回退到 webpack
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
    // 移除手动环境变量配置，让 Next.js 自动处理 .env.local 文件
    // Next.js 会自动加载 .env.local 文件中的环境变量
}

module.exports = nextConfig
