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


