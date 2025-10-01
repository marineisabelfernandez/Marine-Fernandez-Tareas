#Nivel1 
#EJERCICIO 1 
#Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. La nueva tabla debe ser capaz de identificar de forma única cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company"). 
#Después de crear la tabla será necesario que ingreses la información del documento denominado "datos_introducir_credit". 
#Recuerda mostrar el diagrama y realizar una breve descripción del mismo.

USE transactions; 
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(8) PRIMARY KEY, 
	iban VARCHAR(34), 
	pan VARCHAR(19), 
	pin CHAR(4),
	cvv CHAR(3),
	expiring_date DATE
);

#Modificamos el tipo del campo expiring_date 
ALTER TABLE credit_card 
MODIFY COLUMN expiring_date VARCHAR (10); 

#Añadimos la relación entre la tabla transacción y credit_card
ALTER TABLE transaction 
ADD CONSTRAINT Fk_CreditCard 
FOREIGN KEY (credit_card_id) REFERENCES credit_card (id); 

#verificacion de la correcta creación de la tabla 
DESCRIBE credit_card; 



#EJERCICIO 2 
#El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938. 
#La información que debe mostrarse para este registro es: TR323456312213576817699999. 
#Recuerda mostrar que el cambio se realizó.

UPDATE credit_card SET iban = "TR323456312213576817699999" WHERE id = "CcU-2938"; 

#verificacion 
SELECT iban 
FROM credit_card 
WHERE id = "CcU-2938";


#EJERCICIO 3 
#En la tabla "transaction" ingresa una nueva transacción con la siguiente información:
#Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
#credit_card_id	CcU-9999
#company_id	b-9999
#user_id	9999
#lat	829.999
#longitude	-117.999
#amount	111.11
#declined	0

#Insertamos el id de credit card proporcionado en la tabla credit_card 
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)
VALUES ("CcU-9999", NULL, NULL, NULL, NULL); 

#Insertamos el id de la empresa proporcionado en la tabla company 
INSERT INTO company (id, company_name, phone, email, country, website) 
VALUES ("b-9999", NULL, NULL, NULL, NULL, NULL);

#Finalmente podemos ingresar los datos relativos a la transacción
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999", "829.999", "-117.999", NULL, "111.11", "0"); 

#verificacion 
SELECT * 
FROM transaction
WHERE id = "108B1D1D-5B23-A76C-55EF-C568E49A99DD"; 

#EJECICIO 4 
#Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.
ALTER TABLE credit_card 
DROP COLUMN pan; 

#verificacion 
SELECT* 
FROM credit_card; 

#NIVEL 2 
#EJERCICIO 1 
#Elimina de la tabla transacción el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.

#Antes de eliminar, verificamos que existe antes ese registro
SELECT* 
FROM transaction 
WHERE id="000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

DELETE FROM transaction 
WHERE id ="000447FE-B650-4DCF-85DE-C7ED0EE1CAAD"; 
 
#verificacion: 
SELECT* 
FROM transaction 
WHERE id="000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

#EJERCICIO 2 
#La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. 
#Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. 
#Será necesaria que crees una vista llamada VistaMarketing que contenga la siguiente información: 
#Nombre de la compañía. Teléfono de contacto. País de residencia. Media de compra realizado por cada compañía. 
#Presenta la vista creada, ordenando los datos de mayor a menor

CREATE VIEW VistaMarketing AS 
SELECT 
	c.company_name,
    c.phone,
    c.country,
    ROUND(AVG(t.amount),2) AS Media_compras
FROM company AS c 
JOIN transaction AS t
ON c.id=t.company_id
WHERE declined = 0
GROUP BY c.company_name, c.phone, c.country
; 

SELECT * 
FROM VistaMarketing 
ORDER BY Media_compras DESC; 

#EJECICIO 3 
#Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"

SELECT* 
FROM VistaMarketing 
WHERE country = "Germany"; 

#NIVEL 3 
#EJERCICIO 1 

#modificaciones tabla company
ALTER TABLE company
DROP COLUMN website; 

#verificación 
DESCRIBE company; 

#modificacion tabla credit_card:
ALTER TABLE credit_card 
MODIFY COLUMN id VARCHAR (20);

ALTER TABLE credit_card 
MODIFY COLUMN iban VARCHAR (50);

ALTER TABLE credit_card 
MODIFY COLUMN pin VARCHAR (4);

ALTER TABLE credit_card 
MODIFY COLUMN cvv INT; 

ALTER TABLE credit_card 
ADD COLUMN fecha_actual DATE;

#verificación
DESCRIBE credit_card; 

#modificaciones tabla user 
RENAME TABLE user TO data_user;

ALTER TABLE data_user 
MODIFY COLUMN id INT;

ALTER TABLE data_user 
RENAME COLUMN email TO personal_email; 

#verificación
DESCRIBE data_user;

#anadir el id company de la transaccion que nos pidieron anadir en el ejercicio  nivel 1 para poder configurar la FK con la tabla User_id 
INSERT INTO data_user(id, name, surname, phone, personal_email, birth_date, country, city, postal_code, address)
VALUES(9999, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); 

#verificación
SELECT* 
FROM data_user
WHERE id = 9999; 

#modificaciones foreign keys en la tabla transaction
ALTER TABLE transaction 
ADD CONSTRAINT Fk_UserId
FOREIGN KEY (user_id) REFERENCES data_user (id); 

#verificación
DESCRIBE transaction; 

#EJERCICIO 2
#La empresa también le pide crear una vista llamada "InformeTecnico" que contenga la siguiente información:
#- ID de la transacción
#- Nombre del usuario/a
#- Apellido del usuario/a
#- IBAN de la tarjeta de crédito usada.
#- Nombre de la compañía de la transacción realizada.
#Asegúrese de incluir información relevante de las tablas que conocerá y utilice alias para cambiar de nombre columnas según sea necesario.
#Muestra los resultados de la vista, ordena los resultados de forma descendente en función de la variable ID de transacción.

CREATE VIEW InformeTecnico AS 
SELECT 
	t.id AS ID_transaccion, 
    DATE(t.timestamp) AS Fecha_transaccion,
	U.name AS Nombre_usuario, 
	U.surname AS Apellido_usuario,
	c.iban AS Iban_tarjeta_credito_usada,
    c1.company_name AS Nombre_compania_transaccion_realizada,
    c1.country AS Pais_compania,
	SUM(t.amount) OVER(PARTITION BY c1.company_name) AS Total_Importe_Ventas_Por_Compania, 
    COUNT(t.id) OVER(PARTITION BY c1.company_name) AS Total_Cantidad_Ventas_Por_Compania
FROM transaction AS t
JOIN data_user AS u
ON t.user_id = u.id
JOIN credit_card AS c
ON c.id = t.credit_card_id
JOIN company AS c1
ON c1.id = t.company_id; 

SELECT*
FROM InformeTecnico
ORDER BY ID_transaccion DESC;
