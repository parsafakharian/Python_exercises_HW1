-- CREATE TABLE User  
CREATE TABLE Users(  
    user_id SERIAL PRIMARY KEY NOT NULL,  
    name TEXT NOT NULL,  
    phone_number BIGINT NOT NULL,  
    email VARCHAR(255) NOT NULL,  
    role VARCHAR(255) CHECK  
        (role IN('customer', 'admin')) NOT NULL  
);  

INSERT INTO Users (name, phone_number, email, role) VALUES  
( 'Emily White', 1234567890,'emily@example.com','customer' ),  
( 'David Black', 9876543210, 'david@example.com', 'customer' ),  
( 'Sophia Gray', 5432167890,'sophia@example.com', 'customer'),  
('Michael Green',3216549870,  'michael@example.com', 'customer'),  
( 'Olivia Red',  9871234560,'olivia@example.com', 'customer'),  
('Jane Smith', 9876543210, 'jane.smith@example.com', 'customer');  

SELECT * FROM Users;  

-- CREATE TABLE Artists  
CREATE TABLE Artists(  
    artist_id SERIAL NOT NULL,  
    user_id SERIAL NOT NULL,  
    name TEXT,  
    surname TEXT   
);  
ALTER TABLE Artists ADD PRIMARY KEY(artist_id);  
ALTER TABLE Artists ADD CONSTRAINT artists_user_id_foreign FOREIGN KEY(user_id) REFERENCES Users(user_id);  

INSERT INTO Artists (user_id, name, surname) VALUES  
(1, 'Artist One', 'Surname One'),  
(2, 'Artist Two', 'Surname Two'),  
(3, 'Artist Three', 'Surname Three');  

SELECT * FROM Artists;  

-- CREATE TABLE Albums  
CREATE TABLE Albums(  
    album_id SERIAL NOT NULL,  
    name VARCHAR(255) NOT NULL  
);  
ALTER TABLE Albums ADD PRIMARY KEY(album_id);  

INSERT INTO Albums (name) VALUES  
('Album One'),  
('Album Two'),  
('Album Three');  

SELECT * FROM Albums;  

-- CREATE TABLE Artist_Album  
CREATE TABLE Artist_Album(  
    artist_id SERIAL NOT NULL,  
    album_id SERIAL NOT NULL  
);  
CREATE INDEX artist_album_artist_id_index ON Artist_Album(artist_id);  
CREATE INDEX artist_album_album_id_index ON Artist_Album(album_id);  
ALTER TABLE Artist_Album ADD CONSTRAINT artist_album_album_id_foreign FOREIGN KEY(album_id) REFERENCES Albums(album_id);  
ALTER TABLE Artist_Album ADD CONSTRAINT artist_album_artist_id_foreign FOREIGN KEY(artist_id) REFERENCES Artists(artist_id);  

INSERT INTO Artist_Album (artist_id, album_id) VALUES  
(1, 1),  
(2, 2),  
(3, 3),  
(1, 2); -- Artist One also worked on Album Two  

SELECT * FROM Artist_Album;  

-- CREATE TABLE Products  
CREATE TABLE Products(  
    product_id SERIAL NOT NULL,  
    artist_id SERIAL NOT NULL,  
    album_id SERIAL NOT NULL,  
    genre TEXT NOT NULL,  
    file_size INTEGER NOT NULL,  
    file_typs VARCHAR(255) CHECK (file_typs IN('mp3', 'wav', 'flac')) NOT NULL,  
    music_typs VARCHAR(255) CHECK (music_typs IN('original', 'remix')) NOT NULL,  
    price INTEGER NOT NULL  
);  

ALTER TABLE Products ADD PRIMARY KEY(product_id);  
CREATE INDEX products_artist_id_index ON Products(artist_id);  
CREATE INDEX products_album_id_index ON Products(album_id);  
ALTER TABLE Products ADD CONSTRAINT products_artist_id_foreign FOREIGN KEY(artist_id) REFERENCES Artists(artist_id);  
ALTER TABLE Products ADD CONSTRAINT products_album_id_foreign FOREIGN KEY(album_id) REFERENCES Albums(album_id);  

INSERT INTO Products (artist_id, album_id, genre, file_size, file_typs, music_typs, price) VALUES  
(1, 3, 'Pop', 5000, 'mp3', 'original', 10),  
(2, 1, 'Rock', 7000, 'wav', 'remix', 15),  
(1, 2, 'Jazz', 6000, 'flac', 'original', 12),  
(2, 2, 'Pop', 8000, 'mp3', 'original', 11);  

SELECT * FROM Products;  

-- CREATE TABLE Orders  
CREATE TABLE Orders(  
    order_id SERIAL NOT NULL,  
    customer_id SERIAL NOT NULL,  
    order_date DATE NOT NULL,  
    total_amount BIGINT NOT NULL,  
    quantity BIGINT NOT NULL  
);  

ALTER TABLE Orders ADD PRIMARY KEY(order_id);  
CREATE INDEX orders_customer_id_index ON Orders(customer_id);  
ALTER TABLE Orders ADD CONSTRAINT orders_customer_id_foreign FOREIGN KEY(customer_id) REFERENCES Users(user_id);  

INSERT INTO Orders (customer_id, order_date, total_amount, quantity) VALUES  
(1, '2024-11-01', 10, 1),  
(2, '2024-10-08', 15, 2),  
(6, '2024-10-10', 12, 1);  

SELECT * FROM Orders;  

-- CREATE TABLE Order_Items  
CREATE TABLE Order_Items(  
    order_id SERIAL NOT NULL,  
    product_id SERIAL NOT NULL  
);  

CREATE INDEX order_items_order_id_index ON Order_Items(order_id);  
CREATE INDEX order_items_product_id_index ON Order_Items(product_id);  
ALTER TABLE  
    Order_Items ADD CONSTRAINT order_items_product_id_foreign FOREIGN KEY(product_id) REFERENCES Products(product_id);  

ALTER TABLE  
    Order_Items ADD CONSTRAINT order_items_order_id_foreign FOREIGN KEY(order_id) REFERENCES Orders(order_id);          

INSERT INTO Order_Items (order_id, product_id) VALUES  
(1, 1),  
(2, 2),  
(3, 3),  
(1, 4); -- Order 1 also includes Product 4  

SELECT * FROM Order_Items;



-- >>>>>>>>>>>>>>>  * 1 

SELECT Albums.album_id, Albums.Products,   
AVG(Products.Products_time) AS avg_Products_time, Products.price   
FROM Albums  
INNER JOIN Products ON Albums.album_id = Products.album_id  
GROUP BY Albums.album_id, Albums.Products, Products.price  
ORDER BY price;

-- %%%
alter table Albums
add Products integer;
update Albums
-- set Products=5 where album_id=1;
-- set Products=4 where album_id=2;
-- set Products=5 where album_id=3;

SELECT * FROM Albums

-- %%%%

alter table Products
add Products_time interval;
update Products
set Products_time= '5 minutes' where product_id=5; 

SELECT * FROM Products


-- >>>>>>>>>>>>>> * 2

SELECT Users.user_id, Orders.total_amount, Products.product_id   
FROM Users  
INNER JOIN Orders ON Users.user_id = Orders.customer_id  
INNER JOIN Order_Items ON Orders.order_id = Order_Items.order_id  
INNER JOIN Products ON Order_Items.product_id = Products.product_id  
WHERE Orders.total_amount > 0.6 * (SELECT MAX(total_amount) FROM Orders);


-- >>>>>>>>>>>>>>> * 3


SELECT a.name, a.surname, COUNT(p.product_id) AS rock_product_count  
FROM Artists a  
LEFT JOIN Products p ON a.artist_id = p.artist_id AND p.genre = 'Rock'  
GROUP BY a.artist_id, a.name, a.surname  
HAVING COUNT(p.product_id) >= 1;



-- >>>>>>>>>>>>>>>>>> * 4

SELECT u.name, MAX(o.order_date) AS last_order_date  
FROM Users u  
LEFT JOIN Orders o ON u.user_id = o.customer_id  
GROUP BY u.user_id, u.name  
ORDER BY last_order_date DESC;


--  >>>>>>>>>>>>>>> * 5

SELECT a.name AS album_name,   
       SUM(o.total_amount) AS total_amount  
FROM Albums a  
INNER JOIN Products p ON a.album_id = p.album_id  
INNER JOIN Order_Items oi ON p.product_id = oi.product_id  
INNER JOIN Orders o ON oi.order_id = o.order_id  
GROUP BY a.album_id, a.name  
HAVING SUM(o.total_amount) <= 15;  

--  >>>>>>>>>>>>>>> * 6

WITH ProductSales AS (  
    SELECT p.product_id,  
           p.genre,  
           SUM(o.total_amount) AS total_product_sales  
    FROM Products p  
    JOIN Order_Items oi ON p.product_id = oi.product_id  
    JOIN Orders o ON oi.order_id = o.order_id  
    GROUP BY p.product_id, p.genre  
),  

GenreSales AS (  
    SELECT genre,  
           SUM(total_product_sales) AS total_genre_sales  
    FROM ProductSales  
    GROUP BY genre  
)  

SELECT ps.product_id,   
       ps.total_product_sales,   
       gs.total_genre_sales  
FROM ProductSales ps  
JOIN GenreSales gs ON ps.genre = gs.genre  
WHERE ps.total_product_sales < 0.002 * gs.total_genre_sales;


-- ===================================================================================================================

CREATE VIEW GenreSales AS
SELECT 
    p.genre,
    SUM(o.total_amount) AS total_genre_sales
FROM 
    Products p
JOIN 
    Order_Items oi ON p.product_id = oi.product_id
JOIN 
    Orders o ON oi.order_id = o.order_id
GROUP BY 
    p.genre;



UPDATE Products p
SET price = price * 0.5
FROM GenreSales gs
JOIN Order_Items oi ON p.product_id = oi.product_id
JOIN Orders o ON oi.order_id = o.order_id
WHERE 
    p.genre = gs.genre
GROUP BY 
    p.product_id, gs.total_genre_sales
HAVING 
    SUM(o.total_amount) < 0.002 * gs.total_genre_sales;
