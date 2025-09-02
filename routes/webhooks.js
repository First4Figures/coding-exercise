const express = require('express');
const router = express.Router();
const db = require('../config/database');

// POST /api/webhooks/fulfillment - Handle fulfillment webhooks
router.post('/fulfillment', async (req, res) => {
  try {
    const {
      event,
      order_id,
      tracking_number,
      status,
      items
    } = req.body;

    console.log('Webhook received:', { event, order_id, status, items });

    switch (event) {
      case 'shipment.updated':
        await handleShipmentUpdate(order_id, tracking_number, status, items);
        break;
      
      case 'inventory.restocked':
        await handleInventoryRestock(items);
        break;
      
      default:
        return res.status(400).json({ error: `Unsupported event type: ${event}` });
    }

    // Log webhook
    await logWebhook(event, order_id, status, items, 'success', null);

    res.status(200).json({
      success: true,
      message: `Webhook processed successfully for event: ${event}`
    });

  } catch (error) {
    console.error('Webhook processing failed:', error);
    
    // Log webhook failure
    await logWebhook(req.body.event, req.body.order_id, req.body.status, req.body.items, 'failed', error.message);
    
    res.status(500).json({ error: 'Webhook processing failed' });
  }
});

// Handle shipment updates
async function handleShipmentUpdate(orderId, trackingNumber, status, items) {
  if (!orderId) {
    throw new Error('Order ID is required for shipment updates');
  }

  // Update order status
  const validStatuses = ['shipped', 'delivered', 'in_transit'];
  if (!validStatuses.includes(status)) {
    throw new Error(`Invalid shipment status: ${status}`);
  }

  // Get current order
  const orderQuery = 'SELECT * FROM orders WHERE id = $1';
  const orderResult = await db.query(orderQuery, [orderId]);

  if (orderResult.rows.length === 0) {
    throw new Error(`Order ${orderId} not found`);
  }

  // Update order status and tracking
  const updateQuery = `
    UPDATE orders 
    SET status = $1, tracking_number = $2, updated_at = NOW()
    WHERE id = $3
  `;
  await db.query(updateQuery, [status, trackingNumber, orderId]);

  // Update inventory for shipped items
  for (const item of items) {
    const inventoryQuery = `
      UPDATE products 
      SET stock_available = stock_available - $1, updated_at = NOW()
      WHERE sku = $2
    `;
    await db.query(inventoryQuery, [item.quantity, item.sku]);
  }
}

// Handle inventory restock
async function handleInventoryRestock(items) {
  for (const item of items) {
    const { sku, quantity_added, new_total } = item;
    
    if (new_total !== undefined) {
      // Set to specific total
      const updateQuery = 'UPDATE products SET stock_available = $1, updated_at = NOW() WHERE sku = $2';
      await db.query(updateQuery, [new_total, sku]);
    } else if (quantity_added) {
      // Add to existing stock
      const updateQuery = 'UPDATE products SET stock_available = stock_available + $1, updated_at = NOW() WHERE sku = $2';
      await db.query(updateQuery, [quantity_added, sku]);
    }
  }
}

// Log webhook
async function logWebhook(event, orderId, status, items, result, errorMessage) {
  try {
    const query = `
      INSERT INTO webhooks (event_type, payload, status, processed_at, error_message, created_at)
      VALUES ($1, $2, $3, $4, $5, NOW())
    `;
    const payload = { event, order_id: orderId, status, items };
    const processedAt = result === 'success' ? new Date() : null;
    await db.query(query, [event, JSON.stringify(payload), result, processedAt, errorMessage]);
  } catch (error) {
    console.error('Failed to log webhook:', error);
  }
}

module.exports = router;
