const express = require('express');
const router = express.Router();
const db = require('../config/database');

// GET /api/products - List all products with current stock
router.get('/', async (req, res) => {
  try {
    const { low_stock } = req.query;
    
    let whereClause = '';
    if (low_stock === 'true') {
      whereClause = 'WHERE (stock_available / edition_size::float) < 0.1';
    }

    const query = `
      SELECT 
        p.*,
        COALESCE(SUM(oi.quantity), 0) as allocated_stock,
        (p.stock_available - COALESCE(SUM(oi.quantity), 0)) as available_stock,
        COALESCE(SUM(CASE WHEN o.status IN ('shipped', 'delivered') THEN oi.quantity ELSE 0 END), 0) as total_sold
      FROM products p
      LEFT JOIN order_items oi ON p.sku = oi.sku
      LEFT JOIN orders o ON oi.order_id = o.id
      ${whereClause}
      GROUP BY p.id, p.sku, p.name, p.description, p.edition_size, p.price, p.weight, p.status, p.category, p.stock_available, p.created_at, p.updated_at
      ORDER BY p.created_at DESC
    `;
    
    const result = await db.query(query);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/products/:sku - Get single product details
router.get('/:sku', async (req, res) => {
  try {
    const { sku } = req.params;

    const query = `
      SELECT 
        p.*,
        COALESCE(SUM(oi.quantity), 0) as allocated_stock,
        (p.stock_available - COALESCE(SUM(oi.quantity), 0)) as available_stock,
        COALESCE(SUM(CASE WHEN o.status IN ('shipped', 'delivered') THEN oi.quantity ELSE 0 END), 0) as total_sold
      FROM products p
      LEFT JOIN order_items oi ON p.sku = oi.sku
      LEFT JOIN orders o ON oi.order_id = o.id
      WHERE p.sku = $1
      GROUP BY p.id, p.sku, p.name, p.description, p.edition_size, p.price, p.weight, p.status, p.category, p.stock_available, p.created_at, p.updated_at
    `;

    const result = await db.query(query, [sku]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching product:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/products/:sku/inventory - Update stock levels
router.patch('/:sku/inventory', async (req, res) => {
  try {
    const { sku } = req.params;
    const { quantity, reason, notes } = req.body;

    // Get current product info
    const productQuery = 'SELECT * FROM products WHERE sku = $1';
    const productResult = await db.query(productQuery, [sku]);

    if (productResult.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }

    const product = productResult.rows[0];
    const newStock = product.stock_available + quantity;

    if (newStock < 0) {
      return res.status(400).json({ error: 'Insufficient stock' });
    }

    // Update product stock
    const updateQuery = 'UPDATE products SET stock_available = $1, updated_at = NOW() WHERE sku = $2';
    await db.query(updateQuery, [newStock, sku]);

    // Log inventory change
    const logQuery = `
      INSERT INTO inventory_logs (product_id, sku, movement_type, quantity, balance_after, reference_type, notes, created_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
    `;
    const movementType = quantity > 0 ? 'restock' : 'reduction';
    await db.query(logQuery, [
      product.id, sku, movementType, quantity, newStock, 'adjustment', notes
    ]);

    res.json({ message: 'Stock updated successfully', new_stock: newStock });
  } catch (error) {
    console.error('Error updating inventory:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
