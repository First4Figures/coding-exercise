# Full-Stack Developer Coding Exercise - Collectibles Management System

Welcome! In this exercise, you'll build a backend API and simple dashboard for managing a collectibles/figurines store inventory system. This exercise simulates real-world challenges in e-commerce operations, inspired by businesses like First4Figures and Figgyz.

---

## 🎯 Objective

Build a Node.js API with PostgreSQL that handles:
- Inventory management for limited edition collectibles
- Pre-order and payment tracking
- Automated webhook processing for fulfillment updates
- A simple analytics dashboard

**Time Estimate**: 60-75 minutes (allow extra time for setup and troubleshooting)

---

## 📋 Requirements

### Part 1: Database & API Setup (15-20 minutes)

1. **Set up PostgreSQL Database**
   - Use the provided `docker-compose.yml` to start PostgreSQL
   - Create tables for: `products`, `orders`, `order_items`, `inventory_logs`, `webhooks`
   - Use the schema provided in `database/schema.sql`

2. **Build REST API Endpoints**
   
   Create the following endpoints:
   
   **Products/Inventory:**
   - `GET /api/products` - List all products with current stock
   - `GET /api/products/:sku` - Get single product details
   - `PATCH /api/products/:sku/inventory` - Update stock levels
   
   **Orders:**
   - `POST /api/orders` - Create new order
   - `GET /api/orders/:id` - Get order details
   - `PATCH /api/orders/:id/status` - Update order status

### Part 2: Business Logic Implementation (20-25 minutes)

Implement these business rules:

1. **Inventory Management:**
   - Track available vs allocated stock
   - Pre-orders can exceed current stock but track separately
   - Automatically flag products when stock < 10% of edition size

2. **Order Processing:**
   - Calculate order totals including shipping
   - Support partial payments (deposits for pre-orders)
   - Validate stock availability before confirming orders

### Part 3: Webhook Automation (15-20 minutes)

1. **Webhook Handler:**
   - `POST /api/webhooks/fulfillment` - Receive shipping updates
   
   When a fulfillment webhook is received:
   - Update order status
   - Adjust inventory counts
   - Log the webhook for debugging
   - Return appropriate response codes

2. **Sample Webhook Payload:**
   ```json
   {
     "event": "shipment.updated",
     "order_id": "ORD-001",
     "tracking_number": "1Z999AA10123456784",
     "status": "shipped",
     "items": [
       {"sku": "FF-SONIC-001", "quantity": 1}
     ]
   }
   ```

   **Note:** Some events like `inventory.restocked` may not require an `order_id`.

### Part 4: Analytics Dashboard (10-15 minutes)

Create a simple HTML page (`public/dashboard.html`) that:

1. Fetches and displays:
   - Top 5 selling products
   - Current low-stock alerts
   - Order statistics (total, pending, shipped)
   - Pre-order vs in-stock sales ratio

2. Updates data every 30 seconds

3. Basic styling (keep it simple, functionality over aesthetics)

---

## 🌟 Bonus Points (Optional Enhancements)

**Performance Optimizations:**
- [ ] Implement caching for frequently accessed product data
- [ ] Add database indexes on commonly queried fields
- [ ] Batch process webhook events
- [ ] Use connection pooling for database

**Advanced Features:**
- [ ] Add pagination to GET endpoints (limit/offset)
- [ ] Implement rate limiting (e.g., 100 requests/minute)
- [ ] Create waitlist functionality when items are out of stock
- [ ] Add currency conversion (USD/EUR/GBP)
- [ ] Generate CSV export for orders
- [ ] Implement soft deletes with `deleted_at` timestamps
- [ ] Add search/filter capabilities to product listing

**Code Quality:**
- [ ] Input validation using Joi or similar
- [ ] Custom error classes with proper error codes
- [ ] Environment variables for all configuration
- [ ] Basic unit tests for critical functions
- [ ] API documentation (comments or README)
- [ ] Logging for important operations
- [ ] Graceful error handling with meaningful messages

**Data Integrity:**
- [ ] Use database transactions for multi-table operations
- [ ] Implement optimistic locking for inventory updates
- [ ] Add data validation constraints at database level

---

## 🚀 Getting Started

1. **Clone and Setup:**
   ```bash
   # Start PostgreSQL
   docker-compose up -d
   
   # Install dependencies (if using Node.js)
   npm init -y
   npm install express@4 pg dotenv cors
   npm install -D nodemon
   
   # Wait for database to be ready (10-15 seconds)
   sleep 10
   
   # Create database tables
   psql -h localhost -U postgres -d collectibles_db -f database/schema.sql
   ```

2. **Environment Variables:**
   Copy `.env.example` to `.env` and update as needed

3. **Run the application:**
   ```bash
   npm run dev  # or node server.js
   ```

4. **Test your API:**
   Use Postman, curl, or the provided test commands below

---

## 🔧 Common Issues & Troubleshooting

**Database Connection Issues:**
- If you get "database does not exist" errors, make sure PostgreSQL container is fully started
- Wait 10-15 seconds after `docker-compose up -d` before running schema commands
- Check container status: `docker ps` - both db and redis should show "healthy" status

**Express Version Issues:**
- We specify `express@4` to avoid compatibility issues with Express 5
- If you see "Missing parameter name" errors, ensure you're using Express 4

**ULID Generation Errors:**
- If you see "gen_random_bytes function does not exist", the pgcrypto extension needs to be enabled
- This should be handled automatically by the schema, but you can manually run:
  ```bash
  docker exec coding-exercise-db-1 psql -U postgres -d collectibles_db -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
  ```

**Port Already in Use:**
- If port 3000 is busy, change `PORT=3000` in your `.env` file
- PostgreSQL port 5432 conflicts can be resolved by stopping other PostgreSQL instances

---

## 🧪 Testing Your Solution

Test your API endpoints with these commands:

```bash
# Check server health
curl http://localhost:3000/health

# List all products
curl http://localhost:3000/api/products

# Get low stock items
curl http://localhost:3000/api/products?low_stock=true

# Get single product
curl http://localhost:3000/api/products/FF-SONIC-001

# Test webhook (inventory restock - no order_id needed)
curl -X POST http://localhost:3000/api/webhooks/fulfillment \
  -H "Content-Type: application/json" \
  -d '{"event": "inventory.restocked", "items": [{"sku": "FF-SONIC-001", "quantity_added": 10, "new_total": 460}]}'

# View dashboard
open http://localhost:3000
```

---

## 📁 Expected Project Structure

```
/
├── server.js                 # Main application file
├── /routes                   # API route handlers
│   ├── products.js
│   ├── orders.js
│   └── webhooks.js
├── /database
│   ├── schema.sql           # Database schema
│   └── seed.sql            # Sample data
├── /public
│   └── dashboard.html       # Analytics dashboard
├── .env.example            # Environment variables template
├── docker-compose.yml      # PostgreSQL setup
└── package.json           # Dependencies
```

---

## 📊 Sample Data

Your database should include:
- **Products**: Mix of in-stock items, pre-orders, and sold-out collectibles
  - Examples: Limited edition figurines, statues, exclusive variants
  - Include: SKU, name, edition_size, price, weight, status
- **Orders**: Various order states (pending, paid, shipped, delivered)
- **Inventory movements**: Stock adjustments, allocations, returns

---

## 📤 Submission Instructions

1. **Fork this repository** to your own GitHub account
2. **Clone your fork** and work on your solution
3. **Commit your changes** to your fork
4. **Send us the link** to your forked repository when complete

### Your submission should include:
- Working API code with all endpoints implemented
- Any additional files needed to run your solution
- A `README.md` in your repository with:
  - Clear setup and run instructions
  - Any assumptions or decisions you made
  - List of completed bonus features (if any)
  - Any known issues or what you'd improve with more time

### Important Notes:
- Do NOT create a Pull Request to this repository
- Make sure your repository is public so we can review it
- Test your setup instructions on a clean environment if possible

---

## ❓ Questions?

Feel free to make reasonable assumptions about requirements. Document any assumptions in your README. 

If you have any questions about the exercise requirements, please reach out to your hiring contact.

Good luck! 🚀