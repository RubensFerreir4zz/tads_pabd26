select pnome, unome, numero_departamento from funcionario;

select pnome || ' ' || unome nome_completo from funcionario;

--alias

select pnome || ' ' || unome as "Nome Completo", numero_departamento as 'Dep' from funcionario;
select pnome || ' ' || unome nome, numero_departamento dep from funcionario;

select all numero_departamento from funcionario;
-- exbir valores distintos
select distinct numero_departamento from funcionario;

-- round
select pnome || ' ' || unome, nome, salario, round(salario*0.11, 2) inss from funcionario;


-- Filtro WHERE
select cpf, pnome, unome from funcionario
where endereco='Natal-RN';

select cpf, pnome, unome from funcionario
where numero_departamento=1 and salario > 9000;

select cpf, pnome, unome from funcionario
where salario >= 5000 and salario <= 7000;

select cpf, pnome, unome from funcionario
where salario between 5000 and 7000;

select cpf, pnome, unome from funcionario
where salario not between 5000 and 7000;

-- % -> substitui qualquer cadeia textual
-- _ -> substitui em caractere específico

select cpf, pnome, unome from funcionario
where endereco like '%RN';

select cpf, pnome, unome from funcionario
where pnome like '%ri%';

select cpf, pnome, unome from funcionario
where endereco like '%R_';

select cpf, pnome, unome from funcionario
where endereco like '%R_';


create table t(
    message text
);

insert into t(message)
values('The rants are now 10% higher than last month'),
      ('The new film will have _ in the title');
select message from t;

select message from t
where message like '%10$%' escape '$';

select * from funcionario
order by pnome, unome;

select * from funcionario
order by pnome, unome desc
;
select * from funcionario
order by pnome desc, unome desc;

select * from funcionario
order by salario desc
limit 1; -- O limit serve para restringir o número de linhas retornadas.

-- Funções de agregação: count, sum, avg, max, min

select count(*) total_funcionarios from funcionario;

select count(distinct numero_departamento) from funcionario;

select sum(salario) as "Folha Salarial" from funcionario where numero_departamento=1;

select avg(salario) media_salarial from funcionario;

select round(avg(salario), 2) media_salarial from funcionario;

select min(salario) menor_salario, max(salario) maior_salario from funcionario;


select pnome, unome, from funcionario
where salario = (select min(salario) from funcionario);



select pnome, unome from funcionario
where salario > (select avg(salario) from funcionario);


select 
    count(*) total_funcionarios, 
    sum(salario) folha_salarial, 
    round(sum(salario)*0.11,2) folha_inss, 
    round(avg(salario), 2) media_salarial,
    min(salario) menor_salario, 
    max(salario) maior_salario 
from funcionario;


-- Listar funcionários e seus respectivos nomes de departamentos
select
    f.pnome || ' ' || f.unome funcionario,
    d.nome departamento
from funcionario f
join departamento d
    on f.numero_departamento = d.numero
order by d.nome, f.pnome;

select
    f.pnome || ' ' || f.unome as funcionario,
    s.pnome || ' ' || s.unome as supervisor
from funcionario f
join funcionario s
    on f.cpf_supervisor = s.cpf
order by f.pnome, f.unome;

select
    f.pnome || ' ' || f.unome as funcionario,
    coalesce(s.pnome || ' ' || s.unome, 'Sem supervisor') as supervisor
from funcionario f
left join funcionario s
    on f.cpf_supervisor = s.cpf
order by s.pnome nulls last, f.pnome, f.unome;

select
    f.pnome || ' ' || f.unome as funcionario,
    coalesce(s.pnome || ' ' || s.unome, 'Sem supervisor') as supervisor
from funcionario f
right join funcionario s
    on f.cpf_supervisor = s.cpf
order by s.pnome nulls last, f.pnome, f.unome;

update funcionario
set numero_departamento = null
where cpf = '22233344455';

insert into departamento(numero, nome, cpf_gerente, data_ini)
values(4, 'Marketing', null, current_date );

select
    coalesce(d.nome, 'Sem departamento') as departamento,
    coalesce(f.pnome || ' ' || f.unome, 'Sem funcionario') as funcionario
from departamento d
full join funcionario f
    on f.numero_departamento = d.numero
order by departamento nulls last, funcionario nulls last;

select f.pnome || ' ' || f.unome as funcionario 
from funcionario f
where exists(
    select *
    from departamento d 
    where f.cpf = d.cpf_gerente
)
order by funcionario;

    
select f.pnome || ' ' || f.unome as funcionario 
from funcionario f
where not exists(
    select *
    from departamento d 
    where f.cpf = d.cpf_gerente
)
order by funcionario;

-- Exibe valor nulo
select 
    coalesce(numero_departamento, 'Sem departamento') as departamento,
    round(avg(salario), 2) as media_salarial
from funcionario
group by numero_departamento
order by numero_departamento;

--Não exibe valor nulo (WHERE)
select 
    numero_departamento,
    round(avg(salario), 2) as media_salarial
from funcionario
where numero_departamento is not null
group by numero_departamento
order by numero_departamento;

--Não exibe valor nulo (HAVING)
select 
    numero_departamento,
    round(avg(salario), 2) as media_salarial
from funcionario
group by numero_departamento
having numero_departamento is not null
order by numero_departamento;

select
    numero_departamento,
    count(*) as total_funcionarios
from funcionario
group by numero_departamento
having numero_departamento is not null
order by total_funcionarios desc;

-- Lista número e nome do departamento, quantidade de funcionarios, media_salarial e folha salarial
select 
    d.numero,
    d.nome,
    count(f.cpf) qtd_funcionarios,
    round(avg(f.salario),2) media_salarial,
    sum(f.salario) folha_salarial
from funcionario f
right join departamento d
    on f.numero_departamento = d.numero
group by d.numero
order by qtd_funcionarios desc;