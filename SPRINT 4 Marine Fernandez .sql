#NIVEL 1 
#Descarga los archivos CSV, estudiales y diseña una base de datos con un esquema de estrella que contenga, al menos 4 tablas de las que puedas realizar las siguientes consultas:

CREATE DATABASE sales; 

CREATE TABLE companies (
	company_id VARCHAR(15),
    company_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(100)
 );
DESCRIBE companies;


CREATE TABLE transactions (
    id VARCHAR(100),
    card_id  VARCHAR(255),
    business_id VARCHAR(255),
    timestamp TIMESTAMP,
    amount DECIMAL (10,2),
    declined TINYINT(1),
    product_ids INT,
    user_id INT,
    lat FLOAT,
    longitude FLOAT
 ) ;
 
 CREATE TABLE users (
    id INT,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    birth_date VARCHAR(255),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(100),
    address VARCHAR(100)
 );
 
 CREATE TABLE credit_cards (
    id VARCHAR(30),
    user_id INT,
    iban VARCHAR(50) ,
    pan VARCHAR(50),
    pin VARCHAR(6),
    cvv INT,
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(255)
 ); 

#Para determinar dónde almacenar y desde dónde cargar los archivos CSV en MySQL, fue necesario consultar las rutas de archivos accesibles por el servidor. 
#Esto se hizo utilizando el siguiente comando:

SHOW VARIABLES LIKE 'secure_file_priv';

USE sales;
LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.0//Uploads//transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#verificación
 SELECT*
 FROM transactions;
 
LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.0//Uploads//companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#verificación
SELECT*
FROM companies; 

LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.0//Uploads//credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#verificación
SELECT*
FROM credit_cards; 

LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.0//Uploads//european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.0//Uploads//american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#verificación
SELECT*
FROM users; 

#Procedemos a realizar los cambios en cada tabla, tipo de dato en algunos caso y configuracion de los PK 

#- CAMBIOS TABLA TRANSACTIONS
#configuracion de PK 
ALTER TABLE transactions
ADD CONSTRAINT Pk_transactions PRIMARY KEY (id); 

DESCRIBE transactions;

#CAMBIOS TABLA USERS 
ALTER TABLE users 
ADD CONSTRAINT Pk_users PRIMARY KEY (id);

#Cambiamos el data type de la columna birth_date 
SET SQL_SAFE_UPDATES = 0; #Se tiene que configurar el safe update mode para poder usar update sin una clausula WHERE
UPDATE users
SET birth_date = STR_TO_DATE(birth_date, "%b %d, %Y"); 

#verificacion 
SELECT*
FROM users; 

DESCRIBE users;

#CAMBIOS TABLA CREDIT_CARD 

ALTER TABLE credit_cards
ADD CONSTRAINT Pk_credit_cards PRIMARY KEY (id); 

#Cambiamos el formato de la columna expiring_date
UPDATE credit_cards
SET expiring_date = STR_TO_DATE (expiring_date, "%m/%d/%y"); 

#verificaciones
SELECT*
FROM credit_cards;

DESCRIBE credit_cards;

#CAMBIOS TABLA COMPANIES

ALTER TABLE companies
ADD CONSTRAINT Pk_companies PRIMARY KEY (company_id);

#verificacion
DESCRIBE companies;

#Procedemos a relacionar las tablas entre sí : configuración de foreign keys en la tabla transactions y relacionamos las tablas credit_cards y users 
ALTER TABLE transactions 
ADD CONSTRAINT Fk_companies_transactions
FOREIGN KEY (business_id) REFERENCES companies(company_id); 

ALTER TABLE transactions 
ADD CONSTRAINT Fk_users_transactions
FOREIGN KEY (user_id) REFERENCES users(id); 

ALTER TABLE transactions 
ADD CONSTRAINT Fk_credit_cards_transactions
FOREIGN KEY (card_id) REFERENCES credit_cards(id); 

ALTER TABLE credit_cards
ADD CONSTRAINT Fk_users_credit_cards
FOREIGN KEY (user_id) REFERENCES users(id); 

#verificación
DESCRIBE transactions;
DESCRIBE credit_cards; 

#para asegurarnos de las relaciones y mas precisamente de la relacion entre credit_cards y users hacemos la siguiente query : 
SELECT user_id , COUNT(*)
FROM credit_cards 
GROUP BY user_id
HAVING COUNT(*) >1; 

#asi sabemos que un usuario esta asociaciado a una sola tarjeta 

#EJERCICIO 1 
#Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.

SELECT *
FROM users AS u
WHERE EXISTS ( SELECT 1
               FROM transactions AS t
               WHERE t.user_id = u.id
					AND t.declined = 0
			   GROUP BY t.user_id 
               HAVING COUNT(t.id) > 80
); 
        

#verificacion con JOIN 
SELECT u.id, u.name, u.surname, COUNT(t.id) AS Cantidad_transacciones
FROM transactions AS t
JOIN users AS u
ON t.user_id = u.id
WHERE t.declined = 0 
GROUP BY 1,2,3
HAVING Cantidad_transacciones> 80; 

 

#EJERCICIO 2 
#Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd, utiliza por lo menos 2 tablas.

SELECT c1.iban, ROUND(AVG(t.amount),2) AS Media_importe
FROM transactions AS t 
JOIN companies AS c 
ON t.business_id= c.company_id 
JOIN credit_cards AS c1
ON c1.id= t.card_id
WHERE c.company_name = "Donec Ltd" AND t.declined = 0
GROUP BY c1.iban
ORDER BY Media_importe DESC ; 

#NIVEL 2 
#Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las últimas tres transacciones fueron declinadas y genera la siguiente consulta:

#creaamos varias CTE, para tener mejor organizacion y legibilidad 
CREATE TABLE IF NOT EXISTS Credit_cards_status AS(
WITH Transacciones_ordenadas AS (
     SELECT 
	    t.id, 
		t.card_id,
		ROW_NUMBER() OVER (PARTITION BY t.card_id ORDER BY t.timestamp DESC) AS Ranking_transacciones
	 FROM transactions AS t), 

     Tres_ultimas_transacciones AS (
	 SELECT 
		t.card_id,
		t.declined, 
		t.timestamp	
	 FROM  Transacciones_ordenadas 
	 JOIN transactions AS t
	 ON t.id = Transacciones_ordenadas.id
	 WHERE Ranking_transacciones <=3),
     
     Transacciones_declinadas AS (
     SELECT 
		Tres_ultimas_transacciones.card_id, 
		SUM(Tres_ultimas_transacciones.declined) AS Cantidad_declinadas
        FROM Tres_ultimas_transacciones
        GROUP BY Tres_ultimas_transacciones.card_id) 
  
SELECT 
	Transacciones_declinadas.card_id, 
    CASE 
		WHEN Transacciones_declinadas.Cantidad_declinadas = 3 THEN "Tarjeta inactiva"
        ELSE "Tarjeta activa"
        END AS Estado_tarjeta 
FROM Transacciones_declinadas);
     
SELECT*
FROM credit_cards_status;
	
#VERSION CON SUBQUERIES MULTIPLES 
SELECT 
	T3.card_id, 
    CASE 
		WHEN Cantidad_declinadas = 3 THEN "Tarjeta inactiva"
        ELSE "Tarjeta activa"
        END AS Estado_tarjeta 
FROM (SELECT 
		T2.card_id, 
		SUM(T2.declined) AS Cantidad_declinadas

	  FROM ( SELECT 
				t.card_id,
				t.declined, 
				t.timestamp	
        
			 FROM (SELECT 
					 t1.id, 
					 t1.card_id,
					 ROW_NUMBER() OVER (PARTITION BY t1.card_id ORDER BY t1.timestamp DESC) AS Ranking_transacciones
				   FROM transactions AS t1) Transacciones_ordenadas 
       JOIN transactions AS t
       ON t.id = Transacciones_ordenadas .id
       WHERE Ranking_transacciones <=3)T2 

      GROUP BY T2.card_id) T3;

#Configuramos la PK y FK de esa tabla intermedia
ALTER TABLE credit_cards_status
ADD CONSTRAINT Pk_credit_cards_status
PRIMARY KEY (card_id);

ALTER TABLE credit_cards_status
ADD CONSTRAINT FK_CreditCardsStatus_CreditCards
FOREIGN KEY (card_id) REFERENCES credit_cards(id);

DESCRIBE credit_cards_status;


#EJERCICIO  1
SELECT*
FROM credit_cards_status;

#¿Cuántas tarjetas están activas?

SELECT COUNT(c.Estado_tarjeta) AS Cantidad_tarjetas_activas
FROM credit_cards_status AS c
WHERE c.Estado_tarjeta = "Tarjeta activa";

#Nivel 3 
#Crea una tabla con la que podemos unir los datos del nuevo archivo products.csv con la base de datos creada, teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:
#para nivel 3: tendremos que tener una tabla con clave primaria compuesta : id transaccion + id producto relacion de muchos a muchos 

#Primero creamos la tabla products y cargamos los datos siguiendo los mismos pasos que para el nivel 1 
CREATE TABLE products (
id INT,
product_name VARCHAR(50), 
price VARCHAR(10), 
colour VARCHAR(20),
weight DECIMAL(10,2), 
warehouse_id VARCHAR(20));

LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.0//Uploads//products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#cambiamos el data type de la columna price, primero quitando el símbolo dolard y posteriormente convertimos a DECIMAL 
UPDATE products 
SET price = REPLACE(price, "$", ""); 
ALTER TABLE products
MODIFY COLUMN price DECIMAL(10,2);

#verificamos: 
SELECT * 
FROM products;
DESCRIBE products; 

#Anadimos la PK
ALTER TABLE products 
ADD CONSTRAINT Pk_products
PRIMARY KEY (id); 


#transformamos la columna products_id de transactions a formato JSON ARRAY  creando una nueva columna en transactions 
ALTER TABLE transactions 
ADD COLUMN separated_products VARCHAR(255); 

UPDATE transactions
SET separated_products = REPLACE (product_ids, ',', '","'); 

UPDATE transactions
SET separated_products = CONCAT('["',separated_products,'"]');

CREATE TABLE IF NOT EXISTS transactionsProducts
SELECT t.id AS transaction_id, j.product_id
FROM transactions AS t
CROSS JOIN 
JSON_TABLE (t.separated_products, "$[*]"
	COLUMNS (product_id INT PATH "$")) AS j; 


#Configuramos la PK y relacionamos esa tabla con la tabla products y transactions mediante FK 
ALTER TABLE transactionsProducts
ADD CONSTRAINT Pk_transactionsProducts
PRIMARY KEY (transaction_id, product_id);

ALTER TABLE transactionsProducts
ADD CONSTRAINT Fk_transactionsProducts_products
FOREIGN KEY (product_id) REFERENCES products (id);

ALTER TABLE transactionsProducts
ADD CONSTRAINT Fk_transactionsProducts_transactions
FOREIGN KEY (transaction_id) REFERENCES transactions(id);

DESCRIBE transactionsProducts; 

#procedemos a eliminar la columna separated_products de la tabla transactions para dejarla como estaba inicialmente
ALTER TABLE transactions
DROP COLUMN separated_products;

#verificacion: 
SELECT* 
FROM transactions;


#EJERCICIO 1
#Necesitamos conocer el número de veces que se ha vendido cada producto.

SELECT tp.product_id, p.product_name, COUNT(*) AS Cantidad_ventas
FROM transactionsProducts AS tp
JOIN transactions AS t
ON t.id = tp.transaction_id
JOIN products AS p
ON p.id = tp.product_id
WHERE t.declined = 0
GROUP BY tp.product_id
ORDER BY tp.product_id;
