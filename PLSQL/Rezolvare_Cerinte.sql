--4.
create table CALATORI (
    id_calator number(8),
    nume varchar2(50) not null, 
    prenume varchar2(50) not null,
    varsta number(2) not null, 
    email1 varchar2(50) not null,
    email2 varchar2(50),
    telefon varchar2(50) not null unique,
    gen char(1),
    constraint CALATORI_PK primary key (id_calator),
    constraint gen_calatori_CK check(gen = 'M' or gen = 'F' or gen is null)
);

-- M-am gandit sa modific structura tabelului calatori, insa implementasem deja toata structura bazei de date, 
-- asa ca am ales sa fac aceasta modificare cu alter;
/
create or replace type vector_email is varray(2) of varchar(50);
/
create or replace type tabel_telefon is table of varchar(50);
/
alter table calatori add email vector_email not null;
alter table calatori add numere_telefon tabel_telefon
nested table numere_telefon store as nr_telefon;
alter table calatori drop column email1;
alter table calatori drop column email2;
alter table calatori drop column telefon;

create table TRENURI (
    nr_tren number(6),
    an_fabricatie number(4) default 2010,
    data_achizitie date default sysdate,
    firma varchar2(30) not null,
    ultima_revizie date,
    nr_vagoane number(2) default 1,
    constraint TRENURI_PK primary key (nr_tren),
    constraint an_fabricatie_CK check (an_fabricatie between 2010 and 2022),
    constraint nr_vagoane_CK check (nr_vagoane between 1 and 10)
);

create table STAFF (
    id_membru number(3),
    nume varchar2(50) not null,
    prenume varchar2(50) not null,
    data_angajare date default sysdate,
    salariu number(5) not null,
    constraint STAFF_PK primary key (id_membru)
);

create table CONTROLORI (
    id_membru number(3),
    politete number(1) default 1,
    constraint politete_CK check (politete between 1 and 5),
    constraint CONTROLORI_PK primary key (id_membru),
    foreign key (id_membru) references staff(id_membru) on delete cascade
);

create table BUCATARI (
    id_membru number(3),
    stele number(1) default 1,
    constraint stele_CK check (stele between 1 and 5),
    constraint BUCATARI_PK primary key (id_membru),
    foreign key (id_membru) references staff(id_membru) on delete cascade
);

create table CHELNERI (
    id_membru number(3),
    rating number(1) default 1,
    constraint rating_cheler_CK check (rating between 1 and 5),
    constraint CHELNERI_PK primary key (id_membru),
    foreign key (id_membru) references staff(id_membru) on delete cascade
);

create table MENIURI (
    id_meniu number,
    denumire_meniu varchar2(50),
    rating number(1) default 1,
    constraint MENIURI_PK primary key (id_meniu),
    constraint rating_meniu_check check (rating between 1 and 5)
);

create table REDUCERI (
    tip_reducere varchar(20),
    valoare_reducere number(3, 2),
    constraint REDUCERI_PK primary key (tip_reducere),
    constraint valoare_reducere_CK check(valoare_reducere between 0 and 1)
);

create table ORASE (
    id_oras varchar(10),
    nume varchar2(40) not null,
    nume_tara varchar(40) not null,
    constraint orase_pk primary key (id_oras)
);

create table RUTE (
    id_ruta number,
    id_oras_plecare varchar(20),
    id_oras_sosire varchar(20),
    distanta number,
    constraint rute_pk primary key (id_ruta),
    constraint oras_plecare_fk foreign key (id_oras_plecare) references orase(id_oras),
    constraint oras_sosire_fk foreign key (id_oras_sosire) references orase(id_oras),
    constraint chk_orase_diferite check(id_oras_plecare <> id_oras_sosire)
);

create table BILETE (
    id_bilet number(8),
    id_calator number(8),
    tip_reducere varchar2(20),
    nr_tren number(6) not null,
    id_meniu number,
    id_ruta number not null,
    ora_plecare char(5),
    data_plecare date,
    ora_sosire char(5) not null,
    data_sosire date not null,
    pret_initial number(5, 2) not null,
    pret_final number(5, 2) not null,
    constraint BILETE_PK primary key (id_bilet),
    foreign key (id_calator) references CALATORI(id_calator) on delete cascade,
    foreign key (tip_reducere) references REDUCERI(tip_reducere) on delete cascade,
    foreign key (nr_tren) references TRENURI(nr_tren) on delete cascade,
    foreign key (id_meniu) references MENIURI(id_meniu) on delete set null,
    foreign key (id_ruta) references RUTE(id_ruta) on delete cascade
);

create table LUCREAZA_IN (
    nr_tren number(6), 
    id_membru number(3), 
    data_ultima date default sysdate,
    constraint LUCREAZA_IN_PK primary key (nr_tren, id_membru),
    foreign key (id_membru) references STAFF(id_membru) on delete cascade,
    foreign key (nr_tren) references TRENURI(nr_tren) on delete cascade
);

create table SERVESTE (
    id_membru number(3),
    id_calator number(8),
    id_meniu number,
    constraint SERVESTE_PK primary key (id_membru, id_calator, id_meniu),
    foreign key (id_membru) references CHELNERI(id_membru) on delete cascade,
    foreign key (id_calator) references CALATORI(id_calator) on delete cascade,
    foreign key (id_meniu) references MENIURI(id_meniu) on delete cascade
);

create table GATESTE (
    id_membru number(3),
    id_meniu number,
    constraint GATESTE_PK primary key (id_membru, id_meniu),
    foreign key (id_membru) references bucatari(id_membru) on delete cascade,
    foreign key (id_meniu) references meniuri(id_meniu) on delete cascade
);                                                         

create table CONTROLEAZA(
    id_bilet number(8),
    id_membru number(3),
    constraint controleaza_pk primary key (id_bilet, id_membru),
    foreign key (id_bilet) references bilete(id_bilet) on delete cascade,
    foreign key (id_membru) references controlori(id_membru) on delete cascade
);  

--5.
--CALATORI
insert into calatori(id_calator, nume, prenume, varsta, email, numere_telefon, gen)
values (19, 'Pop', 'Andrei', 30, vector_email('andrei_pop@gmail.com'), tabel_telefon('0712345719'), 'M');

insert into calatori(id_calator, nume, prenume, varsta, email, numere_telefon, gen)
values (20, 'Muresan', 'Vicentiu', 28, vector_email('muresvice@gmail.com', 'muresvice1@gmail.com'), tabel_telefon('0757843191'), 'M');

insert into calatori(id_calator, nume, prenume, varsta, email, numere_telefon, gen)
values (21, 'Constantinescu', 'Catalin', 18, vector_email('cataconstantin@gmail.com'), tabel_telefon('0712345718'), null);

insert into calatori(id_calator, nume, prenume, varsta, email, numere_telefon, gen)
values (22, 'Pindaru', 'Adelina', 40, vector_email('pindaruAdelina@gmail.com', 'adelinapin@gmail.com'), tabel_telefon('0712345710'), 'F');

insert into calatori(id_calator, nume, prenume, varsta, email, numere_telefon, gen)
values (23, 'Pavel', 'Doina', 45, vector_email('doina_pavel@gmail.com'), tabel_telefon('0749135476'), 'F');

insert into calatori(id_calator, nume, prenume, varsta, email, numere_telefon, gen)
values (24, 'Dobrica', 'Casiana-Elena', 25, vector_email('casyelena@gmail.com', 'elena.casiana-dobrica@gmail.com'), tabel_telefon('0772149658'), null);

insert into calatori(id_calator, nume, prenume, varsta, email, numere_telefon)
values(25, 'Savoiu', 'Mincu', 30, vector_email('savoiumin@yahoo.com'), tabel_telefon('0716495137'));

insert into calatori(id_calator, nume, prenume, varsta, email, numere_telefon, gen)
values(26, 'Sancu', 'Monica', 23, vector_email('monicasan@outlook.com'), tabel_telefon('0716496257'), 'F');

insert into calatori(id_calator, nume, prenume, varsta, email, numere_telefon, gen)
values(27, 'Samburel', 'Alexandra-Mirela', 32, vector_email('alexymirela@gmail.com'), tabel_telefon('0756713498'), 'F');

commit;
select * from calatori;

--TRENURI 
insert into trenuri(nr_tren, an_fabricatie, firma)
values(28, 2011, 'Rails2GO');

insert into trenuri
values(29, 2019, to_date('15-08-2020', 'DD-MM-YYYY'), 'TrainsForever', null, 8);

insert into trenuri
values(30, 2015, to_date('16-06-2016', 'DD-MM-YYYY'), 'TrainsForever', to_date('27-04-2018', 'DD-MM-YYYY'), 4);

insert into trenuri
values(31, 2017, to_date('15-08-2017', 'DD-MM-YYYY'), 'Rails2Go', to_date('19-05-2021', 'DD-MM-YYYY'), 2);

insert into trenuri
values(32, 2010, to_date('20-09-2019', 'DD-MM-YYYY'), 'TrailLover', null, 5);

insert into trenuri 
values(75, 2017, sysdate - 30, 'TrailLover', null, 3);

commit;
select * from trenuri;

--STAFF + BUCATARI
insert into staff(id_membru, nume, prenume, data_angajare, salariu)
values(33, 'Dumitru', 'Adela', to_date('15-02-2013', 'DD-MM-YYYY'), 5000);

insert into bucatari(id_membru, stele)
values(33, 4);

insert into staff(id_membru, nume, prenume, salariu)
values(34, 'Vlasceanu', 'Diana', 7000);

insert into bucatari(id_membru)
values(34);

insert into staff(id_membru, nume, prenume, salariu)
values(35, 'Dinu', 'Lucian', 6000);

insert into bucatari(id_membru, stele)
values(35, 5);

insert into staff(id_membru, nume, prenume, salariu)
values(36, 'Ifrim', 'Andrei', 10000);

insert into bucatari(id_membru, stele)
values(36, 2);

insert into staff(id_membru, nume, prenume, salariu)
values(37, 'Stanciu', 'Horia', 12000);

insert into bucatari(id_membru, stele)
values(37, 5);

commit;
select * from staff;
select * from bucatari;

--STAFF + CONTROLORI
insert into staff(id_membru, nume, prenume, salariu)
values(38, 'Sava', 'Alexandru', 5500);

insert into controlori(id_membru, politete)
values(38, 5);

insert into staff(id_membru, nume, prenume, salariu)
values(39, 'Manole', 'Iulian-George', 6500);

insert into controlori(id_membru)
values(39);

insert into staff(id_membru, nume, prenume, salariu)
values(40, 'Popescu', 'Madalina-Andreea', 7800);

insert into controlori(id_membru, politete)
values(40, 4);

insert into staff(id_membru, nume, prenume, salariu)
values(41, 'Nita', 'Loredana Monica', 4500);

insert into controlori(id_membru)
values(41);

insert into staff(id_membru, nume, prenume, salariu)
values(42, 'Tomescu', 'Sebastian Emil', 9000);

insert into controlori(id_membru, politete)
values(42, 3);

commit;
select * from staff;
select * from controlori;

--STAFF + CHELNERI
insert into staff(id_membru, nume, prenume, salariu)
values(43, 'Pavel', 'Narcisa', 4000);

insert into chelneri(id_membru, rating)
values(43, 2);

insert into staff(id_membru, nume, prenume, salariu)
values(44, 'Olteanu', 'Stefania-Maria', 6500);

insert into chelneri(id_membru, rating)
values(44, 4);

insert into staff(id_membru, nume, prenume, salariu)
values(45, 'Ciocu', 'Bogdan Constantin', 7500);

insert into chelneri(id_membru, rating)
values(45, 5);

insert into staff(id_membru, nume, prenume, salariu)
values(46, 'Craciun', 'Cristina', 8000);

insert into chelneri(id_membru, rating)
values(46, 5);

insert into staff(id_membru, nume, prenume, salariu)
values(47, 'Pascu', 'Mirel Petre', 3500);

insert into chelneri(id_membru)
values(47);

commit;
select * from staff;
select * from chelneri;

--MENIURI
insert into meniuri(id_meniu, denumire_meniu, rating)
values(48, 'Pulpe de pui la cuptor cu cartofi si salata', 4);

insert into meniuri(id_meniu, denumire_meniu, rating)
values(49, 'Piure de cartofi cu friptura de porc', 5);

insert into meniuri(id_meniu, denumire_meniu, rating)
values(50, 'Ciorba de fasole in paine', 5);

insert into meniuri(id_meniu, denumire_meniu, rating)
values(51, 'Paste carbonara', 2);

insert into meniuri(id_meniu, denumire_meniu, rating)
values(52, 'Paella', 2);

insert into meniuri(id_meniu, denumire_meniu, rating)
values(53, 'Cartofi prajiti cu piept de pui la gratar', 3);

commit;
select * from meniuri;

--REDUCERI
insert into reduceri(tip_reducere, valoare_reducere)
values('Student 50%', 0.5);

insert into reduceri(tip_reducere, valoare_reducere)
values('Elev 50%', 0.5);

insert into reduceri(tip_reducere, valoare_reducere)
values('Donator sange 25%', 0.25);

insert into reduceri(tip_reducere, valoare_reducere)
values('Veteran Razboi 75%', 0.75);

insert into reduceri(tip_reducere, valoare_reducere)
values('Nevoi speciale 50%', 0.5);

commit;
select * from reduceri;

--ORASE
insert into orase(id_oras, nume, nume_tara)
values('BuchRO', 'Bucuresti', 'Romania');

insert into orase(id_oras, nume, nume_tara)
values('RomeIT', 'Roma', 'Italia');

insert into orase(id_oras, nume, nume_tara)
values('MadridSP', 'Madrid', 'Spania');

insert into orase(id_oras, nume, nume_tara)
values('ParisFR', 'Paris', 'Franta');

insert into orase(id_oras, nume, nume_tara)
values('BerlinD', 'Berlin', 'Germania');

commit;
select * from orase;

--RUTE
insert into rute values(55, 'BuchRO', 'RomeIT', 2050);
insert into rute values(56, 'BerlinD', 'RomeIT', 1600);
insert into rute values(57, 'MadridSP', 'ParisFR', 1300);
insert into rute values(58, 'ParisFR', 'MadridSP', 1300);
insert into rute values(59, 'BuchRO', 'BerlinD', 1700);

commit;
select * from rute;

--BILETE
insert into bilete(id_bilet, id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    id_meniu, id_ruta)
values(67, 19, '10:50', to_date('18-06-2022', 'DD-MM-YYYY'), '10:50', to_date('18-06-2022', 'DD-MM-YYYY') + 1, 70.50, null, 70.50, 28, 48, 55);

insert into bilete(id_bilet, id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    id_meniu, id_ruta)
values(68, 20, '06:57', to_date('18-06-2022', 'DD-MM-YYYY'), '00:26', to_date('18-06-2022', 'DD-MM-YYYY') + 1, 100, 'Elev 50%', 50, 29, 52, 56);

insert into bilete(id_bilet, id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    id_meniu, id_ruta)
values(69, 23, '08:49', to_date('18-06-2022', 'DD-MM-YYYY'), '23:56', to_date('18-06-2022', 'DD-MM-YYYY'), 80, 'Student 50%', 40, 30, null, 57);

insert into bilete(id_bilet, id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    id_meniu, id_ruta)
values(70, 25, '13:05', to_date('18-06-2022', 'DD-MM-YYYY'), '10:16', to_date('18-06-2022', 'DD-MM-YYYY') + 1, 150, 'Donator sange 25%', 112.5, 31, 52, 58);

insert into bilete(id_bilet, id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    id_meniu, id_ruta)
values(71, 26, '05:36', to_date('12-07-2019', 'DD-MM-YYYY'), '22:41', to_date('13-07-2019', 'DD-MM-YYYY') + 1, 120, null, 120, 32, null, 59);

insert into bilete(id_bilet, id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    id_meniu, id_ruta)
values(72, 24, '07:20', to_date('15-08-2020', 'DD-MM-YYYY'), '03:25', to_date('15-08-2020', 'DD-MM-YYYY') + 1, 110, 'Elev 50%', 55, 28, 49, 55);

commit;
select * from bilete;


--LUCREAZA_IN
insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(28, 38, to_date('25-03-2018', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(29, 39, to_date('25-03-2018', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(30, 41, to_date('26-04-2019', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(28, 45, to_date('02-01-2023', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(32, 46, to_date('10-11-2019', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(31, 39, to_date('02-01-2023', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(30, 43, to_date('02-01-2023', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(29, 47, to_date('06-12-2021', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(31, 40, to_date('05-02-2019', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(32, 45, to_date('02-01-2023', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(28, 33, to_date('13-05-2022','DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(31, 37, to_date('13-05-2022','DD-MM-YYYY'));

insert into lucreaza_in (id_membru, nr_tren, data_ultima)
values(39, 75, to_date('04-01-2023', 'DD-MM-YYYY'));

insert into lucreaza_in (id_membru, nr_tren, data_ultima)
values(40, 75, to_date('04-01-2023', 'DD-MM-YYYY'));

insert into lucreaza_in(id_membru, nr_tren, data_ultima)
values(35, 28, to_date('07-01-2023', 'DD-MM-YYYY'));

commit;    
select * from lucreaza_in;

--SERVESTE
insert into serveste(id_membru, id_calator, id_meniu)
values(45, 21, 48);
insert into serveste(id_membru, id_calator, id_meniu)
values(45, 25, 50);
insert into serveste(id_membru, id_calator, id_meniu)
values(47, 22, 49);
insert into serveste(id_membru, id_calator, id_meniu)
values(43, 24, 52);
insert into serveste(id_membru, id_calator, id_meniu)
values(45, 21, 51);
insert into serveste(id_membru, id_calator, id_meniu)
values(43, 24, 53);
insert into serveste(id_membru, id_calator, id_meniu)
values(47, 25, 49);
insert into serveste(id_membru, id_calator, id_meniu)
values(46, 23, 48);
insert into serveste(id_membru, id_calator, id_meniu)
values(47, 26, 50);
insert into serveste(id_membru, id_calator, id_meniu)
values(44, 25, 50);

commit;
select * from serveste;

--GATESTE
insert into gateste(id_membru, id_meniu)
values(36, 50);
insert into gateste(id_membru, id_meniu)
values(33, 52);
insert into gateste(id_membru, id_meniu)
values(34, 51);
insert into gateste(id_membru, id_meniu)
values(33, 48);
insert into gateste(id_membru, id_meniu)
values(35, 50);
insert into gateste(id_membru, id_meniu)
values(34, 49);
insert into gateste(id_membru, id_meniu)
values(34, 48);
insert into gateste(id_membru, id_meniu)
values(35, 53);
insert into gateste(id_membru, id_meniu)
values(36, 52);
insert into gateste(id_membru, id_meniu)
values(37, 53);
insert into gateste(id_membru, id_meniu)
values(36, 53);
commit;
select * from gateste;


--CONTROLEAZA
insert into controleaza(id_bilet, id_membru)
values(72, 38);
insert into controleaza(id_bilet, id_membru)
values(72, 39);
insert into controleaza(id_bilet, id_membru)
values(69, 40);
insert into controleaza(id_bilet, id_membru)
values(70, 38);
insert into controleaza(id_bilet, id_membru)
values(68, 38);
insert into controleaza(id_bilet, id_membru)
values(69, 41);
insert into controleaza(id_bilet, id_membru)
values(69, 38);
insert into controleaza(id_bilet, id_membru)
values(67, 41);
insert into controleaza(id_bilet, id_membru)
values(71, 39);
insert into controleaza(id_bilet, id_membru)
values(67, 42);
insert into controleaza(id_bilet, id_membru)
values(70, 41);

commit;
select * from controleaza;
/
-- !!!!!!!!!!!INAINTE DE A RULA EXERCITIILE 6 SI 9, RULATI EXERCITIUL 14!!!!!!!!!!!!!!
-- Am creeat un pachet cu exceptii pentru a avea la un loc exceptiile 
-- definite de mine si folosite in afara subprogramelor
create or replace package exceptii is
    operatie_invalida exception;
    limita_email_depasita exception;
    pragma exception_init(operatie_invalida, -20001);
    pragma exception_init(limita_email_depasita, -20002);
end;

--6.
-- Sunt date doua fisiere: 'data_phone.txt' si 'data_email.txt', ambele continand
-- informatii pe mai multe linii. Fiecare linie din fiecare fisier contine informatii
-- sub urmatoarea forma: <id_calator>,<informatie>, unde <informatie> este fie
-- un numar de telefon, fie o adresa de email, in functie de fisier.
-- Scrieti o procedura care are 2 parametri:
-- - operatie (varchar - 'update_phone' / 'update_email' non-case sensitive; parametru intrare)
-- - nr_calatori_actualizati (numarul calatorilor actualizati; id-urile se pot repeta in fisier;
--   parametru iesire)
-- Procedura va efectua urmatoarele operatii:
-- a)   update_phone: citeste din fisierul 'data_phone.txt' si actualizeaza tabelul 
--      CALATORI inserand pentru fiecare id_calator numarul respectiv de telefon in lista 
--      corespunzatoare lui din baza de date
-- b)   update_email: citeste din fisierul 'data_email.txt' si actualizeaza tabelul
--      CALATORI inserand pentru fiecare id_calator email-ul respectiv in lista
--      corespunzatoare lui din baza de date; daca un calator are deja 2 email-uri
--      atunci se va intrerupe executia procedurii in momentul respectiv.
/
create or replace procedure update_phone_email(operatie in varchar, nr_calatori_actualizati out nocopy number)
is  -- ultimul atribut este nocopy pentru ca procedura sa imi puna valoarea in aceasta variabila chiar si daca are loc
    -- o eroare (raise_application_error)
    file_handle utl_file.file_type;
    fline varchar(100);
    type indexed_table is table of number index by pls_integer;
    hash_table indexed_table;
    words extra_pack.varchar_table := extra_pack.varchar_table();
    v_email vector_email;
    v_id_calator number;
begin
    if lower(operatie) = 'update_phone' then
        file_handle := utl_file.fopen('FILE_DIR', 'data_phone.txt', 'r');
        loop
            begin
                utl_file.get_line(file_handle, fline);
            exception 
                when no_data_found then exit;
            end;
        
        words := extra_pack.sparge_string_regex(fline, '[^,]+');
        v_id_calator := to_number(words(1));
        if not hash_table.exists(v_id_calator) then
            hash_table(v_id_calator) := 1;
        end if;
        
        insert into table(select numere_telefon from calatori where id_calator = v_id_calator)
        values(words(2));
        
        end loop;
        
        nr_calatori_actualizati := hash_table.count;
        utl_file.fclose(file_handle);
        
    elsif lower(operatie) = 'update_email' then
        file_handle := utl_file.fopen('FILE_DIR', 'data_email.txt', 'r');
        loop
            begin
                utl_file.get_line(file_handle, fline);
            exception 
                when no_data_found then exit;
            end;
        
        
        words := extra_pack.sparge_string_regex(fline, '[^,]+');
        v_id_calator := to_number(words(1));
        select email into v_email from calatori where id_calator = v_id_calator;
        if v_email.count = 2 then 
            nr_calatori_actualizati := hash_table.count;
            raise_application_error(-20002, 'Calatorul cu id-ul ' || v_id_calator || ' are deja 2 adrese de email');
        end if;
        
        if not hash_table.exists(v_id_calator) then
            hash_table(v_id_calator) := 1;
        end if;
        
        v_email.extend;
        v_email(v_email.last) := words(2);
        update calatori
        set email = v_email
        where id_calator = v_id_calator;
        
        end loop;
        
        nr_calatori_actualizati := hash_table.count;
        utl_file.fclose(file_handle);
    else
        raise_application_error(-20001, 'Operatia "' || operatie || '" nu este cunoscuta!');
    end if;
end;

/
declare
    nr_return number;
begin
    update_phone_email('update_phone', nr_return);
    dbms_output.put_line('S-au actualizat ' || nr_return || ' inregistrari');
exception
    when exceptii.operatie_invalida then
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Incercati o operatie permisa: "update_phone" / "update_email"');
    when exceptii.limita_email_depasita then
        dbms_output.put_line(SQLERRM);
        if nr_return = 0 then
            dbms_output.put_line('Nu s-a actualizat nici o inregistrare');
        elsif nr_return = 1 then
            dbms_output.put_line('S-a actualizat doar o inregistrare');
        else 
            dbms_output.put_line('S-au actualizat doar ' || nr_return || ' inregistrari');
        end if;
end;
/
select * from calatori;
rollback;

-- 7.
-- Pentru toti conrolorii cu o valoarea a politetii mai mare sau egala decat una data sa se afiseze numele, prenumele, salariul
-- si top-ul primelor 5 trenuri (numar, an fabricatie) in care acestia au lucrat. Ordinea in care vor aparea trenurile in top va 
-- fi data de anul fabricatiei acestora (desc). Daca doua trenuri sunt fabricate in acelasi an, acestea 
-- vor ocupa aceeasi pozitie in top-ul respectiv. Daca nu exista date despre faptul ca un controlor
-- ar fi lucrat in vreun tren, atunci afisati un mesaj corespunzator in loc de top-ul trenurilor.
-- Daca un controlor nu a lucrat in suficiente trenuri astfel incat sa se intocmeasca un top 5 pentru acesta, se va afisa top-ul 
-- pana la pozitia la care se poate ajunge cu datele din baza de date.
-- La final afisati si numarul controlorilor care au lucrat in cel putin un tren, dar si media salariilor acestora.
/
create or replace procedure afis_info_controlori_politete(min_politete in number) is
    cursor expr_curs(polit number) is
        select s.nume, s.prenume, s.salariu, cursor (
            select t.nr_tren, t.an_fabricatie
            from lucreaza_in l
            join trenuri t on l.nr_tren = t.nr_tren
            where l.id_membru = s.id_membru
            order by an_fabricatie desc 
        )
        from controlori c
        join staff s on c.id_membru = s.id_membru
        where c.politete >= polit;
    
    v_cursor sys_refcursor;
    v_nume varchar(50);
    v_prenume varchar(50);
    v_salariu number;
    v_nr_tren number;
    v_an_fabricatie number;
    counter_lucrat number;
    top_counter number;
    prev_an_fabricatie number(4);
    suma_salariu number;
begin
    open expr_curs(min_politete);
    counter_lucrat := 0;
    suma_salariu := 0;
    loop
        fetch expr_curs into v_nume, v_prenume, v_salariu, v_cursor;
        exit when expr_curs%notfound;
        
        dbms_output.put_line(v_nume || ' ' || v_prenume || ' - ' || v_salariu);
        dbms_output.put_line('-----------------------------------');
        
        top_counter := 0;
        prev_an_fabricatie := 0;
        loop
            fetch v_cursor into v_nr_tren, v_an_fabricatie;
            if top_counter = 0 and v_cursor%notfound then
                dbms_output.put_line('Acest controlor nu a lucrat in nici un tren');
                exit;
            end if;
            exit when v_cursor%notfound;
            
            if v_an_fabricatie <> prev_an_fabricatie then
                top_counter := top_counter + 1;
            end if;
            
            dbms_output.put_line(top_counter || '. NR: ' || v_nr_tren || ' -> AN:' || v_an_fabricatie);
            
            prev_an_fabricatie := v_an_fabricatie;
        end loop;
        
        if top_counter > 0 then
            counter_lucrat := counter_lucrat + 1;
            suma_salariu := suma_salariu + v_salariu;
        end if;
        
        dbms_output.new_line;
        dbms_output.new_line;
        
    end loop;
    
    if counter_lucrat > 0 then
        dbms_output.put_line(counter_lucrat || ' controlori cu politete mai mare sau egala decat ' || min_politete || ' de au lucrat in cel putin un tren');
        dbms_output.put_line('Media salariilor acestora este: ' || round(suma_salariu / counter_lucrat, 2));
    else
        dbms_output.put_line('Nici un controlor cu politete de cel putin ' || min_politete || 'nu a lucrat in vreun tren pana acum');
    end if;
end;
/

execute afis_info_controlori_politete(2);
/

-- 8.
--Determinati numele complet (nume + prenume) al calatorilor care au fost serviti de catre un chelner al carui
--rating este dat, cu un meniu al carui rating este dat. Rezultatul va fi un varchar ce contine numele complete
--separate prin virgula si spatiu. Tratati cazul in care nu exista nici un chelner cu rating-ul specificat, cel
--in care nu exista nici un meniu cu rating-ul specificat, cel in care cel putin unul dintre rating-uri are valori
--invalide, respectiv cel in care nici un calator satisface cerinta.

create or replace function nr_calatori_chelner_meniu(p_rating_angajat in number, p_rating_meniu in number) 
return varchar is
    cursor c_chelneri is
        select id_membru from chelneri where rating = p_rating_angajat;
    cursor c_meniu is 
        select id_meniu from meniuri where rating = p_rating_meniu;
    cursor c_principal(p_rating number, p_id_meniu number) is
        select c.nume || ' ' || c.prenume nume_complet from serveste s
        join calatori c on c.id_calator = s.id_calator
        join chelneri ch on ch.id_membru = s.id_membru
        where s.id_meniu = p_id_meniu and ch.rating = p_rating;
        
    rating_out_of_range exception;
    no_waiter exception;
    no_menu exception;
    no_names exception;
    pragma exception_init(rating_out_of_range, -20003);
    pragma exception_init(no_waiter, -20004);
    pragma exception_init(no_menu, -20005);
    pragma exception_init(no_names, -20006);
    dummy number;
    string_nume varchar(256);
    empty_string boolean := true;
begin
    if p_rating_angajat < 1 or p_rating_angajat > 5 or p_rating_meniu < 1 or p_rating_meniu > 5 then
        raise rating_out_of_range;
    end if;
    
    open c_chelneri;
    fetch c_chelneri into dummy;
    
    if c_chelneri%notfound then
        close c_chelneri;
        raise no_waiter;
    end if;
    close c_chelneri;
    
    open c_meniu;
    fetch c_meniu into dummy;
    if c_meniu%notfound then
        close c_meniu;
        raise no_menu;
    end if;
    close c_meniu;
    
    for rec1 in c_meniu loop
        for rec2 in c_principal(p_rating_angajat, rec1.id_meniu) loop
            if empty_string then
                string_nume := string_nume || rec2.nume_complet;
                empty_string := false;
            else
                string_nume := string_nume || ', ' || rec2.nume_complet;
            end if;
        end loop;
    end loop;
    
    if empty_string then
        raise no_names;
    end if;
    
    return string_nume;
exception
    when rating_out_of_range then
        dbms_output.put_line('Unul dintre rating-uri nu este intre valorile permise (1-5)');
        return '';
    when no_waiter then
        dbms_output.put_line('Nu exista nici un chelner cu rating-ul ' || p_rating_angajat);
        return '';
    when no_menu then
        dbms_output.put_line('Nu exista nici un meniu cu rating-ul ' || p_rating_meniu);
        return '';
    when no_names then
        dbms_output.put_line('Nu exista calatori care sa fi fost servit de catre un chelner cu rating-ul '
        || p_rating_angajat || ' cu un meniu care sa aiba rating-ul ' || p_rating_meniu);
        return '';
    when others then
        dbms_output.put_line('Alta eroare');
end;
/
-- cazul in care totul merge bine
begin
    dbms_output.put_line(nr_calatori_chelner_meniu(5, 4));
end;
/
-- cazul in care este apelat cu valori invalide
begin
    -- rating-ul chelnerului este invalid
    dbms_output.put_line(nr_calatori_chelner_meniu(6, 4));
    -- rating-ul meniului este invalid
    dbms_output.put_line(nr_calatori_chelner_meniu(5, 6));
end;
/
-- cazul in care nu exista chelner cu rating-ul dat
begin
    dbms_output.put_line(nr_calatori_chelner_meniu(3, 4));
end;
/
-- cazul in care nu exista meniu cu rating-ul dat
begin
    dbms_output.put_line(nr_calatori_chelner_meniu(5, 1));
end;
/
-- cazul in care nu exista calatori care sa satisfaca cerinta
begin
    dbms_output.put_line(nr_calatori_chelner_meniu(1, 2));
end; 
/

-- 9.

create or replace procedure inc_slr_staff_day_route(directory_path in varchar, 
                                                    file_name in varchar)
is
    file_handle utl_file.file_type;
    type week_days is table of char(1) index by varchar(20);
    type rec_update is record (id_angajat number, procent number);
    type varchar_table is table of varchar(20);
    type rec_table is table of rec_update;
    t_to_update rec_table := rec_table();
    zile week_days;
    invalid_file exception;
    invalid_directory_path exception;
    invalid_percentage exception;
    pragma exception_init(invalid_directory_path, -29280);
    pragma exception_init(invalid_file, -29283);
    pragma exception_init(invalid_percentage, -20007);
    fline varchar(256);
    words extra_pack.varchar_table := extra_pack.varchar_table();
    numar_zi number;
    dist_ruta number;
    nr_linie number := 0;
    v_rec rec_update;
begin
    zile('luni') := '1';
    zile('marti') := '2';
    zile('miercuri') := '3';
    zile('joi') := '4';
    zile('vineri') := '5';
    zile('sambata') := '6';
    zile('duminica') := '7';
    file_handle := utl_file.fopen(upper(directory_path), file_name, 'r');
    loop
        begin
            utl_file.get_line(file_handle, fline);
        exception 
            when no_data_found then exit;
        end;
        nr_linie := nr_linie + 1;
        
        words := extra_pack.sparge_string_regex(fline, '[^,]+');
        numar_zi := zile(lower(words(1)));
        dist_ruta := to_number(words(2));
        words(3) := trim(words(3));     -- in caz ca exista spatii la finalul liniilor
        if not regexp_like(words(3), '^0\.\d{1,2}$') then
            raise invalid_percentage;
        end if;
        v_rec.procent := to_number(words(3), '0.99');
        
        select distinct s.id_membru into v_rec.id_angajat
        from staff s
        join lucreaza_in l on s.id_membru = l.id_membru
        join trenuri t on l.nr_tren = t.nr_tren
        join bilete b on t.nr_tren = b.nr_tren
        join rute r on r.id_ruta = r.id_ruta
        where to_char(l.data_ultima, 'd') = numar_zi and r.distanta > dist_ruta;
        
        t_to_update.extend;
        t_to_update(t_to_update.last) := v_rec;
        
    end loop;
    
    forall i in t_to_update.first..t_to_update.last 
        update staff set salariu = salariu * (1 + t_to_update(i).procent) where id_membru = t_to_update(i).id_angajat;
    
    dbms_output.put_line('S-au prelucrat cu succes cele ' || nr_linie || ' linii');
    utl_file.fclose(file_handle);
exception
    when invalid_file then
        dbms_output.put_line('Fisierul "' || file_name || '" nu exista sau este invalid');
    when invalid_directory_path then
        dbms_output.put_line('Directorul "' || upper(directory_path) || '" nu exista sau este invalid');
    when too_many_rows then
        dbms_output.put_line('Mai multi angajati care satisfac datele din fisier de la linia ' || nr_linie || '. Nepermis!');
        utl_file.fclose(file_handle);
    when no_data_found then
        dbms_output.put_line('Nu exista angajati care sa satisfaca datele din fisier de la linia ' || nr_linie);
        utl_file.fclose(file_handle);
    when invalid_percentage then 
        dbms_output.put_line('Procent invalid la linia ' || nr_linie || '. Formatul permis este "0\.\d{1,2}"');
    when others then
        dbms_output.put_line('Eroare necunoscuta s-a produs la linia ' || nr_linie);
end;
/
-- apel care functioneza cum ne-am astepta
-- angajatul cu id 40 si cel cu id 35
execute inc_slr_staff_day_route('file_dir','incr_salariu_ok.txt');
select id_membru, salariu from staff;
rollback;
/
-- apel in care dau ca parametru un nume de director inexistent
execute inc_slr_staff_day_route('random', 'incr_salariu_ok.txt');
/
-- apel in care dau ca parametru un nume de fisier inexistent
execute inc_slr_staff_day_route('file_dir', 'random_file.txt');
/
-- apel pentru cazul in care fisierul contine un procent in format invalid
execute inc_slr_staff_day_route('file_dir', 'incr_salariu_proc_invalid.txt');
/
-- apel pentru cazul in care pentru o anumita linie nu exista angajati care sa satisfaca cerinta
execute inc_slr_staff_day_route('file_dir', 'incr_salariu_no_data.txt');
/
-- apel pentru cazul in care pentru o anumita linie exista mai multi angajati care satisfac cerinta
execute inc_slr_staff_day_route('file_dir', 'incr_salariu_too_many.txt');
/

-- 10 && 11
-- Doi triggeri care sa implementeze constrangerea ca fiecare calator sa aiba un numar de telefon (sa nu fie null), 
-- iar in baza de date sa nu existe doua numere de telefon identice. (+ un trigger in plus pentru a goli hash_table-ul
-- din pachetul ajutator)
-- Am evitat astfel mutating table.

create or replace package solve_mutating is
    type hash_table is table of number index by varchar(50);
    used hash_table;
end;
/
create or replace trigger valid_phone_comanda 
before insert or update on calatori
declare
    cursor c is 
        select id_calator as id, numere_telefon as nr_tel from calatori;
begin
    for rec in c loop
        for i in rec.nr_tel.first..rec.nr_tel.last loop
            solve_mutating.used(rec.nr_tel(i)) := 1;
        end loop;
    end loop;
end;

/

create or replace trigger valid_phone_linie
before insert or update on calatori
for each row
declare
    type hash_table is table of number index by varchar(50);
    used_local hash_table;
    iterator varchar(50);
begin
    if :new.numere_telefon is null then
        raise_application_error(-20008, 'Fiecare calator trebuie sa aiba asociat cel putin un numar de telefon');
    end if;
    
    if updating then
        for i in :old.numere_telefon.first..:old.numere_telefon.last loop
            solve_mutating.used.delete(:old.numere_telefon(i));
        end loop;
    end if;
    
    for i in :new.numere_telefon.first..:new.numere_telefon.last loop
        if used_local.exists(:new.numere_telefon(i)) then
            raise_application_error(-20010, 'Un calator nu poate sa aiba asociat acelasi numar de telefon de mai multe ori: ' || :new.numere_telefon(i));
        end if;
    
        if solve_mutating.used.exists(:new.numere_telefon(i)) then
            raise_application_error(-20009, 'Nu pot exista mai multi calatori care sa aiba asociat acelasi numar de telefon: ' || :new.numere_telefon(i));
        end if;
        
        used_local(:new.numere_telefon(i)) := 1;
    end loop;
    
    iterator := used_local.first;
    loop
        exit when iterator is null;
        solve_mutating.used(iterator) := 1;
        iterator := used_local.next(iterator);
    end loop;
end;
/

create or replace trigger valid_phone_after
after insert or update on calatori
begin
    solve_mutating.used.delete;
end;
/

-- Nu apare eroarea table mutating, chiar daca apelam insert-ul sub forma "insert into ... select ..."
-- Cazul in care numarul de telefon este deja existent in baza de date
insert into calatori
select 100, 'TestFirstName', 'TestLastName', 20, 'M', vector_email('something@email.com'), tabel_telefon('0712345719')
from dual;

-- Cazul in care numarul de telefon se repeta in tabelul imbricat pe care dorim sa il inseram
insert into calatori
select 100, 'TestFirstName', 'TestLastName', 20, 'M', vector_email('something@email.com'), tabel_telefon('0765741965', '07643519864', '0765741965')
from dual;

-- Cazul in care tabelul imbricat este atomic null
insert into calatori
select 100, 'TestFirstName', 'TestLastName', 20, 'M', vector_email('something@email.com'), null
from dual;

-- Cazul in care totul functioneaza cum ar trebui (datele respecta regulile constrangerii impuse de catre trigger)
insert into calatori
select 100, 'TestFirstName', 'TestLastName', 20, 'M', vector_email('something@email.com'), tabel_telefon('0765741965')
from dual;

select * from calatori where id_calator = 100;
rollback;

-- 12.
create table schema_ddl_history (
    data_comanda date,
    user_name varchar(100),
    comanda varchar(20),
    tip_obiect varchar(50),
    nume_obiect varchar(100)
);

/
create or replace trigger ddl_tracker 
after create or alter or drop on schema
declare
    v_user_name varchar(100) := sys.login_user;
    v_comanda varchar(20) := sys.sysevent;
    v_tip_obiect varchar(50) := sys.dictionary_obj_type;
    v_nume_obiect varchar(100) := sys.dictionary_obj_name;
begin
    dbms_output.put_line('User-ul: ' || v_user_name);
    dbms_output.put_line('Comanda rulata: ' || v_comanda);
    dbms_output.put_line('Tipul obiectului referit: ' || v_tip_obiect);
    dbms_output.put_line('Numele obiectului referit: ' || v_nume_obiect);
    dbms_output.put_line('Data rularii comenzii: ' || to_char(sysdate, 'DD.MM.YYYY'));

    insert into schema_ddl_history
    values(sysdate, v_user_name, v_comanda, v_tip_obiect, v_nume_obiect);
end;
/
create table test_trigger(id number);
alter table test_trigger add test_column varchar(10);
create sequence test_seq;
drop sequence test_seq;
drop table test_trigger;

select * from schema_ddl_history;

-- 13.
create or replace package project_package is
    procedure update_phone_email(operatie in varchar, nr_calatori_actualizati out nocopy number);
    procedure afis_info_controlori_politete(min_politete in number);
    function nr_calatori_chelner_meniu(p_rating_angajat in number, p_rating_meniu in number) 
    return varchar;
    procedure inc_slr_staff_day_route(directory_path in varchar, file_name in varchar);
end;
/
create or replace package body project_package is 
    procedure update_phone_email(operatie in varchar, nr_calatori_actualizati out nocopy number)
    is  -- ultimul atribut este nocopy pentru ca procedura sa imi puna valoarea in aceasta variabila chiar si daca are loc
        -- o eroare (raise_application_error)
        file_handle utl_file.file_type;
        fline varchar(100);
        type indexed_table is table of number index by pls_integer;
        hash_table indexed_table;
        words extra_pack.varchar_table := extra_pack.varchar_table();
        v_email vector_email;
        v_id_calator number;
    begin
        if lower(operatie) = 'update_phone' then
            file_handle := utl_file.fopen('FILE_DIR', 'data_phone.txt', 'r');
            loop
                begin
                    utl_file.get_line(file_handle, fline);
                exception 
                    when no_data_found then exit;
                end;
            
            words := extra_pack.sparge_string_regex(fline, '[^,]+');
            v_id_calator := to_number(words(1));
            if not hash_table.exists(v_id_calator) then
                hash_table(v_id_calator) := 1;
            end if;
            
            insert into table(select numere_telefon from calatori where id_calator = v_id_calator)
            values(words(2));
            
            end loop;
            
            nr_calatori_actualizati := hash_table.count;
            utl_file.fclose(file_handle);
            
        elsif lower(operatie) = 'update_email' then
            file_handle := utl_file.fopen('FILE_DIR', 'data_email.txt', 'r');
            loop
                begin
                    utl_file.get_line(file_handle, fline);
                exception 
                    when no_data_found then exit;
                end;
            
            
            words := extra_pack.sparge_string_regex(fline, '[^,]+');
            v_id_calator := to_number(words(1));
            select email into v_email from calatori where id_calator = v_id_calator;
            if v_email.count = 2 then 
                nr_calatori_actualizati := hash_table.count;
                raise_application_error(-20002, 'Calatorul cu id-ul ' || v_id_calator || ' are deja 2 adrese de email');
            end if;
            
            if not hash_table.exists(v_id_calator) then
                hash_table(v_id_calator) := 1;
            end if;
            
            v_email.extend;
            v_email(v_email.last) := words(2);
            update calatori
            set email = v_email
            where id_calator = v_id_calator;
            
            end loop;
            
            nr_calatori_actualizati := hash_table.count;
            utl_file.fclose(file_handle);
        else
            raise_application_error(-20001, 'Operatia "' || operatie || '" nu este cunoscuta!');
        end if;
    end;
    
    procedure afis_info_controlori_politete(min_politete in number) 
    is
        cursor expr_curs(polit number) is
            select s.nume, s.prenume, s.salariu, cursor (
                select t.nr_tren, t.an_fabricatie
                from lucreaza_in l
                join trenuri t on l.nr_tren = t.nr_tren
                where l.id_membru = s.id_membru
                order by an_fabricatie desc 
            )
            from controlori c
            join staff s on c.id_membru = s.id_membru
            where c.politete >= polit;
        
        v_cursor sys_refcursor;
        v_nume varchar(50);
        v_prenume varchar(50);
        v_salariu number;
        v_nr_tren number;
        v_an_fabricatie number;
        counter_lucrat number;
        top_counter number;
        prev_an_fabricatie number(4);
        suma_salariu number;
    begin
        open expr_curs(min_politete);
        counter_lucrat := 0;
        suma_salariu := 0;
        loop
            fetch expr_curs into v_nume, v_prenume, v_salariu, v_cursor;
            exit when expr_curs%notfound;
            
            dbms_output.put_line(v_nume || ' ' || v_prenume || ' - ' || v_salariu);
            dbms_output.put_line('-----------------------------------');
            
            top_counter := 0;
            prev_an_fabricatie := 0;
            loop
                fetch v_cursor into v_nr_tren, v_an_fabricatie;
                if top_counter = 0 and v_cursor%notfound then
                    dbms_output.put_line('Acest controlor nu a lucrat in nici un tren');
                    exit;
                end if;
                exit when v_cursor%notfound;
                
                if v_an_fabricatie <> prev_an_fabricatie then
                    top_counter := top_counter + 1;
                end if;
                
                dbms_output.put_line(top_counter || '. NR: ' || v_nr_tren || ' -> AN:' || v_an_fabricatie);
                
                prev_an_fabricatie := v_an_fabricatie;
            end loop;
            
            if top_counter > 0 then
                counter_lucrat := counter_lucrat + 1;
                suma_salariu := suma_salariu + v_salariu;
            end if;
            
            dbms_output.new_line;
            dbms_output.new_line;
            
        end loop;
        
        if counter_lucrat > 0 then
            dbms_output.put_line(counter_lucrat || ' controlori cu politete mai mare sau egala decat ' || min_politete || ' de au lucrat in cel putin un tren');
            dbms_output.put_line('Media salariilor acestora este: ' || round(suma_salariu / counter_lucrat, 2));
        else
            dbms_output.put_line('Nici un controlor cu politete de cel putin ' || min_politete || 'nu a lucrat in vreun tren pana acum');
        end if;
    end;
    
    function nr_calatori_chelner_meniu(p_rating_angajat in number, p_rating_meniu in number) 
    return varchar 
    is
        cursor c_chelneri is
            select id_membru from chelneri where rating = p_rating_angajat;
        cursor c_meniu is 
            select id_meniu from meniuri where rating = p_rating_meniu;
        cursor c_principal(p_rating number, p_id_meniu number) is
            select c.nume || ' ' || c.prenume nume_complet from serveste s
            join calatori c on c.id_calator = s.id_calator
            join chelneri ch on ch.id_membru = s.id_membru
            where s.id_meniu = p_id_meniu and ch.rating = p_rating;
            
        rating_out_of_range exception;
        no_waiter exception;
        no_menu exception;
        no_names exception;
        pragma exception_init(rating_out_of_range, -20003);
        pragma exception_init(no_waiter, -20004);
        pragma exception_init(no_menu, -20005);
        pragma exception_init(no_names, -20006);
        dummy number;
        string_nume varchar(256);
        empty_string boolean := true;
    begin
        if p_rating_angajat < 1 or p_rating_angajat > 5 or p_rating_meniu < 1 or p_rating_meniu > 5 then
            raise rating_out_of_range;
        end if;
        
        open c_chelneri;
        fetch c_chelneri into dummy;
        
        if c_chelneri%notfound then
            close c_chelneri;
            raise no_waiter;
        end if;
        close c_chelneri;
        
        open c_meniu;
        fetch c_meniu into dummy;
        if c_meniu%notfound then
            close c_meniu;
            raise no_menu;
        end if;
        close c_meniu;
        
        for rec1 in c_meniu loop
            for rec2 in c_principal(p_rating_angajat, rec1.id_meniu) loop
                if empty_string then
                    string_nume := string_nume || rec2.nume_complet;
                    empty_string := false;
                else
                    string_nume := string_nume || ', ' || rec2.nume_complet;
                end if;
            end loop;
        end loop;
        
        if empty_string then
            raise no_names;
        end if;
        
        return string_nume;
    exception
        when rating_out_of_range then
            dbms_output.put_line('Unul dintre rating-uri nu este intre valorile permise (1-5)');
            return '';
        when no_waiter then
            dbms_output.put_line('Nu exista nici un chelner cu rating-ul ' || p_rating_angajat);
            return '';
        when no_menu then
            dbms_output.put_line('Nu exista nici un meniu cu rating-ul ' || p_rating_meniu);
            return '';
        when no_names then
            dbms_output.put_line('Nu exista calatori care sa fi fost servit de catre un chelner cu rating-ul '
            || p_rating_angajat || ' cu un meniu care sa aiba rating-ul ' || p_rating_meniu);
            return '';
        when others then
            dbms_output.put_line('Alta eroare');
    end;
    
    procedure inc_slr_staff_day_route(directory_path in varchar, file_name in varchar)
    is
        file_handle utl_file.file_type;
        type week_days is table of char(1) index by varchar(20);
        type rec_update is record (id_angajat number, procent number);
        type varchar_table is table of varchar(20);
        type rec_table is table of rec_update;
        t_to_update rec_table := rec_table();
        zile week_days;
        invalid_file exception;
        invalid_directory_path exception;
        invalid_percentage exception;
        pragma exception_init(invalid_directory_path, -29280);
        pragma exception_init(invalid_file, -29283);
        pragma exception_init(invalid_percentage, -20007);
        fline varchar(256);
        words extra_pack.varchar_table := extra_pack.varchar_table();
        numar_zi number;
        dist_ruta number;
        nr_linie number := 0;
        v_rec rec_update;
    begin
        zile('luni') := '1';
        zile('marti') := '2';
        zile('miercuri') := '3';
        zile('joi') := '4';
        zile('vineri') := '5';
        zile('sambata') := '6';
        zile('duminica') := '7';
        file_handle := utl_file.fopen(upper(directory_path), file_name, 'r');
        loop
            begin
                utl_file.get_line(file_handle, fline);
            exception 
                when no_data_found then exit;
            end;
            nr_linie := nr_linie + 1;
            
            words := extra_pack.sparge_string_regex(fline, '[^,]+');
            numar_zi := zile(lower(words(1)));
            dist_ruta := to_number(words(2));
            words(3) := trim(words(3));     -- in caz ca exista spatii la finalul liniilor
            if not regexp_like(words(3), '^0\.\d{1,2}$') then
                raise invalid_percentage;
            end if;
            v_rec.procent := to_number(words(3), '0.99');
            
            select distinct s.id_membru into v_rec.id_angajat
            from staff s
            join lucreaza_in l on s.id_membru = l.id_membru
            join trenuri t on l.nr_tren = t.nr_tren
            join bilete b on t.nr_tren = b.nr_tren
            join rute r on r.id_ruta = r.id_ruta
            where to_char(l.data_ultima, 'd') = numar_zi and r.distanta > dist_ruta;
            
            t_to_update.extend;
            t_to_update(t_to_update.last) := v_rec;
            
        end loop;
        
        forall i in t_to_update.first..t_to_update.last 
            update staff set salariu = salariu * (1 + t_to_update(i).procent) where id_membru = t_to_update(i).id_angajat;
        
        dbms_output.put_line('S-au prelucrat cu succes cele ' || nr_linie || ' linii');
        utl_file.fclose(file_handle);
    exception
        when invalid_file then
            dbms_output.put_line('Fisierul "' || file_name || '" nu exista sau este invalid');
        when invalid_directory_path then
            dbms_output.put_line('Directorul "' || upper(directory_path) || '" nu exista sau este invalid');
        when too_many_rows then
            dbms_output.put_line('Mai multi angajati care satisfac datele din fisier de la linia ' || nr_linie || '. Nepermis!');
            utl_file.fclose(file_handle);
        when no_data_found then
            dbms_output.put_line('Nu exista angajati care sa satisfaca datele din fisier de la linia ' || nr_linie);
            utl_file.fclose(file_handle);
        when invalid_percentage then 
            dbms_output.put_line('Procent invalid la linia ' || nr_linie || '. Formatul permis este "0\.\d{1,2}"');
        when others then
            dbms_output.put_line('Eroare necunoscuta s-a produs la linia ' || nr_linie);
    end;
end;
/
-- APELURI ALE FUNCTIILOR / PROCEDURILOR DIN PACHET

declare
    nr_return number;
begin
    project_package.update_phone_email('update_email', nr_return);
    dbms_output.put_line('S-au actualizat ' || nr_return || ' inregistrari');
exception
    when exceptii.operatie_invalida then
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Incercati o operatie permisa: "update_phone" / "update_email"');
    when exceptii.limita_email_depasita then
        dbms_output.put_line(SQLERRM);
        if nr_return = 0 then
            dbms_output.put_line('Nu s-a actualizat nici o inregistrare');
        elsif nr_return = 1 then
            dbms_output.put_line('S-a actualizat doar o inregistrare');
        else 
            dbms_output.put_line('S-au actualizat doar ' || nr_return || ' inregistrari');
        end if;
end;
/
select * from calatori;
rollback;
/
-----------------------------

execute project_package.afis_info_controlori_politete(1);
/

-----------------------------

-- cazul in care totul merge bine
begin
    dbms_output.put_line(project_package.nr_calatori_chelner_meniu(5, 4));
end;
/
-- cazul in care este apelat cu valori invalide
begin
    -- rating-ul chelnerului este invalid
    dbms_output.put_line(project_package.nr_calatori_chelner_meniu(6, 4));
    -- rating-ul meniului este invalid
    dbms_output.put_line(project_package.nr_calatori_chelner_meniu(5, 6));
end;
/
-- cazul in care nu exista chelner cu rating-ul dat
begin
    dbms_output.put_line(project_package.nr_calatori_chelner_meniu(3, 4));
end;
/
-- cazul in care nu exista meniu cu rating-ul dat
begin
    dbms_output.put_line(project_package.nr_calatori_chelner_meniu(5, 1));
end;
/
-- cazul in care nu exista calatori care sa satisfaca cerinta
begin
    dbms_output.put_line(project_package.nr_calatori_chelner_meniu(1, 2));
end; 
/

----------------------------------------------

-- apel care functioneza cum ne-am astepta
-- angajatul cu id 40 si cel cu id 35
execute project_package.inc_slr_staff_day_route('file_dir','incr_salariu_ok.txt');
select id_membru, salariu from staff;
rollback;
/
-- apel in care dau ca parametru un nume de director inexistent
execute project_package.inc_slr_staff_day_route('random', 'incr_salariu_ok.txt');
/
-- apel in care dau ca parametru un nume de fisier inexistent
execute project_package.inc_slr_staff_day_route('file_dir', 'random_file.txt');
/
-- apel pentru cazul in care fisierul contine un procent in format invalid
execute project_package.inc_slr_staff_day_route('file_dir', 'incr_salariu_proc_invalid.txt');
/
-- apel pentru cazul in care pentru o anumita linie nu exista angajati care sa satisfaca cerinta
execute project_package.inc_slr_staff_day_route('file_dir', 'incr_salariu_no_data.txt');
/
-- apel pentru cazul in care pentru o anumita linie exista mai multi angajati care satisfac cerinta
execute project_package.inc_slr_staff_day_route('file_dir', 'incr_salariu_too_many.txt');
/


-- 14.
create or replace package extra_pack is
    type indexed_numbers is table of number index by pls_integer;
    type varchar_table is table of varchar(256);
    type capete_rute is record(oras_plecare orase.id_oras%type, oras_sosire orase.id_oras%type);
    type table_rute is table of capete_rute;
    type nr_table_rectype is record (nr_calatori number, rute table_rute);
    type vec_rec is varray(2) of nr_table_rectype;
    type number_rec is record (id number);
    cursor c_incr_salariu return number_rec;
    -- primeste ca input un string si o expresie regulata si sparge acel string in substring-uri folosind
    -- expresia regulata data ca parametru; returneaza un tabel imbricat cu acele substring-uri rezultate
    function sparge_string_regex(input_string in varchar, regexp in varchar) return varchar_table;
    
    -- returneaza un vector in care sunt informatii despre numarul minim, respectiv maxim de calatori
    -- care au circulat pe rute, respectiv capetele rutelor respective (pot fi mai multe rute cu nr min/max de calatori
    function ruta_min_max return vec_rec;
    
    -- procedura care mareste salariul cu 5% primilor 3 angajati de luna aceasta pentru fiecare job
    -- top-ul este dat de numarul de "task-uri" efectuate (serveste, controleaza, gateste)
    procedure incr_salary_top3;
    salarii_deja_incr exception;
    pragma exception_init(salarii_deja_incr, -20011);
    
    -- seteaza ultima luna pentru procedura anterioara; doar pentru testing...
    procedure set_luna_ultima_inc(luna number);
    
    -- procedura care afiseaza pentru fiecare tip de reducere varsta calatorilor care au beneficiat
    -- de acel tip de reducere (valori distincte), media varstelor si suma de bani pierduta pentru acel
    -- tip de reducere; la final afiseaza suma totala pierduta pentru toate reducerile
    procedure bani_pierduti_reduceri;
end;
/

create or replace package body extra_pack is
    luna_ultima_inc number := to_number(to_char(add_months(trunc(sysdate, 'mm'), -1), 'mm'));
    type number_table is table of number;
    
    cursor c_incr_salariu return number_rec is
        with temp1 as (
            select id_membru, count(*) from serveste
            group by id_membru order by 2 desc
        ),
        temp2 as (
            select id_membru, count(*) from controleaza
            group by id_membru order by 2 desc
        ),
        temp3 as (
            select id_membru, count(*) from gateste 
            group by id_membru order by 2 desc
        )
        select id_membru from staff
        where id_membru in (
            select id_membru from temp1 where rownum <= 3
        ) or id_membru in (
            select id_membru from temp2 where rownum <= 3
        )or id_membru in (
            select id_membru from temp3 where rownum <= 3
        )
        for update of salariu;
    
    cursor c_pierderi is
        select tip_reducere, cursor (
            select b.pret_initial - b.pret_final pret_partial, c.varsta
            from bilete b 
            join calatori c on c.id_calator = b.id_calator
            where b.tip_reducere = r.tip_reducere
        ) curs from reduceri r;
    
    procedure bani_pierduti_reduceri is
        v_tip_reducere reduceri.tip_reducere%type;
        hash_table indexed_numbers;
        v_curs sys_refcursor;
        suma_part number;
        suma_tot number := 0;
        nr_part number;
        suma_varsta number;
        v_pret number;
        v_varsta number;
        iterator number;
    begin
        open c_pierderi;
        loop
            fetch c_pierderi into v_tip_reducere, v_curs;
            exit when c_pierderi%notfound;
            suma_part := 0;
            nr_part := 0;
            suma_varsta := 0;
            
            loop
                fetch v_curs into v_pret, v_varsta;
                exit when v_curs%notfound;
                suma_varsta := suma_varsta + v_varsta;
                suma_part := suma_part + v_pret;
                nr_part := nr_part + 1;
                if not hash_table.exists(v_varsta) then
                    hash_table(v_varsta) := 1;
                end if;
            end loop;
            
            dbms_output.put_line('============ ' || v_tip_reducere || ' ============');
            if nr_part = 0 then 
                dbms_output.put_line('Nimeni nu a beneficiat de acest tip de reducere');
                dbms_output.new_line;
            else
                iterator := hash_table.first;
                loop
                    exit when iterator is null;
                    dbms_output.put_line(iterator || ' ani');
                    iterator := hash_table.next(iterator);
                end loop;
                hash_table.delete;
                dbms_output.new_line;
                dbms_output.put_line('Media varstelor: ' || suma_varsta / nr_part || ' ani');
                dbms_output.put_line('Suma pierduta pentru acest tip de reducere: ' || suma_part || ' RON');
                dbms_output.new_line;
                suma_tot := suma_tot + suma_part;
            end if;
            
        end loop;
        close c_pierderi;
        
        dbms_output.put_line('In total s-au pierdut: ' || suma_tot || ' RON');
    end;
    
    procedure set_luna_ultima_inc(luna number) is
    begin
        luna_ultima_inc := luna;
    end;
    
    procedure incr_salary_top3 is
        v_id number;
        v_table number_table := number_table();
    begin
        if to_number(to_char(sysdate, 'mm')) = luna_ultima_inc then
            raise_application_error(-20011, 'Luna aceasta s-a realizat deja incrementarea salariala');
        end if;
        
        luna_ultima_inc := to_number(to_char(sysdate, 'mm'));
        
        open c_incr_salariu;
        loop
            fetch c_incr_salariu into v_id;
            exit when c_incr_salariu%notfound;
            update staff set salariu = 1.05 * salariu 
            where current of c_incr_salariu;
            
            v_table.extend;
            v_table(v_table.last) := v_id;
        end loop;   
        close c_incr_salariu;
        
        dbms_output.put_line('S-a incrementat salariul angajatilor cu id-urile: ');
        for i in v_table.first..v_table.last loop
            dbms_output.put(v_table(i) || ' ');
        end loop;
        dbms_output.new_line;
    end;
    
    
    function sparge_string_regex(input_string in varchar, regexp in varchar) 
    return varchar_table
    is
        return_collection varchar_table := varchar_table();
    begin
        select
        regexp_substr (
          input_string, regexp, 1, level
        ) bulk collect into return_collection
        from dual
        connect by regexp_substr (
          input_string, regexp, 1, level
        ) is not null;
        
        return return_collection;
    end;
    
    function ruta_min_max return vec_rec is
        cursor c_min is
            select id_ruta, (select count(*) from bilete where id_ruta = r.id_ruta) nr_calatori
            from rute r 
            where (select count(*) from bilete where id_ruta = r.id_ruta) 
                = (select min(count(*)) from bilete group by id_ruta);
        
        cursor c_max is 
            select id_ruta, (select count(*) from bilete where id_ruta = r.id_ruta) nr_calatori
            from rute r 
            where (select count(*) from bilete where id_ruta = r.id_ruta) 
                = (select max(count(*)) from bilete group by id_ruta);
                
        v_id_ruta rute.id_ruta%type;
        v_nr_calatori number;
        first_iteration boolean := true;
        return_vec vec_rec := vec_rec();
        dummy_rec nr_table_rectype;
        v_capete_rute capete_rute;
    begin
        dummy_rec.rute := table_rute();
        return_vec.extend(2);
        return_vec(1) := dummy_rec;
        return_vec(2) := dummy_rec;
        open c_min;
        loop
            fetch c_min into v_id_ruta, v_nr_calatori;
            exit when c_min%notfound;
            if first_iteration then
                return_vec(1).nr_calatori := v_nr_calatori;
                first_iteration := false;
            end if;
            select id_oras_plecare, id_oras_sosire into v_capete_rute 
            from rute where id_ruta = v_id_ruta;
            
            return_vec(1).rute.extend;
            return_vec(1).rute(return_vec(1).rute.last) := v_capete_rute;
        end loop;
        close c_min;
        if first_iteration then
            raise no_data_found;
        end if;
        
        first_iteration := true;
        open c_max;
        loop
            fetch c_max into v_id_ruta, v_nr_calatori;
            exit when c_max%notfound;
            if first_iteration then
                return_vec(2).nr_calatori := v_nr_calatori;
                first_iteration := false;
            end if;
            select id_oras_plecare, id_oras_sosire into v_capete_rute 
            from rute where id_ruta = v_id_ruta;
            
            return_vec(2).rute.extend;
            return_vec(2).rute(return_vec(2).rute.last) := v_capete_rute;
        end loop;
        close c_max;
        
        if first_iteration then
            raise no_data_found;
        end if;
        
        return return_vec;
    end;
end;
/
-- functia sparge_string_regex a fost folosita la 6 si 9; de aceea
-- pachetul de la 14 trebuie rulat inainte de acestea.

declare
    vec_test extra_pack.vec_rec := extra_pack.vec_rec();
begin
    vec_test := extra_pack.ruta_min_max;
    dbms_output.put_line('Nr calatori minim: ' || vec_test(1).nr_calatori || ', iar rutele sunt: ');
    for j in vec_test(1).rute.first..vec_test(1).rute.last loop
        dbms_output.put_line(vec_test(1).rute(j).oras_plecare || ' -> ' || vec_test(1).rute(j).oras_sosire);
    end loop;
    dbms_output.new_line;
    
    dbms_output.put_line('Nr calatori maxim: ' || vec_test(2).nr_calatori || ', iar rutele sunt: ');
    for j in vec_test(2).rute.first..vec_test(2).rute.last loop
        dbms_output.put_line(vec_test(2).rute(j).oras_plecare || ' -> ' || vec_test(2).rute(j).oras_sosire);
    end loop;
    dbms_output.new_line;
exception
    when no_data_found then
        dbms_output.put_line('Nu exista date');
end;
/
-- puteti modifica luna pentru a rula din nou folosind procedura
-- extra_pack.set_luna_ultima_inc(luna number)
execute extra_pack.incr_salary_top3;
select * from staff;
--33 34 36 38 39 41 43 45 47       
rollback;
/
execute extra_pack.bani_pierduti_reduceri;
/
-- DROP ALL OBJECTS
drop table lucreaza_in;
drop table gateste;
drop table serveste;
drop table controleaza;
drop table controlori;
drop table bucatari;
drop table chelneri;
drop table bilete;
drop table calatori;
drop table meniuri;
drop table staff;
drop table rute;
drop table reduceri;
drop table orase;
drop table trenuri;
drop trigger ddl_tracker;
drop table schema_ddl_history;
drop trigger valid_phone_linie;
drop trigger valid_phone_comanda;
drop trigger valid_phone_after;
drop package project_package;
drop package solve_mutating;
drop package extra_pack;
drop package exceptii;
drop function nr_calatori_chelner_meniu;
drop procedure update_phone_email;
drop procedure afis_info_controlori_politete;
drop procedure inc_slr_staff_day_route;
drop type tabel_telefon;
drop type vector_email;

