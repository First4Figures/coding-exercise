-- Sample Data for Collectibles Management System
-- Inspired by First4Figures and Figgyz product catalogs

-- Insert sample products (mix of in-stock, pre-order, and sold-out items)
INSERT INTO products (sku, name, description, edition_size, price, weight, category, manufacturer, release_date, status, stock_available, stock_allocated, low_stock_threshold, is_limited_edition, deposit_amount) VALUES
-- In-stock items
('FF-SONIC-001', 'Sonic the Hedgehog - Classic Edition', 'Premium 30cm statue featuring classic Sonic pose', 2500, 149.99, 2.5, 'Gaming', 'First4Figures', '2024-03-15', 'active', 450, 50, 25, true, NULL),
('FF-ZELDA-002', 'Link - Breath of the Wild', 'Detailed 35cm figure with LED Master Sword', 1500, 249.99, 3.2, 'Gaming', 'First4Figures', '2024-01-20', 'active', 120, 30, 15, true, NULL),
('FZ-GOKU-001', 'Super Saiyan Goku', 'Dynamic action pose with energy effects', 3000, 189.99, 2.8, 'Anime', 'Figgyz', '2024-02-10', 'active', 15, 5, 30, true, NULL),
('FF-MARIO-003', 'Super Mario - Fire Flower Edition', 'Mario with fire flower power-up effects', 2000, 179.99, 2.3, 'Gaming', 'First4Figures', '2023-12-01', 'active', 8, 2, 20, true, NULL),

-- Pre-order items
('FF-SAMUS-004', 'Samus Aran - Varia Suit', 'Metroid Prime figure with LED visor', 1000, 399.99, 4.5, 'Gaming', 'First4Figures', '2025-06-15', 'pre_order', 0, 650, 10, true, 100.00),
('FZ-LUFFY-002', 'Monkey D. Luffy - Gear 5', 'One Piece limited edition with special effects', 1500, 299.99, 3.5, 'Anime', 'Figgyz', '2025-04-30', 'pre_order', 0, 1200, 15, true, 75.00),
('FF-CRASH-005', 'Crash Bandicoot - TNT Edition', 'Includes TNT crate base with LED explosion', 2000, 199.99, 2.8, 'Gaming', 'First4Figures', '2025-05-20', 'pre_order', 0, 450, 20, true, 50.00),

-- Sold out items
('FF-CLOUD-006', 'Cloud Strife - Buster Sword Edition', 'Final Fantasy VII Remake exclusive', 500, 549.99, 5.0, 'Gaming', 'First4Figures', '2023-08-15', 'sold_out', 0, 0, 5, true, NULL),
('FZ-NARUTO-003', 'Naruto Uzumaki - Sage Mode', 'Limited edition with Rasengan effect', 1000, 259.99, 3.0, 'Anime', 'Figgyz', '2023-10-01', 'sold_out', 0, 0, 10, true, NULL),

-- Regular items (non-limited)
('FF-PIKACHU-007', 'Pikachu - Standard Edition', 'Classic Pikachu pose', NULL, 79.99, 1.5, 'Gaming', 'First4Figures', '2024-01-01', 'active', 850, 150, 100, false, NULL),
('FZ-DEKU-004', 'Izuku Midoriya', 'My Hero Academia standard figure', NULL, 99.99, 2.0, 'Anime', 'Figgyz', '2024-02-20', 'active', 320, 80, 50, false, NULL),

-- Low stock alert item
('FF-KRATOS-008', 'Kratos - God of War', 'Leviathan Axe with frost effects', 1200, 329.99, 4.0, 'Gaming', 'First4Figures', '2023-11-30', 'active', 3, 1, 12, true, NULL),

-- Upcoming pre-order
('FF-MASTERCHIEF-009', 'Master Chief - Halo Infinite', 'Fully armored with energy sword', 1500, 379.99, 4.2, 'Gaming', 'First4Figures', '2025-08-01', 'pre_order', 0, 0, 15, true, 100.00),
('FZ-TANJIRO-005', 'Tanjiro Kamado - Water Breathing', 'Demon Slayer with water effects', 2000, 219.99, 2.7, 'Anime', 'Figgyz', '2025-07-15', 'pre_order', 0, 0, 20, true, 60.00),

-- Exclusive variant
('FF-SONIC-001-EX', 'Sonic the Hedgehog - Exclusive Gold Edition', 'Limited gold variant of classic Sonic', 250, 299.99, 2.6, 'Gaming', 'First4Figures', '2024-04-01', 'active', 25, 10, 3, true, NULL);

-- Insert sample orders
INSERT INTO orders (order_number, customer_email, customer_name, shipping_address, billing_address, subtotal, shipping_cost, tax_amount, total_amount, amount_paid, status, payment_status, order_type, notes, tracking_number) VALUES
-- Completed orders
('ORD-20240101-001', 'john.doe@email.com', 'John Doe', 
 '{"street": "123 Main St", "city": "New York", "state": "NY", "zip": "10001", "country": "USA"}',
 '{"street": "123 Main St", "city": "New York", "state": "NY", "zip": "10001", "country": "USA"}',
 329.98, 15.00, 29.70, 374.68, 374.68, 'delivered', 'paid', 'regular', 'VIP customer', '1Z999AA10123456784'),

('ORD-20240102-002', 'jane.smith@email.com', 'Jane Smith',
 '{"street": "456 Oak Ave", "city": "Los Angeles", "state": "CA", "zip": "90001", "country": "USA"}',
 '{"street": "456 Oak Ave", "city": "Los Angeles", "state": "CA", "zip": "90001", "country": "USA"}',
 249.99, 20.00, 24.30, 294.29, 294.29, 'shipped', 'paid', 'regular', NULL, '1Z999BB20234567895'),

-- Pending orders
('ORD-20240115-003', 'mike.jones@email.com', 'Mike Jones',
 '{"street": "789 Pine Rd", "city": "Chicago", "state": "IL", "zip": "60601", "country": "USA"}',
 '{"street": "789 Pine Rd", "city": "Chicago", "state": "IL", "zip": "60601", "country": "USA"}',
 189.99, 12.00, 18.18, 220.17, 220.17, 'processing', 'paid', 'regular', 'Express shipping requested', NULL),

('ORD-20240120-004', 'sarah.wilson@email.com', 'Sarah Wilson',
 '{"street": "321 Elm St", "city": "Houston", "state": "TX", "zip": "77001", "country": "USA"}',
 '{"street": "321 Elm St", "city": "Houston", "state": "TX", "zip": "77001", "country": "USA"}',
 179.99, 15.00, 16.20, 211.19, 0, 'pending', 'pending', 'regular', NULL, NULL),

-- Pre-orders with deposits
('ORD-20240125-005', 'alex.chen@email.com', 'Alex Chen',
 '{"street": "555 Market St", "city": "San Francisco", "state": "CA", "zip": "94103", "country": "USA"}',
 '{"street": "555 Market St", "city": "San Francisco", "state": "CA", "zip": "94103", "country": "USA"}',
 399.99, 25.00, 38.25, 463.24, 100.00, 'pending', 'partial', 'pre_order', 'Pre-order for Samus figure', NULL),

('ORD-20240128-006', 'emma.davis@email.com', 'Emma Davis',
 '{"street": "999 Broadway", "city": "Seattle", "state": "WA", "zip": "98101", "country": "USA"}',
 '{"street": "999 Broadway", "city": "Seattle", "state": "WA", "zip": "98101", "country": "USA"}',
 299.99, 20.00, 28.80, 348.79, 75.00, 'pending', 'partial', 'pre_order', 'Pre-order for Luffy Gear 5', NULL),

-- Mixed order (regular + pre-order)
('ORD-20240130-007', 'ryan.martinez@email.com', 'Ryan Martinez',
 '{"street": "777 Sunset Blvd", "city": "Miami", "state": "FL", "zip": "33101", "country": "USA"}',
 '{"street": "777 Sunset Blvd", "city": "Miami", "state": "FL", "zip": "33101", "country": "USA"}',
 549.98, 30.00, 52.20, 632.18, 150.00, 'processing', 'partial', 'pre_order', 'Mixed order with pre-order item', NULL),

-- Cancelled order
('ORD-20240105-008', 'tom.brown@email.com', 'Tom Brown',
 '{"street": "222 Lake Dr", "city": "Orlando", "state": "FL", "zip": "32801", "country": "USA"}',
 '{"street": "222 Lake Dr", "city": "Orlando", "state": "FL", "zip": "32801", "country": "USA"}',
 329.99, 20.00, 31.50, 381.49, 0, 'cancelled', 'pending', 'regular', 'Customer cancelled - out of stock', NULL),

-- Large order
('ORD-20240110-009', 'lisa.white@email.com', 'Lisa White',
 '{"street": "888 Park Ave", "city": "Boston", "state": "MA", "zip": "02101", "country": "USA"}',
 '{"street": "888 Park Ave", "city": "Boston", "state": "MA", "zip": "02101", "country": "USA"}',
 849.95, 45.00, 80.55, 975.50, 975.50, 'shipped', 'paid', 'regular', 'Bulk order - collector', '1Z999CC30345678906'),

-- International order
('ORD-20240112-010', 'yuki.tanaka@email.jp', 'Yuki Tanaka',
 '{"street": "1-1-1 Shibuya", "city": "Tokyo", "state": "Tokyo", "zip": "150-0002", "country": "Japan"}',
 '{"street": "1-1-1 Shibuya", "city": "Tokyo", "state": "Tokyo", "zip": "150-0002", "country": "Japan"}',
 259.99, 65.00, 0, 324.99, 324.99, 'delivered', 'paid', 'regular', 'International shipping', 'EMS123456789JP');

-- Insert order items
INSERT INTO order_items (order_id, product_id, sku, product_name, quantity, unit_price, total_price, is_pre_order) VALUES
-- Order 1 items (2 different products)
((SELECT id FROM orders WHERE order_number = 'ORD-20240101-001'), 
 (SELECT id FROM products WHERE sku = 'FF-SONIC-001'), 'FF-SONIC-001', 'Sonic the Hedgehog - Classic Edition', 1, 149.99, 149.99, false),
((SELECT id FROM orders WHERE order_number = 'ORD-20240101-001'),
 (SELECT id FROM products WHERE sku = 'FF-MARIO-003'), 'FF-MARIO-003', 'Super Mario - Fire Flower Edition', 1, 179.99, 179.99, false),

-- Order 2 items
((SELECT id FROM orders WHERE order_number = 'ORD-20240102-002'),
 (SELECT id FROM products WHERE sku = 'FF-ZELDA-002'), 'FF-ZELDA-002', 'Link - Breath of the Wild', 1, 249.99, 249.99, false),

-- Order 3 items
((SELECT id FROM orders WHERE order_number = 'ORD-20240115-003'),
 (SELECT id FROM products WHERE sku = 'FZ-GOKU-001'), 'FZ-GOKU-001', 'Super Saiyan Goku', 1, 189.99, 189.99, false),

-- Order 4 items
((SELECT id FROM orders WHERE order_number = 'ORD-20240120-004'),
 (SELECT id FROM products WHERE sku = 'FF-MARIO-003'), 'FF-MARIO-003', 'Super Mario - Fire Flower Edition', 1, 179.99, 179.99, false),

-- Order 5 items (pre-order)
((SELECT id FROM orders WHERE order_number = 'ORD-20240125-005'),
 (SELECT id FROM products WHERE sku = 'FF-SAMUS-004'), 'FF-SAMUS-004', 'Samus Aran - Varia Suit', 1, 399.99, 399.99, true),

-- Order 6 items (pre-order)
((SELECT id FROM orders WHERE order_number = 'ORD-20240128-006'),
 (SELECT id FROM products WHERE sku = 'FZ-LUFFY-002'), 'FZ-LUFFY-002', 'Monkey D. Luffy - Gear 5', 1, 299.99, 299.99, true),

-- Order 7 items (mixed)
((SELECT id FROM orders WHERE order_number = 'ORD-20240130-007'),
 (SELECT id FROM products WHERE sku = 'FF-SONIC-001'), 'FF-SONIC-001', 'Sonic the Hedgehog - Classic Edition', 1, 149.99, 149.99, false),
((SELECT id FROM orders WHERE order_number = 'ORD-20240130-007'),
 (SELECT id FROM products WHERE sku = 'FF-SAMUS-004'), 'FF-SAMUS-004', 'Samus Aran - Varia Suit', 1, 399.99, 399.99, true),

-- Order 8 items (cancelled)
((SELECT id FROM orders WHERE order_number = 'ORD-20240105-008'),
 (SELECT id FROM products WHERE sku = 'FF-KRATOS-008'), 'FF-KRATOS-008', 'Kratos - God of War', 1, 329.99, 329.99, false),

-- Order 9 items (bulk)
((SELECT id FROM orders WHERE order_number = 'ORD-20240110-009'),
 (SELECT id FROM products WHERE sku = 'FF-SONIC-001'), 'FF-SONIC-001', 'Sonic the Hedgehog - Classic Edition', 2, 149.99, 299.98, false),
((SELECT id FROM orders WHERE order_number = 'ORD-20240110-009'),
 (SELECT id FROM products WHERE sku = 'FF-ZELDA-002'), 'FF-ZELDA-002', 'Link - Breath of the Wild', 1, 249.99, 249.99, false),
((SELECT id FROM orders WHERE order_number = 'ORD-20240110-009'),
 (SELECT id FROM products WHERE sku = 'FF-SONIC-001-EX'), 'FF-SONIC-001-EX', 'Sonic the Hedgehog - Exclusive Gold Edition', 1, 299.99, 299.99, false),

-- Order 10 items
((SELECT id FROM orders WHERE order_number = 'ORD-20240112-010'),
 (SELECT id FROM products WHERE sku = 'FZ-NARUTO-003'), 'FZ-NARUTO-003', 'Naruto Uzumaki - Sage Mode', 1, 259.99, 259.99, false);

-- Insert inventory logs
INSERT INTO inventory_logs (product_id, sku, movement_type, quantity, balance_after, reference_type, reference_id, notes) VALUES
-- Initial stock for FF-SONIC-001
((SELECT id FROM products WHERE sku = 'FF-SONIC-001'), 'FF-SONIC-001', 'restock', 500, 500, 'adjustment', NULL, 'Initial stock'),
((SELECT id FROM products WHERE sku = 'FF-SONIC-001'), 'FF-SONIC-001', 'sale', -1, 499, 'order', 'ORD-20240101-001', 'Sold to John Doe'),
((SELECT id FROM products WHERE sku = 'FF-SONIC-001'), 'FF-SONIC-001', 'sale', -2, 497, 'order', 'ORD-20240110-009', 'Bulk order'),

-- Stock movements for FF-ZELDA-002
((SELECT id FROM products WHERE sku = 'FF-ZELDA-002'), 'FF-ZELDA-002', 'restock', 200, 200, 'adjustment', NULL, 'Initial stock'),
((SELECT id FROM products WHERE sku = 'FF-ZELDA-002'), 'FF-ZELDA-002', 'sale', -1, 199, 'order', 'ORD-20240102-002', 'Sold to Jane Smith'),
((SELECT id FROM products WHERE sku = 'FF-ZELDA-002'), 'FF-ZELDA-002', 'sale', -1, 198, 'order', 'ORD-20240110-009', 'Bulk order'),
((SELECT id FROM products WHERE sku = 'FF-ZELDA-002'), 'FF-ZELDA-002', 'adjustment', -48, 150, 'adjustment', NULL, 'Inventory count correction'),

-- Low stock item
((SELECT id FROM products WHERE sku = 'FF-KRATOS-008'), 'FF-KRATOS-008', 'restock', 100, 100, 'adjustment', NULL, 'Initial stock'),
((SELECT id FROM products WHERE sku = 'FF-KRATOS-008'), 'FF-KRATOS-008', 'sale', -96, 4, 'adjustment', NULL, 'Multiple sales aggregated'),

-- Pre-order allocations
((SELECT id FROM products WHERE sku = 'FF-SAMUS-004'), 'FF-SAMUS-004', 'allocation', 650, 650, 'adjustment', NULL, 'Pre-order allocations'),
((SELECT id FROM products WHERE sku = 'FZ-LUFFY-002'), 'FZ-LUFFY-002', 'allocation', 1200, 1200, 'adjustment', NULL, 'Pre-order allocations');

-- Insert sample waitlist entries
INSERT INTO waitlist (product_id, customer_email, quantity_requested) VALUES
((SELECT id FROM products WHERE sku = 'FF-CLOUD-006'), 'collector1@email.com', 1),
((SELECT id FROM products WHERE sku = 'FF-CLOUD-006'), 'superfan@email.com', 1),
((SELECT id FROM products WHERE sku = 'FF-CLOUD-006'), 'gamer99@email.com', 2),
((SELECT id FROM products WHERE sku = 'FZ-NARUTO-003'), 'anime_lover@email.com', 1),
((SELECT id FROM products WHERE sku = 'FF-KRATOS-008'), 'waiting_customer@email.com', 1);

-- Insert sample webhook events
INSERT INTO webhooks (event_type, payload, status, processed_at) VALUES
('shipment.updated', 
 '{"event": "shipment.updated", "order_id": "ORD-20240101-001", "tracking_number": "1Z999AA10123456784", "status": "shipped", "items": [{"sku": "FF-SONIC-001", "quantity": 1}]}',
 'processed', '2024-01-03 10:30:00'),

('shipment.delivered',
 '{"event": "shipment.delivered", "order_id": "ORD-20240101-001", "tracking_number": "1Z999AA10123456784", "status": "delivered", "delivered_at": "2024-01-05 14:30:00"}',
 'processed', '2024-01-05 14:35:00'),

('payment.received',
 '{"event": "payment.received", "order_id": "ORD-20240125-005", "amount": 100.00, "payment_method": "credit_card", "transaction_id": "TXN-123456"}',
 'processed', '2024-01-25 09:15:00'),

('inventory.low_stock',
 '{"event": "inventory.low_stock", "sku": "FF-KRATOS-008", "current_stock": 3, "threshold": 12}',
 'pending', NULL),

('order.cancelled',
 '{"event": "order.cancelled", "order_id": "ORD-20240105-008", "reason": "out_of_stock", "refund_amount": 0}',
 'processed', '2024-01-05 11:00:00');