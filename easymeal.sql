create database easymeal;
use easymeal;
create table users(
user_id int auto_increment primary key,
email varchar(255) not null unique,
password_hash varchar(255) not null,
branch_id int,
role enum('user','seller','admin') not null default 'user'
);
select * from users;
INSERT INTO users (email, password_hash, branch_id, role) 
VALUES ('user@example.com', '11111', 1, 'user');
ALTER TABLE users ADD branch_name VARCHAR(255) NOT NULL;
ALTER TABLE users
ADD CONSTRAINT unique_branch_id UNIQUE (branch_id);




CREATE TABLE categories (

    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    branch_id INT NOT NULL,  
    image_path VARCHAR(255), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    FOREIGN KEY (branch_id) REFERENCES users(branch_id) 
    
);

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

create table inventory(
inventory_id int auto_increment primary key,
item_name varchar(255) not null,
quantity decimal(10,2) not null default 0,
restock int default 0,
last_date timestamp default current_timestamp
);





