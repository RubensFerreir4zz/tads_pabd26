insert into funcionario values 
('11122233388', 'João', 'Heli', 'joao@tads.ifrn', 'Natal-RN', '6400', '2000-09-10','M',null, null),
('22233344455', 'Maria', 'Silveira', 'maria@tads.ifrn', 'Mossoró-RN', '7900', '1999-08-15','F', null, null),
('33344455566', 'Pedro', 'Souza', 'pedro@tads.ifrn', 'Parnamirim-RN', '5900', '1995-05-05','M',null, null);

insert into funcionario (cpf,pnome,unome,email,salario,data_nasc,sexo) values
('44455566677', 'Ana', 'Silva', 'ana@tads.ifrn', '6400', '2000-09-10','F');


update funcionario
set salario = 6500
    endereco = 'Macau-RN'
where cpf = '44455566677'
returning cpf, pnome, salario, endereco;

delete from funcionario
where cpf = '44455566677'
returning *;



insert into departamento values
(1, 'TI', '11122233388', current_date),
(2, 'Fianceiro', '22233344455', current_date - interval '3 days'),
(3, 'RH', '33344455566', current_date - interval '5 days');


-- o supervisor de todos os funcionarios (exceto ele mesmo) será '11122233344'
update funcionario set cpf_supervisor = '11122233388'
where cpf <> '11122233388'

update funcionario
set numero_departamento = 1
where cpf in ('11122233388');

update funcionario
set numero_departamento = 2
where cpf in ('22233344455');

update funcionario
set numero_departamento = 3
where cpf in ('33344455566');