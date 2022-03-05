USE sakila;



#How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT 
	count(inventory_id)
FROM 
	inventory
WHERE 
	film_id IN 
				(SELECT 
					film_id 
				FROM 
					film 
				WHERE 
					title = 'hunchback impossible');


#List all films whose length is longer than the average of all the films.

SELECT
	title, 
    length AS length
FROM 
	film
WHERE 
	length > (SELECT ROUND(AVG(length),2)
				FROM film)
ORDER BY
	length DESC;


#Use subqueries to display all actors who appear in the film Alone Trip.

SELECT 
	CONCAT(a.first_name," ", a.last_name) as actor
FROM 
	actor a
JOIN
	film_actor fa
USING
	(actor_id)
JOIN
	film
USING
	(film_id)
WHERE
	film_id = 
				(SELECT 
					film_id 
				FROM 
					film 
                WHERE 
					title = 'alone trip');
                
                

                                    

#Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT 
	title
FROM
	film
WHERE 
	film_id IN 
				(SELECT 
					film_id 
					FROM
						film_category 
					WHERE 
						category_id IN 
										(SELECT 
											category_id 
                                        FROM
											category 
										WHERE 
											name = "Family"));


#Get name and email from customers from Canada using subqueries. Do the same with joins. 
#Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

SELECT 
	c.first_name, 
    c.last_name,
    c.email,
    ci.city
FROM 
	customer c
JOIN
	address a
USING
	(address_id)
JOIN
	city ci
USING
	(city_id)
JOIN
	country co
USING
	(country_id)
WHERE
	country = 'Canada';
    

SELECT 
	CONCAT(first_name," ", last_name) as customer,
    email
FROM
	customer
WHERE 
	address_id IN 
				(SELECT 
					address_id 
				FROM 
					address 
					WHERE 
						city_id IN 
									(SELECT 
										city_id 
									FROM 
										city 
									WHERE 
										country_id IN
											(SELECT
												country_id
											FROM
												country
											WHERE
												country = "Canada"))); 



#Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
#First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

CREATE TEMPORARY TABLE Most_films1
SELECT
	actor_id,
    COUNT(film_id) as num_films
FROM
	film_actor
GROUP BY
	actor_id
ORDER BY
	num_films DESC
LIMIT
	1;
    
SELECT * from most_films1;
	
SELECT
	first_name, last_name
FROM
	actor
WHERE
	actor_id = 107;
    
SELECT
	title
FROM
	film
WHERE
	film_id IN
				(SELECT 
					film_id
				FROM
					film_actor
				WHERE 
					actor_id =
								(SELECT 
									actor_id
								FROM
									most_films1));
                 

#Films rented by most profitable customer. 
#You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

CREATE TEMPORARY TABLE Most_money
SELECT
	customer_id,
    sum(amount) as amount
FROM
	payment
GROUP BY
	customer_id
ORDER BY
	amount DESC
LIMIT
	1;
    
SELECT * from most_money;
	
SELECT
	title
FROM
	film
WHERE
	film_id in
				(SELECT 
					film_id
				FROM
					inventory
				WHERE
					inventory_id in
									(SELECT
										inventory_id
									FROM
										rental
									WHERE 
										rental_id in
													(SELECT 
														rental_id
													FROM
														payment
													WHERE
														customer_id =
																		(SELECT
																			customer_id
																		FROM 
																			most_money))))
ORDER BY
	title;
																		


#Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.


SELECT
	customer_id,
    SUM(amount) AS total_amount
FROM
	payment
GROUP BY
	customer_id
HAVING
	total_amount > (SELECT
					ROUND(AVG(total_amount))
					FROM
						(SELECT
							customer_id,
							SUM(amount) AS total_amount
						FROM
							payment
						GROUP BY
							customer_id) AS totals
				)
ORDER BY
	total_amount DESC;
