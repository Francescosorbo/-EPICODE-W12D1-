 
/*PRATICA 1 */ 
 
 /*Esercizio 2- Scoprite quanti clienti si sono registrati nel 2006.*/
 
 
 select count(customer.customer_id)as registroclienti
 from customer
 where year(customer.create_date)=2006 ;

 

 /*Esercizio 3- Trovate il numero totale di noleggi effettuati il giorno 14/02/2006.*/
 
SELECT 
    COUNT(rental.rental_id) AS NumeroNoleggi
FROM
    rental
WHERE
    DATE(rental.rental_date) = '2006-02-14';
 
 /*Esercizio 4- Elencate tutti i film noleggiati nell’ultima settimana e tutte le informazioni legate al cliente che li ha noleggiati.*/
 
SELECT 
    film.title AS titolofim, customer.*
FROM
    film
        LEFT JOIN
    inventory ON film.film_id = inventory.film_id
        LEFT JOIN
    rental ON inventory.inventory_id = rental.inventory_id
        LEFT JOIN
    customer ON rental.customer_id = customer.customer_id
WHERE
    DATEDIFF('2006-02-14', DATE(rental.rental_date)) < 7 ;
 
 
 
 /*Esercizio 5- Calcolate la durata media del noleggio per ogni categoria di film.*/
 
SELECT 
    category.name AS Categoria,
    CAST(AVG(DATEDIFF(rental.return_date, rental.rental_date))
        AS DECIMAL (10 , 2 )) AS DurataNoleggio
FROM
    category
        LEFT JOIN
    film_category ON category.category_id = film_category.category_id
        LEFT JOIN
    film ON film_category.film_id = film.film_id
        LEFT JOIN
    inventory ON film.film_id = inventory.film_id
        LEFT JOIN
    rental ON inventory.inventory_id = rental.inventory_id
        LEFT JOIN
    customer ON rental.customer_id = customer.customer_id
GROUP BY Categoria
ORDER BY DurataNoleggio;
 
 
 /*Esercizio 6- trovate la durata del noleggio più lungo*/
 
 SELECT 
    film.title AS Film,
    customer.first_name AS NomeCliente,
    customer.last_name AS CognomeCliente,
    DATEDIFF(rental.return_date, rental.rental_date) AS DurataNoleggio
FROM
    film
        LEFT JOIN
    inventory ON film.film_id = inventory.film_id
        LEFT JOIN
    rental ON inventory.inventory_id = rental.inventory_id
        LEFT JOIN
    customer ON rental.customer_id = customer.customer_id
WHERE
    DATEDIFF(rental.return_date, rental.rental_date) = (SELECT 
            MAX(DATEDIFF(rental.return_date, rental.rental_date))
        FROM
            rental);
 
 
 /* PRATICA 2 */
 
 /*Esercizio 1 Identificate tutti i clienti che non hanno effettuato nessun noleggio a gennaio 2006*/
 
SELECT DISTINCT
    CONCAT(customer.first_name,
            ' ',
            customer.last_name) AS cliente
FROM
    customer
        LEFT JOIN
    rental ON customer.customer_id = rental.customer_id
WHERE
    customer.customer_id NOT IN (SELECT DISTINCT
            customer.customer_id
        FROM
            customer
                JOIN
            rental ON customer.customer_id = rental.customer_id
        WHERE
            YEAR(rental.rental_date) = 2006
                AND MONTH(rental.rental_date) = 2);
 
 
 /*Esercizio 2 Elencate tutti i film che sono stati noleggiati più di 10 volte nell’ultimo quarto del 2005*/
 
SELECT 
    film.title AS titolofilm,
    COUNT(rental.rental_id) AS numeronoleggi
FROM
    rental
        LEFT JOIN
    inventory ON inventory.inventory_id = rental.inventory_id
        LEFT JOIN
    film ON film.film_id = inventory.film_id
WHERE
    rental.rental_id IN (SELECT DISTINCT
            rental.rental_id
        FROM
            rental
        WHERE
            YEAR(rental.rental_date) = 2005
                AND MONTH(rental.rental_date) BETWEEN 7 AND 9)
GROUP BY titolofilm
HAVING numeronoleggi > 10
ORDER BY numeronoleggi DESC;
 
 
 /*Esercizio 3 Trovate il numero totale di noleggi effettuati il giorno 1/1/2006.*/ 
 
SELECT 
    rental.rental_date AS datanoleggio,
    COUNT(*) AS numeronoleggi
FROM
    rental
WHERE
    DATE(rental.rental_date) = '2006-02-14'
GROUP BY datanoleggio;
 
 
/*Esercizio 4 Calcolate la somma degli incassi generati nei weekend (sabato e domenica).*/
 
 SELECT
	SUM(p.amount) incassi_weekend
FROM
	payment p
WHERE
	DAYOFWEEK(p.payment_date) = 1 OR DAYOFWEEK(p.payment_date) = 7;
 
 /*Esercizio 5 Individuate il cliente che ha speso di più in noleggi.*/
 
 SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
	SUM(p.amount) somma_noleggi
FROM
	payment p
		LEFT JOIN
	customer c ON p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY 4 DESC
LIMIT 1;

 /*Esercizio 6 elencate i 5 film con la maggior durata media di noleggio*/ 
 
 SELECT
	f.title titolo_film,
    AVG(DATEDIFF(r.return_date,r.rental_date)) durata_noleggio_media
FROM
	rental r
		LEFT JOIN
	inventory i ON r.inventory_id = i.inventory_id
		LEFT JOIN
	film f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY 2 DESC
LIMIT 5;
 

 /*Esercizio 7 Calcolate il tempo medio tra due noleggi consecutivi da parte di un cliente.*/
 
 SELECT 
    customer.first_name,
    customer.last_name,
    AVG(DATEDIFF(next_rental.rental_date, rental.rental_date)) AS Tempo_Medio_Due_Noleggi
FROM 
    sakila.customer
JOIN 
    sakila.rental ON customer.customer_id = rental.customer_id
LEFT JOIN 
    sakila.rental AS next_rental ON rental.customer_id = next_rental.customer_id 
                                    AND next_rental.rental_date = (
                                        SELECT MIN(nr.rental_date)
                                        FROM sakila.rental nr
                                        WHERE nr.customer_id = rental.customer_id 
                                          AND nr.rental_date > rental.rental_date
                                    )
GROUP BY 
    customer.customer_id, customer.first_name, customer.last_name
ORDER BY 
    Tempo_Medio_Due_Noleggi DESC;
 
 
 /*Esercizio 8 Individuate il numero di noleggi per ogni mese del 2005.*/
 
 SELECT
	MONTHNAME(r.rental_date) mese,
	COUNT(r.rental_id) numero_noleggi
FROM
	rental r
WHERE
	YEAR(r.rental_date) = 2005
GROUP BY MONTHNAME(r.rental_date);
 

 /*Esercizio 9 Trovate i film che sono stati noleggiati almeno due volte lo stesso giorno.*/
 
 SELECT
	f.title film,
    -- COUNT(r.rental_id) numero_noleggi,
    COUNT(DISTINCT DATE(r.rental_id)) numero_noleggi_distinti
FROM
	rental r
		LEFT JOIN
	inventory i ON r.inventory_id = i.inventory_id
		LEFT JOIN
	film f ON i.film_id = f.film_id
GROUP BY f.title
HAVING COUNT(DISTINCT DATE(r.rental_id)) >= 2
ORDER BY 2;
 
 /*Esercizio 10 Calcolate il tempo medio di noleggio.*/
 
 SELECT
	AVG(DATEDIFF(r.return_date,r.rental_date)) durata_noleggio_media
FROM
	rental r;
 