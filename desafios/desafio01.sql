-- Questão 01
drop materialized view if exists mv_driver_season_summary;
create materialized view mv_driver_season_summary as
select
    r.year as temporada,
    d.id as nome_piloto,
    count(*) as total_corridas,
    count(case when rd.position_number = 1 then 1 end) as vitorias,
    count(case when rd.position_number <= 3 then 1 end) as podios,
    count(case when rd.race_reason_retired is not null then 1 end) as abandonos,
    sd.total_points as total_pontos
from race_data rd
join race r on r.id = rd.race_id
join driver d on rd.driver_id = d.id
join season_driver sd on sd.driver_id = d.id and sd.year = r.year
where rd.type = 'RACE_RESULT'
group by r.year, d.id, sd.total_points;

create unique index idx_mv_driver_season_summary on mv_driver_season_summary (temporada, nome_piloto);

refresh materialized view concurrently mv_driver_season_summary;

select * from mv_driver_season_summary where nome_piloto = 'ayrton-senna';

-- Questão 02

DROP TABLE IF EXISTS points_adjustment_audit;
CREATE TABLE points_adjustment_audit (
    id         SERIAL PRIMARY KEY,
    year       INT NOT NULL,
    driver_id  VARCHAR(100) NOT NULL,
    old_points DECIMAL(8,2),
    new_points DECIMAL(8,2),
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

create or replace function audit_points_adjustment()
    returns trigger
    language plpgsql
as $$
begin
    insert into points_adjustment_audit (year, driver_id, old_points, new_points)
    values (NEW.year, NEW.driver_id, OLD.total_points, NEW.total_points);
    return NEW;
end;
$$;

drop trigger trg_audit_points_adjustment on season_driver;
create trigger trg_audit_points_adjustment
after update on season_driver
for each row
execute function audit_points_adjustment();

update season_driver
set total_points=total_points + 100
where year = 1993 and driver_id='ayrton-senna';

select * from points_adjustment_audit;

-- Questão 03
create or replace function delete_driver()
    returns trigger
    language plpgsql
as $$
begin
    if exists (select 1 from race_data where driver_id = OLD.id) then
        raise exception 'Driver % não pode ser excluído, pois possui registros na tabela race_data', OLD.full_name;
    end if;
    return OLD;
end;
$$;

drop trigger trg_delete_driver on driver;
create trigger trg_delete_driver
before delete on driver
for each row
execute function delete_driver();

delete from driver where id = 'ayrton-senna';

