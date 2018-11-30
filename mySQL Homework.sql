# use sakila data base
use sakila;

# 1a.	Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

# 1b.	Display the first and last name of each actor in a single column in upper case letters. 
#		Name the column Actor Name.
select upper(concat(first_name, ' ',last_name)) as 'Actor Name' from actor;

#2a. 	You need to find the ID number, first name, and last name of an actor, 
#		of whom you know only the first name, "Joe." 
#		What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor
where first_name like 'joe%';

#2b. 	Find all actors whose last name contain the letters GEN.
select first_name, last_name from actor 
where last_name like '%gen%';

#2c. 	Find all actors whose last names contain the letters LI. 
#		This time, order the rows by last name and first name, in that order.alter
select first_name, last_name from actor 
where last_name like '%li%'
order by last_name asc, first_name asc;

#2d. 	Using IN, display the country_id and country columns of the following countries: 
#		Afghanistan, Bangladesh, and China
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

#3a. 	Create a column in the table actor named description and use the data type BLOB.
alter table actor
add column description blob after last_name;

#3b. 	Delete the description column.
alter table actor
drop column description;

#4a. 	List the last names of actors, as well as how many actors have that last name.
select last_name, count(first_name) from actor
group by (last_name);

#4b. 	List last names of actors and the number of actors who have that last name, 
#		but only for names that are shared by at least two actors
select last_name, count(first_name) from actor
group by (last_name)
having count(first_name) > 1;

#4c. 	The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
#		Write a query to fix the record.
update actor 
set first_name = 'HARPO' 
where first_name = 'Groucho' 
and last_name = 'Williams';

#4d. 	Perhaps we were too hasty in changing GROUCHO to HARPO. 
#		It turns out that GROUCHO was the correct name after all! 
#		In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor 
set first_name = 'GROUCHO' 
where first_name = 'Harpo'
and actor_id = '%';

#5a. 	You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;

#6a. 	Use JOIN to display the first and last names, as well as the address, of each staff member. 
#		Use the tables staff and address.
select 	staff.first_name, 
		staff.last_name, 
		address.address 
from staff left join address on staff.address_id = address.address_id;

#6b. 	Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#		Use tables staff and payment.
select 	staff.first_name, 
		staff.last_name,
        concat('$', format(sum(payment.amount), 2)) 'total amount: \n aug 05'
from staff left join payment on staff.staff_id = payment.staff_id
where payment_date like '2005-08%'
group by staff.staff_id;

#6c. 	List each film and the number of actors who are listed for that film. 
#		Use tables film_actor and film. Use inner join.
select 	film.title 'film',
		count(film_actor.actor_id) 'actor_count'
from film inner join film_actor on film.film_id = film_actor.film_id
group by film.film_id;   

#6d. 	How many copies of the film Hunchback Impossible exist in the inventory system?
select 	film.title 'film',
		count(inventory.inventory_id) 'inventory_count'
from film inner join inventory on film.film_id = inventory.film_id
where film.title = 'Hunchback Impossible';

#6e. 	Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#		List the customers alphabetically by last name.
select 	customer.first_name,
		customer.last_name,
        concat('$', format(sum(payment.amount) , 2))  'total paid'
from customer left join payment on customer.customer_id = payment.customer_id
group by customer.customer_id
order by customer.last_name;

#7a. 	Use subqueries to display the titles of movies starting with the letters K and Q 
#		whose language is English.
select title from film 
where language_id in
	(select language_id from language
	where name = 'English')
and (title like 'k%' 
or title like 'q%');

#7b. 	Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor
where actor_id in 
    (select actor_id from film_actor
	where film_id in 
		(select film_id from film
		where title = 'Alone Trip'));

#7c. 	You want to run an email marketing campaign in Canada, 
#		for which you will need the names and email addresses of all Canadian customers. 
#		Use joins to retrieve this information.
select 	customer.first_name,
		customer.last_name,
		customer.email
from customer inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id
where country.country = 'Canada';

#7d. 	Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#		Identify all movies categorized as family films.
select title 'family_films' from film
where film_id in	
    (select film_id from film_category
	where category_id in 	
		(select category_id from category 
		where name = 'Family'));

#7e. 	Display the most frequently rented movies in descending order.
select 	film.title,
		count(rental.rental_id) 'rental_count'
from film inner join inventory on film.film_id = inventory.film_id
inner join rental on inventory.inventory_id = rental.inventory_id
group by film.film_id
order by count(rental.rental_id) desc;

#7f. 	Write a query to display how much business, in dollars, each store brought in.
select 	store.store_id,
		concat('$', format(sum(payment.amount) , 2))  'total_revenue'
from store inner join staff on store.store_id = staff.store_id
inner join payment on staff.staff_id = payment.staff_id
group by store.store_id;

#7g. 	Write a query to display for each store its store ID, city, and country.
select 	store.store_id,
		city.city,
        country.country
from store inner join address on store.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id
group by store.store_id;

#7h. 	List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select 	category.name 'top_five_genres',
		concat('$', format(sum(payment.amount), 2)) 'gross_revenue'
from category inner join  film_category on category.category_id = film_category.category_id
inner join inventory on film_category.film_id = inventory.film_id
inner join rental on inventory.inventory_id = rental.inventory_id
inner join payment on rental.rental_id = payment.rental_id
group by category.category_id
order by sum(payment.amount) desc
limit 5;

#8a. 	In your new role as an executive, you would like to have an easy way of viewing 
#		the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
create view top_grossing_genres as
select 	category.name 'top_five_genres',
		concat('$', format(sum(payment.amount), 2)) 'gross_revenue'
from category inner join  film_category on category.category_id = film_category.category_id
inner join inventory on film_category.film_id = inventory.film_id
inner join rental on inventory.inventory_id = rental.inventory_id
inner join payment on rental.rental_id = payment.rental_id
group by category.category_id
order by sum(payment.amount) desc
limit 5;

#8b. 	How would you display the view that you created in 8a?
select * from top_grossing_genres;

#8c. 	You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_grossing_genres;


