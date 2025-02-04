create database easymeal;
use easymeal;
-- user table
create table users(
user_id int auto_increment primary key,
email varchar(255) not null unique,
password_hash varchar(255) not null,
branch_id int,
role enum('user','seller','admin') not null default 'user'
);
ALTER TABLE users DROP COLUMN branch_id;
select * from users;
ALTER TABLE users ADD branch_id INT;
ALTER TABLE users ADD CONSTRAINT UNIQUE (branch_id);
select * from users;


-- category table

CREATE TABLE categories (

    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    branch_id INT NOT NULL,  
    image_path VARCHAR(255), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    FOREIGN KEY (branch_id) REFERENCES users(branch_id) 
    
);

select * from categories;


CREATE TABLE inventory (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    quantity VARCHAR(255) NOT NULL,
    branch_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES users(branch_id) 
);
select * from inventory;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
	product_price DECIMAL(10,2) NOT NULL,
    category_id INT NOT NULL,
    branch_id INT NOT NULL,  
    is_available BOOLEAN NOT NULL DEFAULT TRUE,  
    image_url VARCHAR(255),  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ,
    FOREIGN KEY (branch_id) REFERENCES users(branch_id) 
);

select * from products;

CREATE TABLE cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY, -- bill no
    user_id INT NOT NULL, -- id
    product_id INT NOT NULL,
    quantity INT DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY (user_id) REFERENCES users(user_id) ,  
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
);
select * from cart_items;



-- change
-- Step 1: Remove the branch_id from the users table
ALTER TABLE users DROP COLUMN branch_id;

-- Step 2: Remove the branch_id from the categories table
ALTER TABLE categories DROP COLUMN branch_id;

-- Step 3: Remove the branch_id from the inventory table
ALTER TABLE inventory DROP COLUMN branch_id;

-- Step 4: Remove the branch_id from the products table
ALTER TABLE products DROP COLUMN branch_id;

-- first
ALTER TABLE categories DROP FOREIGN KEY categories_ibfk_1;  -- Assuming the foreign key name is 'categories_ibfk_1'
ALTER TABLE inventory DROP FOREIGN KEY inventory_ibfk_1;    -- Assuming the foreign key name is 'inventory_ibfk_1'
ALTER TABLE products DROP FOREIGN KEY products_ibfk_2;      -- Assuming the foreign key name is 'products_ibfk_2'

-- Step 6: Verify the changes by selecting data from each table
select * from users;
select * from categories;
select * from inventory;
select * from products;
select * from cart_items;





-- adding  items

-- change
-- Step 1: Ensure both `branch_id` columns have the same data type (INT in this case)
-- You can change the data type in the products table to match the users table if necessary
ALTER TABLE products MODIFY COLUMN branch_id INT;

-- Step 2: Add an index to `branch_id` in the users table if it is not already indexed
CREATE INDEX idx_users_branch_id ON users(branch_id);

-- Step 3: Add the foreign key constraint to the products table again
ALTER TABLE products 
    ADD CONSTRAINT fk_products_branch_id FOREIGN KEY (branch_id) REFERENCES users(branch_id);

-- Step 4: Verify the changes by selecting data from each table
select * from users;
select * from products;

-- Add foreign key constraint to the `categories` table for `branch_id`
ALTER TABLE categories 
    ADD CONSTRAINT fk_categories_branch_id FOREIGN KEY (branch_id) REFERENCES users(branch_id);

-- Add foreign key constraint to the `inventory` table for `branch_id`
ALTER TABLE inventory 
    ADD CONSTRAINT fk_inventory_branch_id FOREIGN KEY (branch_id) REFERENCES users(branch_id);
select * from categories;
select * from inventory;



