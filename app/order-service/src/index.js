const express = require('express');
const mysql = require('mysql2/promise');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Database config
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || 'password',
  database: process.env.DB_NAME || 'testdb',
  port: process.env.DB_PORT || 3306
};

let dbConnection = null;

// Connect to database
async function connectDB() {
  try {
    dbConnection = await mysql.createConnection(dbConfig);
    console.log('✅ Database connected successfully!');
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    return false;
  }
}

// Health check endpoint
app.get('/', async (req, res) => {
  const isDBConnected = await connectDB();
  
  res.json({
    service: 'order-service',
    status: 'running',
    timestamp: new Date().toISOString(),
    database: {
      connected: isDBConnected,
      host: dbConfig.host,
      database: dbConfig.database
    },
    message: isDBConnected 
      ? '✅ Server is running and DB is connected!' 
      : '⚠️ Server is running but DB connection failed!'
  });
});

// Simple test endpoint
app.get('/test', (req, res) => {
  res.json({
    message: 'Express server is working!',
    env: process.env.NODE_ENV || 'development'
  });
});

// Start server
app.listen(PORT, async () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 Health check: http://localhost:${PORT}`);
  console.log('✅ Server is running with NEW CODE! 🚀');

  
  // Test DB connection on startup
  await connectDB();
});