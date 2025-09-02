require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

// Import routes
const productsRoutes = require('./routes/products');
const ordersRoutes = require('./routes/orders');
const webhooksRoutes = require('./routes/webhooks');

const app = express();
const PORT = process.env.PORT || 3000;

// CORS configuration
app.use(cors());

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static files
app.use(express.static(path.join(__dirname, 'public')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString()
  });
});

// API routes
app.use('/api/products', productsRoutes);
app.use('/api/orders', ordersRoutes);
app.use('/api/webhooks', webhooksRoutes);

// Serve dashboard
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Collectibles Management System server running on port ${PORT}`);
  console.log(`📊 Dashboard available at: http://localhost:${PORT}`);
  console.log(`🔌 API endpoints available at: http://localhost:${PORT}/api`);
});

module.exports = app;
