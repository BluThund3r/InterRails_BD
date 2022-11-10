--11.

--I.   (h, a, f, b)
-- Enunt:
--Afisati numele si prenumele calatorilor (care au id < 33 si care au cumparat bilete cu plecare inainte 
-- de ora 10:50) impreuna cu id-urile bucatarilor care gatesc meniurile comandate de catre calatorii 
-- respectivi; rezultatele sunt odonate descrescator dupa id-ul bucatarului

with temp_table as (
    select c.nume || ' ' || c.prenume as nume_prenume, buc.id_membru as bucatar from calatori c 
    join bilete b on b.id_calator = c.id_calator
    join meniuri m on m.denumire = b.denumire_meniu
    join gateste g on g.denumire_meniu = m.denumire
    join bucatari buc on buc.id_membru = g.id_membru
    where c.id_calator < 33 and b.ora_plecare < '10:50'
)
select nume_prenume, bucatar from temp_table
order by bucatar desc;



--II. (g - 5 functii pentru siruri de caractere, 2 functii pentru date calendaristice, case)
-- Enunt:
-- Afisati pentru fiecare angajat pentru care se cunoaste in ce tren(uri) a lucrat semnatura sa,
-- numarul trenului si mesajele: 
--      a. daca a lucrat in urma cu mai putin de un an in trenul respectiv, mesajul este "mai putin de un an"
--      b. daca a lucrat intre 1 si 2 ani in urma in trenul respectiv, mesajul este "intre un an si doi ani"
--      c. altfel "mai mult de doi ani"
-- Semnatura este formata prin concatenarea la prima litera a numelui angajatului (litera mica) primele 4 
-- litere din prenumele sau (litere mari)
-- Rezultatele sa fie ordonate crescator dupa semnatura.

select lower(chr(ascii(s.nume))) || upper(substr(s.prenume, 1, 4)) as semnatura, l.nr_tren, 
case
    when months_between(trunc(sysdate), l.data_ultima) < 12 then 'mai putin de un an'
    when months_between(trunc(sysdate), l.data_ultima) between 12 and 24 then 'intre un an si doi ani'
    else 'mai mult de doi ani'
end as rezultat
from lucreaza_in l
join staff s on s.id_membru = l.id_membru
order by semnatura;



--III. (e + g - NVL si DECODE)
-- Enunt:
-- Afisati numarul de calatori pentru fiecare gen, cu conditia ca exista mai mult de doi calatori pentru genul respectiv
-- Pentru genul M afisati 'Barbati', pentru F 'Femei', iar pentru cei care nu au genul specificat afisati 
-- 'Prefera sa nu spuna'.

with temp_table as (
    select gen, count(*) numar
    from calatori
    group by gen
    having count(*) > 2
)
select decode(nvl(gen, 'n/a'), 'M', 'Barbati', 'F', 'Femei', 'n/a', 'Prefera sa nu spuna') gen, numar
from temp_table;


--IV. (functie pentru siruri de caractere + c - cerere sincronizata cu 3 tabele + case + order by + nvl)
-- Enunt: 
-- Pentru fiecare client sa se afiseze numele si prenumele acestuia (pe aceeasi coloana)
-- si numele chelnerului de care a fost servit. In caz ca un calator a fost servit de 
-- mai multi chelneri, se va alege numele cel mai mare din punct de vedere lexicografic.
-- In cazul in care nu a fost servit, in dreptul calatorului se va afisa '???'.
-- Calatorii despre care nu se stie cine i-a servit vor aparea la final.

select concat(concat(c.nume, ' '), c.prenume) as calator,
nvl(
(
    select max(concat(concat(s.nume, ' '), s.prenume))
    from serveste serv
    join chelneri chel on serv.id_membru = chel.id_membru
    join staff s on s.id_membru = chel.id_membru
    where serv.id_calator = c.id_calator
    ), 
    '???') as chelner
from calatori c
order by chelner desc;


--V. (d - subcerere nesincronizata)
-- Enunt:
-- Pentru fiecare calator care a circulat cu un tren care a avut cel putin o revizie facuta
-- si care, in plus, a beneficiat vreodata de o reducere cu o valoare mai mare de 0.25
-- sa se afiseze numarul de tipuri de reduceri distincte de care a beneficiat de cand este
-- calator la aceast

select c.nume, count(distinct b.tip_reducere)
from calatori c
join bilete b on c.id_calator = b.id_calator
where c.id_calator in (
    select b.id_calator 
    from bilete b
    join reduceri red on b.tip_reducere = red.tip_reducere
    join trenuri t on b.nr_tren = t.nr_tren
    where t.ultima_revizie is not null and red.valoare_reducere > 0.25
)
group by c.nume;




--12.

-- sterge membrii staff-ului care au lucrat in trenuri fara revizie facuta
delete from staff where id_membru in (
    select id_membru 
    from lucreaza_in 
    join trenuri using (nr_tren)
    where ultima_revizie is null
);


rollback;


-- seteaza genul la M pentru calatorii care au fost sertivi vreun meniu ce contine 'cartofi' in denumire
-- iar id_ul chelnerului care l-a servit este mai mare decat 42
update calatori set gen = 'M' where id_calator in (
    select id_calator
    from serveste 
    where upper(denumire_meniu) like '%CARTOFI%' and id_membru > 42
);


rollback;


-- sterge biletele care circula pe o linie care nu se afla in baza de date
-- in cazul acesta nu sterge nimic pentru ca am adaugat toate legaturile intre toate
-- orasele din baza de date
delete from bilete
where (oras_plecare, oras_sosire) not in (
    select oras1, oras2 from legate
) and (oras_sosire, oras_plecare) not in (
    select oras1, oras2 from legate
);


rollback;






--13.
create sequence seq_inserare nocycle; -- + folosirea secventei pentru inserarea in tabele (punctul 10.)
drop sequence seq_inserare;






-- 14.
create view test_view as (
    select * from bilete
    join reduceri using(tip_reducere)
);  -- vizualizare compusa deoarece are mai multe tabele de baza (2 in acest caz)

select * from test_view;


update test_view set tip_reducere = 'Reducere ciudata' where ora_plecare = '07:20';  --exemplu de comanda
-- LMD care nu o sa functioneze, deoarece se incearca modificarea unei coloane a tabelului care nu este key-preserved

update test_view set nr_tren = 40 where ora_plecare = '07:20'; -- aceasta comanda o sa mearga, deoarece incearca sa modifice
-- coloana nr_tren, care face parte din tabelul bilete (acesta este tabelul key-preserved care participa la vizualizare), iar
-- acest lucru este permis

rollback;



--15.
-- un index
create index email1_email2_idx on calatori (email1, email2);
drop index email1_email2_idx;

select /*+ index(calatori email1_email2_idx) */ * from calatori
where email1 like 'a%' and email2 is null;



-- al doilea index

select /*+ index(calatori nume_prenume_clt_idx) */ * from calatori
where upper(nume) like 'S%' and prenume like '%';

create index nume_prenume_clt_idx on calatori (nume, prenume);
drop index nume_prenume_clt_idx;




--16.
-- query-uri de division: 
-- a. Sa se obtina numele si prenumele membrilor staff-ului care au lucrat macar o data in toate trenurile care 
--    au revizia facuta.

with temp_table as (
    select id_membru 
    from lucreaza_in
    where nr_tren in (
        select nr_tren
        from trenuri 
        where ultima_revizie is not null
    )
    group by id_membru
    having count(nr_tren) = (
        select count(*)
        from trenuri
        where ultima_revizie is not null
    )
)
select nume, prenume from staff where id_membru in (
    select id_membru from temp_table
);


-- b. Sa se afiseze numele, prenumele si numarul de stele pentru bucatarii care gatesc toate meniurile cu rating 5. 

with temp_table as (
    select id_membru 
    from gateste
    where denumire_meniu in (
        select denumire
        from meniuri 
        where rating = 5
    )
    group by id_membru
    having count(denumire_meniu) = (
        select count(*)
        from meniuri
        where rating = 5 
    )
)
select s.nume, s.prenume, b.stele
from staff s
join bucatari b on s.id_membru = b.id_membru
where b.id_membru in (
    select id_membru from temp_table
);

-- operatia de outer join intre 4 tabele
-- Enunt:
-- Afisati mesajele "Au lucrat in trenuri cu siguranta", respectiv "Nu stiu daca au lucrat in trenuri", fiecare fiind
-- urmat de numarul de controlori care corespund categoriei descrise de mesajul respectiv.

select * from lucreaza_in;

select 'Au lucrat in trenuri cu siguranta' as categorie, count(*) as numar from trenuri
full outer join lucreaza_in using(nr_tren)
full outer join staff using(id_membru)
full outer join controlori using(id_membru)
where nr_tren is not null and id_membru in (select id_membru from controlori)

union

select 'Nu stiu daca au lucrat in trenuri', count(*) 
from trenuri
full outer join lucreaza_in using(nr_tren)
full outer join staff using(id_membru)
full outer join controlori using(id_membru)
where nr_tren is null and id_membru in (select id_membru from controlori)
;
