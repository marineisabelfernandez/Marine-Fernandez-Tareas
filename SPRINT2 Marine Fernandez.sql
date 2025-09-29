#NIVEL 1
#EJERCICIO 2
#1. Listado de los países que están generando ventas. 

SELECT DISTINCT c.country 
FROM company AS c
JOIN transaction AS t
ON c.id= t.company_id
WHERE declined = 0; 


#2. Desde cuántos países se generan las ventas.

SELECT COUNT(DISTINCT c.country) 
FROM company AS c
JOIN transaction AS t
ON c.id= t.company_id
WHERE declined =0 ;

#3. Identifica a la compañía con la mayor media de ventas 
SELECT c.company_name, ROUND(AVG(amount),2) AS Promedio_ventas 
FROM company AS c
JOIN transaction AS t
ON c.id= t.company_id
WHERE declined = 0 
GROUP BY company_name
ORDER BY Promedio_ventas  DESC 
LIMIT 1;

#EJERCICIO 3 Utilizando sólo subconsultas (sin utilizar JOIN)
#1. Muestra todas las transacciones realizadas por empresas de Alemania

SELECT *
FROM transaction AS t
WHERE EXISTS (SELECT 1
			  FROM company AS c
			  WHERE c.id = t.company_id AND country = "GERMANY");


#2. Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT  c.id, c.company_name
FROM company AS c
WHERE EXISTS (SELECT 1
              FROM transaction AS t
              WHERE c.id = t.company_id 
			    AND t.amount > (SELECT AVG(t1.amount) 
							    FROM transaction AS t1)
		        AND t.declined = 0);


#3. Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.

SELECT c.id, c.company_name 
FROM company AS c
WHERE NOT EXISTS (SELECT 1
				  FROM transaction AS t
                  WHERE t.company_id=c.id); 


#NIVEL 2
#EJERCICIO 1
#1. Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT DATE(t.timestamp) AS fecha, SUM(amount) AS suma_ingresos
FROM transaction AS t
GROUP BY fecha 
ORDER BY suma_ingresos DESC
LIMIT 5;

#EJERCICIO 2
#1. ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.

SELECT  c.country, ROUND(AVG(amount),2) as Media_ventas
FROM company AS c
JOIN transaction AS t
ON c.id= t.company_id 
WHERE declined=0
GROUP BY c.country
ORDER BY Media_ventas desc;

#EJERCICIO 3
#1. En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”. Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía. 
#Muestra el listado aplicando JOIN y subconsultas.

SELECT *
FROM company AS c
JOIN transaction AS t
ON c.id= t.company_id
WHERE declined = 0 AND c.country = (SELECT country
				                    FROM company 
				                    WHERE company_name = "Non Institute");
                     


#Muestra el listado aplicando solo subconsultas.

SELECT *
FROM transaction AS t
WHERE EXISTS (SELECT 1
			  FROM company AS c
			  WHERE c.id= t.company_id 
               AND declined = 0
			   AND country = (SELECT country
							  FROM company 
						      WHERE company_name = "Non Institute"));

#NIVEL 3
#EJERCICIO 1
#1. Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 350 y 400 euros y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. 
#Ordena los resultados de mayor a menor cantidad.

SELECT c.company_name, c.phone, c.country, t.timestamp, t.amount 
FROM company AS c 
JOIN transaction AS t
ON c.id=t.company_id 
WHERE declined =0 
 AND t.amount BETWEEN 350 AND 400 
 AND DATE(t.timestamp) IN ("2015-04-29", "2018-07-20", "2024-03-13")
ORDER BY t.amount DESC;

#EJERCICIO 2 
#Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente y quiere un listado de las empresas en las que especifiques si tienen más de 400 transacciones o menos.

SELECT c.id, c.company_name, COUNT(t.id),
CASE 
	WHEN COUNT(t.id) > 400 THEN "La empresa tiene más de 400 transacciones"
    ELSE "La empresa tiene igual o menos de 400 transacciones"
    END as Cantidad_de_transacciones
FROM transaction AS t
JOIN company AS c 
ON c.id = t.company_id 
WHERE declined = 0 
GROUP BY c.id, c.company_name;
   