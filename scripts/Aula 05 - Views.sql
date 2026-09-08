-- Relatorios de vendas de produtos (id, produto, qtd_vendida, total vendido)
drop view if exists v_product_sales;

create view v_product_sales as
select
    p.id as "id_produto",
    p.name as "nome_produto",
    sum(op.quantity) as "quantidade_vendida",
    sum(op.unit_price * op.quantity) as "total_vendido"
from products p 
join orders_products op 
    on p.id = op.product_id
join orders o 
    on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name;

-- select * from v_product_sales order by id_produto;

-- Relatorio detalhado de pedidos

drop view if exists v_details_orders;
create view v_details_orders as
select 
    u.id as "id_usuario",
    u.name as "nome_usuario",
    o.id as "id_pedido",
    o.order_date as "data_pedido",
    o.status as "status_pedido",
    o.total as "total_pedido",
    p.id as "id_produto",
    p.name as "nome_produto",
    op.quantity as "quantidade_produto",
    op.unit_price as "preco_unitario",
    op.unit_price * op.quantity as "total_produto"
from orders o
join users u on o.user_id = u.id
join orders_products op on o.id = op.order_id
join products p on op.product_id = p.id;

-- select * from v_details_orders order by "id_pedido";

-- Relatorio itens estoques
drop view if exists v_itens_estoque;
create view v_products_in_stock as
select
    id,
    name produto,
    price valor,
    stock estoque
from products
where stock > 0
order by estoque desc;

-- select * from v_products_in_stock;

-- Relatorio de produtos mais vendidos
drop view if exists v_top_products;
create view v_top_products as
select
    p.id id,
    p.name produto,
    sum(op.quantity) unid_vendidas,
    sum(op.quantity * op.unit_price) total_vendido
from products p 
join orders_products op on op.product_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name;

drop view if exists mv_top_products;
create materialized view mv_top_products as
select
    p.id id,
    p.name produto,
    sum(op.quantity) unid_vendidas,
    sum(op.quantity * op.unit_price) total_vendido
from products p 
join orders_products op on op.product_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name
with data; -- com dados
-- with NO data; --sem dados