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
      ('The new film wll have _ in the title');
select message from t;

select message from t
where message like '%10$%'