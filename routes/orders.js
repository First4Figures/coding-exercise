const express = require('express');
const router = express.Router();
const db = require('../config/database');

// GET /api/orders - List all orders
router.get('/', async (req, res) => {
  try {
    const query = `
      SELECT o.*, 
             json_agg(json_build_object(
               'sku', oi.sku,
               'quantity', oi.quantity,
               'unit_price', oi.unit_price,
               'total_price', oi.total_price
             )) as items
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      GROUP BY o.id
      ORDER BY o.created_at DESC
    `;

    const result = await db.query(query);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/orders - Create new order
router.post('/', async (req, res) => {
  try {
    const {
      customer_name,
      customer_email,
      customer_phone,
      shipping_address,
      items,
      payment_method,
      payment_status,
      order_type
    } = req.body;

    // Validate stock availability for in-stock orders
    if (order_type === 'in_stock') {
      for (const item of items) {
        const stockQuery = `
          SELECT 
            p.stock_available,
            COALESCE(SUM(oi.quantity), 0) as allocated_stock
          FROM products p
          LEFT JOIN order_items oi ON p.sku = oi.sku AND oi.order_id IN (
            SELECT id FROM orders WHERE status IN ('pending', 'confirmed', 'processing')
          )
          WHERE p.sku = $1
          GROUP BY p.stock_available
        `;
        
        const stockResult = await db.query(stockQuery, [item.sku]);
        if (stockResult.rows.length === 0) {
          return res.status(404).json({ error: `Product with SKU ${item.sku} not found` });
        }
        
        const availableStock = stockResult.rows[0].stock_available - stockResult.rows[0].allocated_stock;
        if (availableStock < item.quantity) {
          return res.status(400).json({ error: `Insufficient stock for ${item.sku}` });
        }
      }
    }

    // Calculate order totals
    let subtotal = 0;
    const orderItems = [];

    for (const item of items) {
      const productQuery = 'SELECT price FROM products WHERE sku = $1';
      const productResult = await db.query(productQuery, [item.sku]);
      
      if (productResult.rows.length === 0) {
        return res.status(404).json({ error: `Product with SKU ${item.sku} not found` });
      }
      
      const unitPrice = item.unit_price || productResult.rows[0].price;
      const itemTotal = unitPrice * item.quantity;
      subtotal += itemTotal;
      
      orderItems.push({
        sku: item.sku,
        quantity: item.quantity,
        unit_price: unitPrice,
        total: itemTotal
      });
    }

    // Calculate shipping cost (simple flat rate for demo)
    const shippingCost = subtotal > 100 ? 0 : 15.99;
    const total = subtotal + shippingCost;

    // Generate order ID
    const orderId = `ORD-${Date.now()}-${Math.random().toString(36).substr(2, 5).toUpperCase()}`;

    // Create order
    const orderQuery = `
      INSERT INTO orders (
        id, order_number, customer_name, customer_email, shipping_address,
        subtotal, shipping_cost, total_amount, payment_status,
        order_type, status, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, NOW(), NOW())
      RETURNING *
    `;
    
    const orderResult = await db.query(orderQuery, [
      orderId, orderId, customer_name, customer_email, JSON.stringify(shipping_address),
      subtotal, shippingCost, total, payment_status,
      order_type, 'pending'
    ]);

    // Create order items
    for (const item of orderItems) {
      const itemQuery = `
        INSERT INTO order_items (order_id, product_id, sku, product_name, quantity, unit_price, total_price, created_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
      `;
      // Get product details for the order item
      const productQuery = 'SELECT id, name FROM products WHERE sku = $1';
      const productResult = await db.query(productQuery, [item.sku]);
      const productId = productResult.rows[0]?.id || 'unknown';
      const productName = productResult.rows[0]?.name || item.sku;
      
      await db.query(itemQuery, [orderId, productId, item.sku, productName, item.quantity, item.unit_price, item.total]);
    }

    res.status(201).json({
      message: 'Order created successfully',
      order_id: orderId,
      total: total
    });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/orders/:id - Get order details
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const orderQuery = `
      SELECT o.*, 
             json_agg(json_build_object(
               'sku', oi.sku,
               'quantity', oi.quantity,
               'unit_price', oi.unit_price,
               'total_price', oi.total_price
             )) as items
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE o.id = $1
      GROUP BY o.id
    `;

    const result = await db.query(orderQuery, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/orders/:id/status - Update order status
router.patch('/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const query = 'UPDATE orders SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *';
    const result = await db.query(query, [status, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json({ message: 'Order status updated successfully', order: result.rows[0] });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
