// db.js
import mysql2 from 'serverless-mysql';
import { DBQueryParams, DBResult } from '@/types';

interface DatabaseConfig {
    host: string;
    port: number;
    database: string;
    user: string;
    password: string;
}

const db = mysql2({
    config: {
        host: process.env.MYSQL_HOST || 'localhost',
        port: parseInt(process.env.MYSQL_PORT || '3306'),
        database: process.env.MYSQL_DATABASE || '',
        user: process.env.MYSQL_USER || '',
        password: process.env.MYSQL_PASSWORD || ''
    }
});

export default async function executeQuery({ query, values }: DBQueryParams): Promise<any> {
    try {
        console.log('executeQuery', query, values);
        const results = await db.query(query, values);
        await db.end();
        return results as DBResult[];
    } catch (error) {
        console.error("数据库错误:", error);
        throw new Error(`数据库报错: ${error}`);
    }
}
