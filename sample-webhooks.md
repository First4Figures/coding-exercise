# Sample Webhook Payloads

This file contains example webhook payloads that your system should handle. Use these for testing your webhook endpoints.

## Testing Webhooks

You can test webhooks using curl, Postman, or any HTTP client:

```bash
# Basic webhook test
curl -X POST http://localhost:3000/api/webhooks/fulfillment \
  -H "Content-Type: application/json" \
  -d @webhook-samples/shipment-updated.json
```

## 1. Shipment Updated

**Event**: Item has been shipped from fulfillment center

**Endpoint**: `POST /api/webhooks/fulfillment`

```json
{
  "event": "shipment.updated",
  "timestamp": "2024-08-25T10:30:00Z",
  "order_id": "ORD-20240120-004",
  "tracking_number": "1Z999AA10987654321",
  "carrier": "UPS",
  "status": "shipped",
  "estimated_delivery": "2024-08-27T18:00:00Z",
  "items": [
    {
      "sku": "FF-MARIO-003",
      "product_name": "Super Mario - Fire Flower Edition",
      "quantity": 1
    }
  ],
  "shipping_address": {
    "name": "Sarah Wilson",
    "street": "321 Elm St",
    "city": "Houston",
    "state": "TX",
    "zip": "77001",
    "country": "USA"
  }
}
```

**Your system should handle this webhook appropriately**

---

## 2. Shipment Delivered

**Event**: Package has been delivered to customer

```json
{
  "event": "shipment.delivered",
  "timestamp": "2024-08-27T16:45:00Z",
  "order_id": "ORD-20240102-002",
  "tracking_number": "1Z999BB20234567895",
  "carrier": "UPS",
  "status": "delivered",
  "delivered_at": "2024-08-27T16:45:00Z",
  "signature": "J.SMITH",
  "items": [
    {
      "sku": "FF-ZELDA-002",
      "product_name": "Link - Breath of the Wild",
      "quantity": 1
    }
  ]
}
```

**Your system should handle this webhook appropriately**

---

## 3. Payment Received

**Event**: Payment has been processed (useful for pre-orders)

```json
{
  "event": "payment.received",
  "timestamp": "2024-08-25T14:20:00Z",
  "order_id": "ORD-20240125-005",
  "payment_type": "final_payment",
  "amount": 299.99,
  "currency": "USD",
  "payment_method": "credit_card",
  "transaction_id": "TXN-987654321",
  "total_paid": 399.99,
  "order_total": 463.24,
  "remaining_balance": 63.25
}
```

**Your system should handle this webhook appropriately**

---

## 4. Inventory Restock

**Event**: New stock has arrived at warehouse

```json
{
  "event": "inventory.restocked",
  "timestamp": "2024-08-25T09:00:00Z",
  "warehouse_id": "WH-001",
  "items": [
    {
      "sku": "FF-KRATOS-008",
      "product_name": "Kratos - God of War",
      "quantity_added": 50,
      "new_total": 53,
      "batch_number": "BATCH-20240825-001"
    },
    {
      "sku": "FZ-GOKU-001",
      "product_name": "Super Saiyan Goku",
      "quantity_added": 100,
      "new_total": 115,
      "batch_number": "BATCH-20240825-002"
    }
  ]
}
```

**Your system should handle this webhook appropriately**

---

## 5. Order Cancelled

**Event**: Order has been cancelled (by customer or system)

```json
{
  "event": "order.cancelled",
  "timestamp": "2024-08-25T11:30:00Z",
  "order_id": "ORD-20240115-003",
  "reason": "customer_request",
  "cancelled_by": "customer",
  "refund_amount": 220.17,
  "refund_method": "original_payment",
  "items": [
    {
      "sku": "FZ-GOKU-001",
      "quantity": 1
    }
  ]
}
```

**Your system should handle this webhook appropriately**

---

## 6. Pre-order Status Update

**Event**: Pre-order item status has changed (e.g., production started)

```json
{
  "event": "preorder.status_updated",
  "timestamp": "2024-08-25T08:00:00Z",
  "sku": "FF-SAMUS-004",
  "product_name": "Samus Aran - Varia Suit",
  "old_status": "pre_order",
  "new_status": "in_production",
  "estimated_ship_date": "2025-05-15T00:00:00Z",
  "production_batch": "BATCH-SAMUS-001",
  "affected_orders": [
    "ORD-20240125-005",
    "ORD-20240130-007"
  ]
}
```

**Your system should handle this webhook appropriately**

---

## 7. Low Stock Alert

**Event**: Product stock has fallen below threshold

```json
{
  "event": "inventory.low_stock",
  "timestamp": "2024-08-25T15:45:00Z",
  "sku": "FF-MARIO-003",
  "product_name": "Super Mario - Fire Flower Edition",
  "current_stock": 6,
  "threshold": 20,
  "stock_allocated": 2,
  "available_for_sale": 4,
  "days_of_inventory": 12,
  "reorder_recommended": true
}
```

**Your system should handle this webhook appropriately**

---

## 8. Return/Refund Processed

**Event**: Customer return has been processed

```json
{
  "event": "return.processed",
  "timestamp": "2024-08-25T13:15:00Z",
  "order_id": "ORD-20240101-001",
  "return_id": "RET-20240825-001",
  "reason": "damaged_in_shipping",
  "refund_amount": 149.99,
  "restocking_fee": 0.00,
  "items": [
    {
      "sku": "FF-SONIC-001",
      "product_name": "Sonic the Hedgehog - Classic Edition",
      "quantity": 1,
      "condition": "damaged",
      "restock": false
    }
  ]
}
```

**Your system should handle this webhook appropriately**

---

## Error Handling

Your webhook handler should properly validate payloads and return appropriate HTTP status codes.

## Testing Commands

```bash
# Test shipment update
curl -X POST http://localhost:3000/api/webhooks/fulfillment \
  -H "Content-Type: application/json" \
  -d '{
    "event": "shipment.updated",
    "order_id": "ORD-20240120-004",
    "tracking_number": "TEST-123456789",
    "status": "shipped",
    "items": [{"sku": "FF-MARIO-003", "quantity": 1}]
  }'

# Test inventory restock
curl -X POST http://localhost:3000/api/webhooks/fulfillment \
  -H "Content-Type: application/json" \
  -d '{
    "event": "inventory.restocked",
    "items": [
      {"sku": "FF-KRATOS-008", "quantity_added": 25, "new_total": 28}
    ]
  }'

# Test order cancellation
curl -X POST http://localhost:3000/api/webhooks/fulfillment \
  -H "Content-Type: application/json" \
  -d '{
    "event": "order.cancelled",
    "order_id": "ORD-20240115-003",
    "reason": "customer_request",
    "refund_amount": 220.17
  }'
```