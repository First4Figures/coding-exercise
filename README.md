# Collectibles Management System

A simple Node.js API with PostgreSQL for managing a collectibles/figurines store inventory system.

## Features

- **Inventory Management**: Track available vs allocated stock for limited edition collectibles
- **Order Processing**: Create and manage orders with automatic stock allocation
- **Webhook Automation**: Process fulfillment updates and inventory restocks
- **Analytics Dashboard**: Real-time view of top products, low stock alerts, and order statistics

## Project Structure

```
/
├── server.js                 # Main application file
├── /routes                   # API route handlers
│   ├── products.js          # Product and inventory endpoints
│   ├── orders.js            # Order management endpoints
│   └── webhooks.js          # Webhook processing endpoints
├── /database
│   ├── schema.sql           # Database schema
│   └── seed.sql            # Sample data
├── /public
│   └── dashboard.html       # Analytics dashboard
├── /config
│   └── database.js          # Database connection
├── .env.example             # Environment variables template
├── docker-compose.yml       # PostgreSQL setup
└── package.json             # Dependencies
```

## API Endpoints

### Products
- `GET /api/products` - List all products with current stock
- `GET /api/products/:sku` - Get single product details
- `PATCH /api/products/:sku/inventory` - Update stock levels

### Orders
- `POST /api/orders` - Create new order
- `GET /api/orders/:id` - Get order details
- `PATCH /api/orders/:id/status` - Update order status

### Webhooks
- `POST /api/webhooks/fulfillment` - Process fulfillment updates

## Setup Instructions

1. **Start PostgreSQL:**
   ```bash
   docker-compose up -d
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment:**
   ```bash
   copy .env.example .env
   # Update .env with your database credentials if needed
   ```

4. **Create database tables:**
   ```bash
   # Wait 10-15 seconds for PostgreSQL to be ready
   psql -h localhost -U postgres -d collectibles_db -f database/schema.sql
   ```

5. **Seed with sample data:**
   ```bash
   psql -h localhost -U postgres -d collectibles_db -f database/seed.sql
   ```

6. **Run the application:**
   ```bash
   npm run dev
   ```

## Testing

Test your API endpoints:

```bash
# Check server health
curl http://localhost:3000/health

# List all products
curl http://localhost:3000/api/products

# Get low stock items
curl http://localhost:3000/api/products?low_stock=true

# Test webhook
curl -X POST http://localhost:3000/api/webhooks/fulfillment \
  -H "Content-Type: application/json" \
  -d '{"event": "inventory.restocked", "items": [{"sku": "FF-SONIC-001", "quantity_added": 10, "new_total": 460}]}'
```

## Dashboard

Access the analytics dashboard at: http://localhost:3000

The dashboard displays:
- Top 5 selling products
- Current low-stock alerts
- Order statistics (total, pending, shipped)
- Pre-order vs in-stock sales ratio

Data refreshes automatically every 30 seconds.

## Business Rules

- **Inventory Management**: Tracks available vs allocated stock separately
- **Pre-orders**: Can exceed current stock but are tracked separately
- **Low Stock Alerts**: Automatically flags products when stock < 10% of edition size
- **Order Processing**: Calculates totals including shipping, supports partial payments
- **Stock Validation**: Validates availability before confirming in-stock orders

## Environment Variables

- `PORT` - Server port (default: 3000)
- `DB_HOST` - Database host (default: localhost)
- `DB_PORT` - Database port (default: 5432)
- `DB_NAME` - Database name (default: collectibles_db)
- `DB_USER` - Database user (default: postgres)
- `DB_PASSWORD` - Database password (default: root)