-- Questão 01
drop view if exists v_staff_performance;
create view v_staff_performance as
select 
    s.staff_id, 
    s.first_name || ' ' || s.last_name as nome,
    c.city || ', ' || cy.country as localizacao,
    coalesce(count(distinct r.rental_id), 0) as total,
    coalesce(sum(p.amount), 0) as valor_total
from staff s
join store st on st.store_id = s.store_id
join address a on a.address_id = st.address_id
join city c on c.city_id = a.city_id
join country cy on cy.country_id = c.country_id
left join rental r on r.staff_id = s.staff_id
left join payment p on r.rental_id = p.rental_id
group by s.staff_id, c.city, cy.country
order by valor_total desc;

select * from v_staff_performance;

-- Questão 02
drop materialized view if exists mv_category_total_sales;
create materialized view mv_category_total_sales as
select 
    c.name as categoria,
    coalesce(sum(p.amount), 0) as total 
from category c 
join film_category fc on c.category_id = fc.category_id
join film f on f.film_id = fc.film_id
join inventory i on i.film_id = f.film_id
join rental r on i.inventory_id = r.inventory_id
join payment p on p.rental_id = r.rental_id
group by c.name 
order by total desc;

drop index if exists idx_categoria;
create unique index idx_categoria on mv_category_total_sales (categoria);

refresh materialized view concurrently mv_category_total_sales;

select * from mv_category_total_sales;

-- Questão 03
drop index if exists idx_rental_return_date_null;
create index idx_rental_return_date_null on rental (return_date) where return_date is null;

explain analyze
select * from rental where return_date is null;

-- Questão 04
drop index if exists idx_film_description_gin;
create index idx_film_description_gin on film using gin (to_tsvector('english', description));

explain analyze
select film_id, title, description 
from film 
where to_tsvector('english', description) @@ to_tsquery('english', 'documentary & drama');

-- Questão 05
drop index if exists idx_payment_customer_date;
create index idx_payment_customer_date on payment (customer_id, payment_date desc);

explain analyze
select * from payment where customer_id = 1 order by payment_date desc;

-- Questão 06
drop index if exists idx_customer_email_lower;
create index idx_customer_email_lower on customer (lower(email));

explain analyze
select * from customer where lower(email) = lower('MARY.SMITH@sakilacustomer.org');

-- Questão 07
create or replace function check_rental_dates()
returns trigger
language plpgsql
as $$
begin
    if new.return_date is not null and new.return_date < new.rental_date then
        raise exception 'data de devolucao anterior a data de locacao';
    end if;
    return new;
end;
$$;

drop trigger if exists trg_check_rental_dates on rental;
create trigger trg_check_rental_dates
before insert or update on rental
for each row
execute function check_rental_dates();

insert into rental (rental_date, inventory_id, customer_id, staff_id, return_date)
values (now(), 1, 1, 1, now() + interval '1 day');

do $$
begin
    insert into rental (rental_date, inventory_id, customer_id, staff_id, return_date)
    values (now(), 1, 1, 1, now() - interval '1 day');
exception
    when others then
        raise notice 'teste de falha executado: %', sqlerrm;
end;
$$;

-- Questão 08
drop table if exists film_cost_audit;
create table film_cost_audit (
    film_id int,
    old_cost numeric(5,2),
    new_cost numeric(5,2),
    changed_at timestamptz default now()
);

create or replace function log_film_cost_change()
returns trigger
language plpgsql
as $$
begin
    insert into film_cost_audit (film_id, old_cost, new_cost)
    values (new.film_id, old.replacement_cost, new.replacement_cost);
    return new;
end;
$$;

drop trigger if exists trg_film_cost_audit on film;
create trigger trg_film_cost_audit
after update on film
for each row
when (new.replacement_cost is distinct from old.replacement_cost)
execute function log_film_cost_change();

-- Questão 09
create or replace function check_language_delete()
returns trigger
language plpgsql
as $$
begin
    if exists (
        select 1 from film 
        where language_id = old.language_id
    ) then
        raise exception 'nao e permitido excluir este idioma, pois existem filmes vinculados';
    end if;
    return old;
end;
$$;

drop trigger if exists trg_check_language_delete on language;
create trigger trg_check_language_delete
before delete on language
for each row
execute function check_language_delete();

-- Questão 10
drop table if exists customer_rental_stats;
create table customer_rental_stats (
    customer_id int primary key,
    total_rentals int default 0
);

insert into customer_rental_stats (customer_id, total_rentals)
select customer_id, count(rental_id)
from rental
group by customer_id;

create or replace function update_customer_rental_stats()
returns trigger
language plpgsql
as $$
begin
    if exists (select 1 from customer_rental_stats where customer_id = new.customer_id) then
        update customer_rental_stats
        set total_rentals = total_rentals + 1
        where customer_id = new.customer_id;
    else
        insert into customer_rental_stats (customer_id, total_rentals)
        values (new.customer_id, 1);
    end if;
    return new;
end;
$$;

drop trigger if exists trg_update_customer_rental_stats on rental;
create trigger trg_update_customer_rental_stats
after insert on rental
for each row
execute function update_customer_rental_stats();
