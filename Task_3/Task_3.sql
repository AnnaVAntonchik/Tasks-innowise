-- 1. Вывести количество фильмов в каждой категории, отсортировать по убыванию.
-- Первый вариант
select c.name as category, count(film_id) as number_of_films
from public.film_category fc
join public.category c on c.category_id = fc.category_id 
group by c.name
order by number_of_films desc; 

-- Второй вариант
select distinct category, count(fid) over (partition by category) as number_of_films
from public.film_list
order by number_of_films desc; 


-- 2. Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
select a.actor_id, a.last_name, a.first_name, count(r.rental_id) as number_of_rented_films 
from public.rental r
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id 
join film_actor fa on fa.film_id  = f.film_id 
join actor a on a.actor_id = fa.actor_id 
group by a.actor_id, a.last_name, a.first_name
order by number_of_rented_films desc
limit 10;


-- 3. Вывести категорию фильмов, на которую потратили больше всего денег.
-- Первый вариант
select c."name", sum(p.amount) as total_sales
from public.payment p
join public.rental r on r.rental_id = p.rental_id 
join inventory i on i.inventory_id = r.inventory_id 
join film_category fc on fc.film_id = i.film_id 
join category c on c.category_id = fc.category_id 
group by c."name" 
order by total_sales desc
fetch first row with ties;

-- Второй вариант
select * 
from public.sales_by_film_category
order by total_sales desc
fetch first row with ties;


-- 4. Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.
-- Первый вариант
with films_not_in_inventory as(
	select film_id from film f 
	except
	select film_id from inventory i)

select f.film_id, f.title from films_not_in_inventory c
join film f on f.film_id = c.film_id
order by f.film_id; 

-- Второй вариант
select f.film_id, f.title 
from film f 
left join inventory i on i.film_id = f.film_id 
where i.inventory_id is null
order by f.film_id; 

-- Третий вариант с использованием anti join
select f.film_id, f.title
from film f
where not exists (select i.film_id from inventory i where i.film_id = f.film_id)
order by f.film_id; 


-- 5. Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.
-- CTE для подсчёта количества повторений актёров в категории “Children”
with count_actors_children_films as(
	select a.actor_id, a.first_name, a.last_name, count(c."name") as number_of_films_in_category_children
	from actor a 
	join film_actor fa on fa.actor_id = a.actor_id 
	join public.film f on f.film_id = fa.film_id 
	join public.film_category fc on fc.film_id = f.film_id 
	join category c on c.category_id = fc.category_id and c."name" = 'Children'
	group by c."name", a.actor_id
	order by count(c."name") desc), 
-- CTE для выбора топ 3 количества повторений актёров в категории “Children”
	top_3_children_filming_amounts as(
	select distinct number_of_films_in_category_children as max_number 
	from count_actors_children_films 
	order by max_number desc 
	limit 3)
	
select *
from count_actors_children_films c
where c.number_of_films_in_category_children in(select * from top_3_children_filming_amounts)


-- 6. Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). 
-- Отсортировать по количеству неактивных клиентов по убыванию.
with customer_counts as (
    select c.country, count(case when c3.active = 1 then 1 end) as active_customers, count(case when c3.active = 0 then 1 end) as inactive_customers
    from country c
    join city c2 on c2.country_id = c.country_id
    join address a on a.city_id = c2.city_id
    join customer c3 on c3.address_id = a.address_id
    group by c.country)

select country, active_customers, inactive_customers
from customer_counts
order by inactive_customers desc;


-- 7. Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), 
-- и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.
with count_rental_hours as (
	select c2.city, c3.name, sum(extract(hour from  return_date - rental_date)) as rental_hours
	from public.rental r 
	join customer c on c.customer_id = r.customer_id
	join address a on c.address_id = a.address_id
	join city c2 on c2.city_id = a.city_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	join film_category fc on fc.film_id = f.film_id
	join category c3 on c3.category_id = fc.category_id
	where c2.city ilike 'A%' or c2.city ilike '%-%'
	group by c2.city, c3.name)
	
select * from (select city, name, max(rental_hours) as rental_hours
	from count_rental_hours 
	where city ilike 'A%'
	group by city, name
	having max(rental_hours) is not null
	order by max(rental_hours) desc
	limit 1)
union 
select * from (select city, name, max(rental_hours) as rental_hours
	from count_rental_hours 
	where city ilike '%-%'
	group by city, name
	having max(rental_hours) is not null
	order by max(rental_hours) desc
	limit 1)













