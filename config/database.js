const { Pool } = require('pg');

class Database {
  constructor() {
    this.pool = null;
    this.init();
  }

  init() {
    try {
      this.pool = new Pool({
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 5432,
        database: process.env.DB_NAME || 'collectibles_db',
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD || 'root',
        ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
        max: 20,
        idleTimeoutMillis: 30000,
        connectionTimeoutMillis: 10000,
      });

      // Handle pool errors
      this.pool.on('error', (err) => {
        console.error('Unexpected error on idle client', err);
        process.exit(-1);
      });

      // Test connection
      this.testConnection();
    } catch (error) {
      console.error('Failed to initialize database pool:', error);
      throw error;
    }
  }

  async testConnection() {
    try {
      const client = await this.pool.connect();
      console.log('Database connection established successfully');
      client.release();
    } catch (error) {
      console.error('Database connection failed:', error);
      throw error;
    }
  }

  async query(text, params) {
    try {
      const result = await this.pool.query(text, params);
      return result;
    } catch (error) {
      console.error('Query execution failed:', error);
      throw error;
    }
  }

  async getClient() {
    return await this.pool.connect();
  }

  async close() {
    if (this.pool) {
      await this.pool.end();
      console.log('Database pool closed');
    }
  }
}

module.exports = new Database();
