-- Collectibles Management System Database Schema
-- PostgreSQL 14+

-- Enable the pgcrypto extension for gen_random_bytes
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create ULID generation function
CREATE OR REPLACE FUNCTION generate_ulid() RETURNS text AS $$
DECLARE
  timestamp_part bigint;
  random_part text;
BEGIN
  timestamp_part := floor(extract(epoch from clock_timestamp()) * 1000);
  random_part := encode(gen_random_bytes(10), 'base64');
  random_part := translate(random_part, '+/', '-_');
  random_part := substring(random_part from 1 for 16);
  RETURN lpad(to_hex(timestamp_part), 12, '0') || random_part;
END;
$$ LANGUAGE plpgsql;

-- Products table
CREATE TABLE IF NOT EXISTS products (
  id text PRIMARY KEY DEFAULT generate_ulid(),
  sku VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  edition_size INTEGER,
  price DECIMAL(10, 2) NOT NULL,
  weight DECIMAL(8, 3), -- in kg for shipping calculations
  category VARCHAR(100),
  manufacturer VARCHAR(100),
  release_date DATE,
  status VARCHAR(50) DEFAULT 'active', -- active, pre_order, discontinued, sold_out
  stock_available INTEGER DEFAULT 0,
  stock_allocated INTEGER DEFAULT 0,
  low_stock_threshold INTEGER DEFAULT 10,
  is_limited_edition BOOLEAN DEFAULT false,
  deposit_amount DECIMAL(10, 2), -- for pre-orders
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id text PRIMARY KEY DEFAULT generate_ulid(),
  order_number VARCHAR(50) UNIQUE NOT NULL,
  customer_email VARCHAR(255) NOT NULL,
  customer_name VARCHAR(255),
  shipping_address JSONB,
  billing_address JSONB,
  subtotal DECIMAL(10, 2) NOT NULL,
  shipping_cost DECIMAL(10, 2) DEFAULT 0,
  tax_amount DECIMAL(10, 2) DEFAULT 0,
  total_amount DECIMAL(10, 2) NOT NULL,
  amount_paid DECIMAL(10, 2) DEFAULT 0,
  currency VARCHAR(3) DEFAULT 'USD',
  status VARCHAR(50) DEFAULT 'pending', -- pending, processing, paid, shipped, delivered, cancelled, refunded
  payment_status VARCHAR(50) DEFAULT 'pending', -- pending, partial, paid, refunded
  order_type VARCHAR(50) DEFAULT 'regular', -- regular, pre_order
  notes TEXT,
  tracking_number VARCHAR(255),
  shipped_at TIMESTAMP,
  delivered_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
  id text PRIMARY KEY DEFAULT generate_ulid(),
  order_id text NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id text NOT NULL REFERENCES products(id),
  sku VARCHAR(50) NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10, 2) NOT NULL,
  total_price DECIMAL(10, 2) NOT NULL,
  is_pre_order BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory logs table for tracking stock movements
CREATE TABLE IF NOT EXISTS inventory_logs (
  id text PRIMARY KEY DEFAULT generate_ulid(),
  product_id text NOT NULL REFERENCES products(id),
  sku VARCHAR(50) NOT NULL,
  movement_type VARCHAR(50) NOT NULL, -- restock, sale, allocation, return, adjustment
  quantity INTEGER NOT NULL, -- positive for additions, negative for reductions
  balance_after INTEGER NOT NULL,
  reference_type VARCHAR(50), -- order, return, adjustment, restock
  reference_id VARCHAR(255), -- order_id or other reference
  notes TEXT,
  created_by VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Webhooks table for tracking webhook events
CREATE TABLE IF NOT EXISTS webhooks (
  id text PRIMARY KEY DEFAULT generate_ulid(),
  event_type VARCHAR(100) NOT NULL,
  payload JSONB NOT NULL,
  status VARCHAR(50) DEFAULT 'pending', -- pending, processed, failed
  processed_at TIMESTAMP,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Waitlist table for out-of-stock items
CREATE TABLE IF NOT EXISTS waitlist (
  id text PRIMARY KEY DEFAULT generate_ulid(),
  product_id text NOT NULL REFERENCES products(id),
  customer_email VARCHAR(255) NOT NULL,
  quantity_requested INTEGER DEFAULT 1,
  notified BOOLEAN DEFAULT false,
  notified_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(product_id, customer_email)
);

-- Create indexes for better performance
CREATE INDEX idx_products_sku ON products(sku) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_status ON products(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_stock ON products(stock_available) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_number ON orders(order_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_status ON orders(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_email ON orders(customer_email) WHERE deleted_at IS NULL;
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_inventory_logs_product ON inventory_logs(product_id);
CREATE INDEX idx_inventory_logs_created ON inventory_logs(created_at);
CREATE INDEX idx_webhooks_status ON webhooks(status);
CREATE INDEX idx_webhooks_created ON webhooks(created_at);
CREATE INDEX idx_waitlist_product ON waitlist(product_id) WHERE notified = false;

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON order_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_webhooks_updated_at BEFORE UPDATE ON webhooks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();