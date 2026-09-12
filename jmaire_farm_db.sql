-- ============================================================
-- J'Maire Farm Database
-- Import this file via phpMyAdmin: Import tab -> Choose File -> Go
-- (Or paste into the SQL tab after creating an empty database)
-- ============================================================

CREATE DATABASE IF NOT EXISTS jmaire_farm
  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE jmaire_farm;

-- ------------------------------------------------------------
-- 1. Top-level buckets: Food / Rooms & Cottages / Activities
-- ------------------------------------------------------------
CREATE TABLE offering_types (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. Sub-groups within each type (Breakfast, Seafood, Overnight Room, etc.)
-- ------------------------------------------------------------
CREATE TABLE categories (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    offering_type_id INT NOT NULL,
    name             VARCHAR(100) NOT NULL,
    FOREIGN KEY (offering_type_id) REFERENCES offering_types(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. The actual named item
-- ------------------------------------------------------------
CREATE TABLE offerings (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name        VARCHAR(150) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. Price(s) for each offering. One offering can have several
--    rows here (e.g. Crispy Pata M/L, Entrance Adult/Kids).
--    price = NULL means "no listed price" (e.g. free activities).
-- ------------------------------------------------------------
CREATE TABLE price_variants (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    offering_id   INT NOT NULL,
    variant_label VARCHAR(100) NOT NULL DEFAULT 'default',
    price         DECIMAL(10,2) DEFAULT NULL,
    notes         VARCHAR(255) DEFAULT NULL,
    last_verified DATE DEFAULT NULL,
    FOREIGN KEY (offering_id) REFERENCES offerings(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. Free-text inclusions/bundles (e.g. Overnight Room includes
--    Entrance + Swimming + Breakfast)
-- ------------------------------------------------------------
CREATE TABLE inclusions (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    offering_id INT NOT NULL,
    inclusion_text VARCHAR(255) NOT NULL,
    FOREIGN KEY (offering_id) REFERENCES offerings(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;


-- ============================================================
-- SEED DATA
-- ============================================================

-- 1. Offering types
INSERT INTO offering_types (name) VALUES
('Food'), ('Rooms & Cottages'), ('Activities');

-- 2. Categories
INSERT INTO categories (offering_type_id, name) VALUES
(1,'Breakfast (Filipino)'),
(1,'Breakfast (American)'),
(1,'Soup'),
(1,'Snacks'),
(1,'Rice'),
(1,'Noodles'),
(1,'Vegetables'),
(1,'Chicken'),
(1,'Beef/Pork'),
(1,'Seafood'),
(1,'Dessert'),
(1,'Drinks - Soda'),
(1,'Drinks - Shake'),
(1,'Drinks - Pitcher'),
(2,'Entrance'),
(2,'Swimming'),
(2,'Daytime Cottage'),
(2,'Overnight Room'),
(3,'Activity');

-- ------------------------------------------------------------
-- FOOD: Breakfast (Filipino) -- category_id 1
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(1,'Tapsilog'),(1,'Tocisilog'),(1,'Hotsilog'),
(1,'Boneless Bangus w/ Rice'),(1,'Sisiglog'),(1,'Squidsilog');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Tapsilog'), 220.00),
((SELECT id FROM offerings WHERE name='Tocisilog'), 210.00),
((SELECT id FROM offerings WHERE name='Hotsilog'), 185.00),
((SELECT id FROM offerings WHERE name='Boneless Bangus w/ Rice'), 225.00),
((SELECT id FROM offerings WHERE name='Sisiglog'), 225.00),
((SELECT id FROM offerings WHERE name='Squidsilog'), 235.00);

-- ------------------------------------------------------------
-- FOOD: Breakfast (American) -- category_id 2
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(2,'Pancake'),(2,'Toast & Omelette'),(2,'Toast & Sausage');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Pancake'), 155.00),
((SELECT id FROM offerings WHERE name='Toast & Omelette'), 155.00),
((SELECT id FROM offerings WHERE name='Toast & Sausage'), 155.00);

-- ------------------------------------------------------------
-- FOOD: Soup -- category_id 3
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(3,'Sinigang Baboy'),(3,'Sinigang Boneless Bangus'),
(3,'Sinigang Pasayan'),(3,'Bulalo'),(3,'Patatim');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Sinigang Baboy'), 315.00),
((SELECT id FROM offerings WHERE name='Sinigang Boneless Bangus'), 325.00),
((SELECT id FROM offerings WHERE name='Sinigang Pasayan'), 335.00),
((SELECT id FROM offerings WHERE name='Bulalo'), 585.00),
((SELECT id FROM offerings WHERE name='Patatim'), 495.00);

-- ------------------------------------------------------------
-- FOOD: Snacks -- category_id 4  (Pizza has two variants)
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name, description) VALUES
(4,'Pizza','Pepperoni, Hawaiian, or Triple Cheese'),
(4,'Carbonara',NULL),(4,'Spaghetti',NULL),(4,'French Fries',NULL),
(4,'Overload Fried',NULL),(4,'Nachos',NULL),(4,'Fish & Chips',NULL);

INSERT INTO price_variants (offering_id, variant_label, price) VALUES
((SELECT id FROM offerings WHERE name='Pizza'), 'Medium', 195.00),
((SELECT id FROM offerings WHERE name='Pizza'), 'Large', 315.00),
((SELECT id FROM offerings WHERE name='Carbonara'), 'default', 270.00),
((SELECT id FROM offerings WHERE name='Spaghetti'), 'default', 240.00),
((SELECT id FROM offerings WHERE name='French Fries'), 'default', 120.00),
((SELECT id FROM offerings WHERE name='Overload Fried'), 'default', 150.00),
((SELECT id FROM offerings WHERE name='Nachos'), 'default', 125.00),
((SELECT id FROM offerings WHERE name='Fish & Chips'), 'default', 235.00);

-- ------------------------------------------------------------
-- FOOD: Rice -- category_id 5
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(5,'Plain Rice'),(5,'Garlic Rice');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Plain Rice'), 85.00),
((SELECT id FROM offerings WHERE name='Garlic Rice'), 100.00);

-- ------------------------------------------------------------
-- FOOD: Noodles -- category_id 6
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(6,'Sotanghon Guisado'),(6,'Canton Guisado');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Sotanghon Guisado'), 249.00),
((SELECT id FROM offerings WHERE name='Canton Guisado'), 249.00);

-- ------------------------------------------------------------
-- FOOD: Vegetables -- category_id 7
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(7,'Chopsuey'),(7,'Sizzling Kangkong'),(7,'Kangkong Chips'),(7,'Onion Rings');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Chopsuey'), 219.00),
((SELECT id FROM offerings WHERE name='Sizzling Kangkong'), 125.00),
((SELECT id FROM offerings WHERE name='Kangkong Chips'), 135.00),
((SELECT id FROM offerings WHERE name='Onion Rings'), 185.00);

-- ------------------------------------------------------------
-- FOOD: Chicken -- category_id 8
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(8,'Garlic Chicken Parmesan'),(8,'Buffalo Wings'),(8,'Buttered Chicken'),
(8,'Honey Garlic Chicken'),(8,'Sweet & Sour Chicken');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Garlic Chicken Parmesan'), 229.00),
((SELECT id FROM offerings WHERE name='Buffalo Wings'), 219.00),
((SELECT id FROM offerings WHERE name='Buttered Chicken'), 219.00),
((SELECT id FROM offerings WHERE name='Honey Garlic Chicken'), 219.00),
((SELECT id FROM offerings WHERE name='Sweet & Sour Chicken'), 309.00);

-- ------------------------------------------------------------
-- FOOD: Beef/Pork -- category_id 9 (Crispy Pata has two variants)
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(9,'Beef Broccoli'),(9,'Sweet & Sour Pork'),(9,'Sizzling Sisig'),(9,'Crispy Pata');

INSERT INTO price_variants (offering_id, variant_label, price) VALUES
((SELECT id FROM offerings WHERE name='Beef Broccoli'), 'default', 369.00),
((SELECT id FROM offerings WHERE name='Sweet & Sour Pork'), 'default', 329.00),
((SELECT id FROM offerings WHERE name='Sizzling Sisig'), 'default', 225.00),
((SELECT id FROM offerings WHERE name='Crispy Pata'), 'Medium', 585.00),
((SELECT id FROM offerings WHERE name='Crispy Pata'), 'Large', 685.00);

-- ------------------------------------------------------------
-- FOOD: Seafood -- category_id 10
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(10,'Boneless Bangus'),(10,'Honey Garlic Bangus'),(10,'Buttered Garlic Shrimp'),
(10,'Calamares'),(10,'Shrimp Tempura'),(10,'Sweet & Sour Fish Fillet');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Boneless Bangus' AND category_id=10), 265.00),
((SELECT id FROM offerings WHERE name='Honey Garlic Bangus'), 275.00),
((SELECT id FROM offerings WHERE name='Buttered Garlic Shrimp'), 315.00),
((SELECT id FROM offerings WHERE name='Calamares'), 255.00),
((SELECT id FROM offerings WHERE name='Shrimp Tempura'), 285.00),
((SELECT id FROM offerings WHERE name='Sweet & Sour Fish Fillet'), 295.00);

-- ------------------------------------------------------------
-- FOOD: Dessert -- category_id 11
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(11,'Letche Flan'),(11,'Buko Halo-Halo'),(11,'Mango Pana Cotta');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Letche Flan'), 125.00),
((SELECT id FROM offerings WHERE name='Buko Halo-Halo'), 125.00),
((SELECT id FROM offerings WHERE name='Mango Pana Cotta'), 139.00);

-- ------------------------------------------------------------
-- FOOD: Drinks - Soda (1.5L) -- category_id 12
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name, description) VALUES
(12,'Coke','1.5L'),(12,'Sprite','1.5L'),(12,'Royal','1.5L');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Coke'), 115.00),
((SELECT id FROM offerings WHERE name='Sprite'), 115.00),
((SELECT id FROM offerings WHERE name='Royal'), 115.00);

-- ------------------------------------------------------------
-- FOOD: Drinks - Shake -- category_id 13
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(13,'Mango Shake'),(13,'Watermelon Shake'),(13,'Buko Shake'),
(13,'Vanilla Shake'),(13,'Melon Shake'),(13,'Taro Shake'),
(13,'Chocolate Shake'),(13,'Okinawa Shake'),(13,'Wintermelon Shake'),
(13,'Matcha Shake'),(13,'Papaya Shake');

INSERT INTO price_variants (offering_id, price)
SELECT id, 110.00 FROM offerings WHERE category_id = 13;

-- ------------------------------------------------------------
-- FOOD: Drinks - Pitcher -- category_id 14
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(14,'Iced Tea'),(14,'Cucumber Lemonade');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Iced Tea'), 125.00),
((SELECT id FROM offerings WHERE name='Cucumber Lemonade'), 125.00);


-- ------------------------------------------------------------
-- ROOMS & COTTAGES: Entrance -- category_id 15
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES (15,'Entrance Fee');

INSERT INTO price_variants (offering_id, variant_label, price) VALUES
((SELECT id FROM offerings WHERE name='Entrance Fee'), 'Adult', 50.00),
((SELECT id FROM offerings WHERE name='Entrance Fee'), 'Kids', 30.00);

-- ------------------------------------------------------------
-- ROOMS & COTTAGES: Swimming -- category_id 16
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES (16,'Swimming Fee');

INSERT INTO price_variants (offering_id, variant_label, price) VALUES
((SELECT id FROM offerings WHERE name='Swimming Fee'), 'Adult', 80.00),
((SELECT id FROM offerings WHERE name='Swimming Fee'), 'Kids', 50.00);

-- ------------------------------------------------------------
-- ROOMS & COTTAGES: Daytime Cottage -- category_id 17
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name, description) VALUES
(17,'Open Cottage','9-12 pax'),
(17,'Open Cottage (Large)','12-15 pax'),
(17,'Big Cottage','15-20 pax'),
(17,'Kalesa Table & Chairs','3-6 pax'),
(17,'Cottage with Room','3-6 pax');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Open Cottage'), 700.00),
((SELECT id FROM offerings WHERE name='Open Cottage (Large)'), 900.00),
((SELECT id FROM offerings WHERE name='Big Cottage'), 1500.00),
((SELECT id FROM offerings WHERE name='Kalesa Table & Chairs'), 350.00),
((SELECT id FROM offerings WHERE name='Cottage with Room'), 700.00);

INSERT INTO inclusions (offering_id, inclusion_text) VALUES
((SELECT id FROM offerings WHERE name='Cottage with Room'), '10 minutes free kayak for 2');

-- ------------------------------------------------------------
-- ROOMS & COTTAGES: Overnight Room -- category_id 18
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name, description) VALUES
(18,'Deluxe Room','2 pax'),
(18,'Deluxe Room (4 pax)','4 pax'),
(18,'Family Room','4 pax'),
(18,'Barkada Room','6 pax');

INSERT INTO price_variants (offering_id, price) VALUES
((SELECT id FROM offerings WHERE name='Deluxe Room'), 2000.00),
((SELECT id FROM offerings WHERE name='Deluxe Room (4 pax)'), 4000.00),
((SELECT id FROM offerings WHERE name='Family Room'), 3000.00),
((SELECT id FROM offerings WHERE name='Barkada Room'), 4000.00);

INSERT INTO inclusions (offering_id, inclusion_text)
SELECT id, 'Includes Entrance, Swimming, and Breakfast'
FROM offerings WHERE category_id = 18;

-- ------------------------------------------------------------
-- ACTIVITIES -- category_id 19  (no listed prices)
-- ------------------------------------------------------------
INSERT INTO offerings (category_id, name) VALUES
(19,'Kayak'),(19,'Billiards'),(19,'Fishing'),(19,'Bonfire'),
(19,'Camping'),(19,'KTV'),(19,'Volleyball/Badminton Court'),
(19,'Children''s Play House');

-- price_variants intentionally left empty for activities (no price listed)

-- ============================================================
-- Handy view: full menu with prices, one row per variant
-- ============================================================
CREATE OR REPLACE VIEW v_full_menu AS
SELECT
    ot.name        AS offering_type,
    c.name         AS category,
    o.name         AS item,
    o.description  AS item_description,
    pv.variant_label,
    pv.price,
    pv.notes
FROM offerings o
JOIN categories c       ON o.category_id = c.id
JOIN offering_types ot  ON c.offering_type_id = ot.id
LEFT JOIN price_variants pv ON pv.offering_id = o.id
ORDER BY ot.id, c.id, o.name, pv.variant_label;

-- Example query once imported:
-- SELECT * FROM v_full_menu WHERE offering_type = 'Food' AND category = 'Chicken';
