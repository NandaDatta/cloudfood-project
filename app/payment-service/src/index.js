const express = require('express');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5001;

app.get('/', (req, res) => {
  res.json({
    service: 'payment-service',
    status: 'running',
    timestamp: new Date().toISOString(),
    message: '✅ Payment service is running!'
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'payment-service'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Payment service running on port ${PORT}`);
});