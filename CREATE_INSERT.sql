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

alter table calatori drop constraint gen_calatori_CK; 
alter table calatori add constraint gen_calatori_CK check(gen = 'M' or gen = 'F' or gen is null);

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
    denumire varchar2(50),
    rating number(1) default 1,
    constraint MENIURI_PK primary key (denumire),
    constraint rating_meniu_check check (rating between 1 and 5)
);

create table REDUCERI (
    tip_reducere varchar(20),
    valoare_reducere number(3, 2),
    constraint REDUCERI_PK primary key (tip_reducere),
    constraint valoare_reducere_CK check(valoare_reducere between 0 and 1)
);

create table ORASE_PLECARE (
    id_oras varchar2(8),
    nume varchar2(40) not null,
    nume_tara varchar(40) not null,
    constraint ORASE_PLECARE_PK primary key (id_oras)
);

create table ORASE_SOSIRE (
    id_oras varchar2(8),
    nume varchar2(40) not null,
    nume_tara varchar(40) not null,
    constraint ORASE_SOSIRE_PK primary key (id_oras)
);

create table BILETE (
    id_calator number(8),
    ora_plecare char(5),
    data_plecare date,
    ora_sosire char(5) not null,
    data_sosire date not null,
    pret_initial number(5, 2) not null,
    tip_reducere varchar2(20),
    pret_final number(5, 2) not null,
    nr_tren number(6) not null,
    denumire_meniu varchar2(50),
    oras_plecare varchar2(8) not null,
    oras_sosire varchar2(8) not null,
    constraint BILETE_PK primary key (id_calator, ora_plecare, data_plecare),
    foreign key (id_calator) references CALATORI(id_calator) on delete cascade,
    foreign key (tip_reducere) references REDUCERI(tip_reducere) on delete cascade,
    foreign key (nr_tren) references TRENURI(nr_tren) on delete cascade,
    foreign key (denumire_meniu) references MENIURI(denumire) on delete set null,
    foreign key (oras_plecare) references ORASE_PLECARE(id_oras) on delete cascade,
    foreign key (oras_sosire) references ORASE_SOSIRE(id_oras) on delete cascade
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
    denumire_meniu varchar2(50),
    nota_client number(2) default 1,
    constraint SERVESTE_PK primary key (id_membru, id_calator, denumire_meniu),
    constraint SERVESTE_CK check(nota_client between 1 and 10),
    foreign key (id_membru) references CHELNERI(id_membru) on delete cascade,
    foreign key (id_calator) references CALATORI(id_calator) on delete cascade,
    foreign key (denumire_meniu) references MENIURI(denumire) on delete cascade
);

create table GATESTE (
    id_membru number(3),
    denumire_meniu varchar2(50),
    constraint GATESTE_PK primary key (id_membru, denumire_meniu),
    foreign key (id_membru) references bucatari(id_membru) on delete cascade,
    foreign key (denumire_meniu) references meniuri(denumire) on delete cascade
);

create table legate (
    oras1 varchar2(8),
    oras2 varchar2(8),
    an_constructie number(4) default 1970,
    constraint legate_pk primary key (oras1, oras2),
    constraint legate_unique unique (oras2, oras1),
    constraint legate_ck check (an_constructie between 1970 and 2022),
    foreign key (oras1) references orase_plecare(id_oras) on delete cascade,
    foreign key (oras2) references orase_sosire(id_oras) on delete cascade
);

alter table legate drop constraint legate_unique;
alter table legate drop constraint legate_different_ck;
alter table legate add constraint legate_different_ck check(oras1 < oras2); --dau voie sa fie inserate doar tupluri "ordonate"
--                                                                             pentru a pastra unicitatea

create table controleaza(
    id_calator number(8),
    ora_plecare char(5),
    data_plecare date,
    id_membru number(3),
    constraint controleaza_pk primary key (id_calator, ora_plecare, data_plecare, id_membru),
    foreign key (id_calator, ora_plecare, data_plecare) references bilete(id_calator, ora_plecare, data_plecare) on delete cascade,
    foreign key (id_membru) references controlori(id_membru) on delete cascade
);

create sequence seq_inserare nocycle; -- exercitiul 13
drop sequence seq_inserare;

--CALATORI
insert into calatori(id_calator, nume, prenume, varsta, email1, email2, telefon, gen)
values (seq_inserare.nextval, 'Pop', 'Andrei', 30, 'andrei_pop@gmail.com', null, '0712345719', 'M');

insert into calatori(id_calator, nume, prenume, varsta, email1, email2, telefon, gen)
values (seq_inserare.nextval, 'Muresan', 'Vicentiu', 28, 'muresvice@gmail.com', 'muresvice1@gmail.com', '0757843191', 'M');

insert into calatori(id_calator, nume, prenume, varsta, email1, email2, telefon, gen)
values (seq_inserare.nextval, 'Constantinescu', 'Catalin', 18, 'cataconstantin@gmail.com', null, '0712345718', null);

insert into calatori(id_calator, nume, prenume, varsta, email1, email2, telefon, gen)
values (seq_inserare.nextval, 'Pindaru', 'Adelina', 40, 'pindaruAdelina@gmail.com', 'adelinapin@gmail.com', '0712345710', 'F');

insert into calatori(id_calator, nume, prenume, varsta, email1, email2, telefon, gen)
values (seq_inserare.nextval, 'Pavel', 'Doina', 45, 'doina_pavel@gmail.com', null, '0749135476', 'F');

insert into calatori(id_calator, nume, prenume, varsta, email1, email2, telefon, gen)
values (seq_inserare.nextval, 'Dobrica', 'Casiana-Elena', 25, 'casyelena@gmail.com', 'elena.casiana-dobrica@gmail.com', '0772149658', null);

insert into calatori(id_calator, nume, prenume, varsta, email1, telefon)
values(seq_inserare.nextval, 'Savoiu', 'Mincu', 30, 'savoiumin@yahoo.com', '0716495137');

insert into calatori(id_calator, nume, prenume, varsta, email1, telefon, gen)
values(seq_inserare.nextval, 'Sancu', 'Monica', 23, 'monicasan@outlook.com', '0716496257', 'F');

insert into calatori(id_calator, nume, prenume, varsta, email1, telefon, gen)
values(seq_inserare.nextval, 'Samburel', 'Alexandra-Mirela', 32, 'alexymirela@gmail.com', '0756713498', 'F');

commit;


--TRENURI (nr_tren, an_fabricatie, data_achizitie, firma, ultima_revizie, nr_vagoane)
insert into trenuri(nr_tren, an_fabricatie, firma)
values(seq_inserare.nextval, 2011, 'Rails2GO');

insert into trenuri
values(seq_inserare.nextval, 2019, to_date('15-08-2020', 'DD-MM-YYYY'), 'TrainsForever', null, 8);

insert into trenuri
values(seq_inserare.nextval, 2015, to_date('16-06-2016', 'DD-MM-YYYY'), 'TrainsForever', to_date('27-04-2018', 'DD-MM-YYYY'), 4);

insert into trenuri
values(seq_inserare.nextval, 2017, to_date('15-08-2017', 'DD-MM-YYYY'), 'Rails2Go', to_date('19-05-2021', 'DD-MM-YYYY'), 2);

insert into trenuri
values(seq_inserare.nextval, 2010, to_date('20-09-2019', 'DD-MM-YYYY'), 'TrailLover', null, 5);

commit;

--STAFF + BUCATARI
insert into staff(id_membru, nume, prenume, data_angajare, salariu)
values(seq_inserare.nextval, 'Dumitru', 'Adela', to_date('15-02-2013', 'DD-MM-YYYY'), 5000);

insert into bucatari(id_membru, stele)
values(seq_inserare.currval, 4);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Vlasceanu', 'Diana', 7000);

insert into bucatari(id_membru)
values(seq_inserare.currval);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Dinu', 'Lucian', 6000);

insert into bucatari(id_membru, stele)
values(seq_inserare.currval, 5);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Ifrim', 'Andrei', 10000);

insert into bucatari(id_membru, stele)
values(seq_inserare.currval, 2);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Stanciu', 'Horia', 12000);

insert into bucatari(id_membru, stele)
values(seq_inserare.currval, 5);

commit;

--STAFF + CONTROLORI
insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Sava', 'Alexandru', 5500);

insert into controlori(id_membru, politete)
values(seq_inserare.currval, 5);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Manole', 'Iulian-George', 6500);

insert into controlori(id_membru)
values(seq_inserare.currval);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Popescu', 'Madalina-Andreea', 7800);

insert into controlori(id_membru, politete)
values(seq_inserare.currval, 4);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Nita', 'Loredana Monica', 4500);

insert into controlori(id_membru)
values(seq_inserare.currval);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Tomescu', 'Sebastian Emil', 9000);

insert into controlori(id_membru, politete)
values(seq_inserare.currval, 3);

commit;
--STAFF + CHELNERI
insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Pavel', 'Narcisa', 4000);

insert into chelneri(id_membru, rating)
values(seq_inserare.currval, 2);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Olteanu', 'Stefania-Maria', 6500);

insert into chelneri(id_membru, rating)
values(seq_inserare.currval, 4);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Ciocu', 'Bogdan Constantin', 7500);

insert into chelneri(id_membru, rating)
values(seq_inserare.currval, 5);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Craciun', 'Cristina', 8000);

insert into chelneri(id_membru, rating)
values(seq_inserare.currval, 5);

insert into staff(id_membru, nume, prenume, salariu)
values(seq_inserare.nextval, 'Pascu', 'Mirel Petre', 3500);

insert into chelneri(id_membru)
values(seq_inserare.currval);

commit;

--MENIURI

insert into meniuri(denumire, rating)
values('Pulpe de pui la cuptor cu cartofi si salata', 4);

insert into meniuri(denumire, rating)
values('Piure de cartofi cu friptura de porc', 5);

insert into meniuri(denumire, rating)
values('Ciorba de fasole in paine', 5);

insert into meniuri(denumire, rating)
values('Paste carbonara', 2);

insert into meniuri(denumire, rating)
values('Paella', 1);

insert into meniuri(denumire, rating)
values('Cartofi prajiti cu piept de pui la gratar', 3);

commit;

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

--ORASE_PLECARE + ORASE_SOSIRE

insert into orase_plecare(id_oras, nume, nume_tara)
values('BuchRO', 'Bucuresti', 'Romania');

insert into orase_sosire(id_oras, nume, nume_tara)
values('BuchRO', 'Bucuresti', 'Romania');

insert into orase_plecare(id_oras, nume, nume_tara)
values('RomeIT', 'Roma', 'Italia');

insert into orase_sosire(id_oras, nume, nume_tara)
values('RomeIT', 'Roma', 'Italia');

insert into orase_plecare(id_oras, nume, nume_tara)
values('MadridSP', 'Madrid', 'Spania');

insert into orase_sosire(id_oras, nume, nume_tara)
values('MadridSP', 'Madrid', 'Spania');

insert into orase_plecare(id_oras, nume, nume_tara)
values('ParisFR', 'Paris', 'Franta');

insert into orase_sosire(id_oras, nume, nume_tara)
values('ParisFR', 'Paris', 'Franta');

insert into orase_plecare(id_oras, nume, nume_tara)
values('BerlinD', 'Berlin', 'Germania');

insert into orase_sosire(id_oras, nume, nume_tara)
values('BerlinD', 'Berlin', 'Germania');


commit;

--BILETE

insert into bilete(id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    denumire_meniu, oras_plecare, oras_sosire)
values(30, '10:50', to_date('18-06-2022', 'DD-MM-YYYY'), '10:50', to_date('18-06-2022', 'DD-MM-YYYY') + 1, 70.50, null, 70.50, 36, 'Paella', 'BuchRO', 'RomeIT');

insert into bilete(id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    denumire_meniu, oras_plecare, oras_sosire)
values(32, '06:57', to_date('18-06-2022', 'DD-MM-YYYY'), '00:26', to_date('18-06-2022', 'DD-MM-YYYY') + 1, 100, 'Elev 50%', 50, 38, 'Piure de cartofi cu friptura de porc', 'MadridSP', 'BerlinD');

insert into bilete(id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    denumire_meniu, oras_plecare, oras_sosire)
values(35, '08:49', to_date('18-06-2022', 'DD-MM-YYYY'), '23:56', to_date('18-06-2022', 'DD-MM-YYYY'), 80, 'Student 50%', 40, 40, null, 'BerlinD', 'ParisFR');

insert into bilete(id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    denumire_meniu, oras_plecare, oras_sosire)
values(33, '13:05', to_date('18-06-2022', 'DD-MM-YYYY'), '10:16', to_date('18-06-2022', 'DD-MM-YYYY') + 1, 150, 'Donator sange 25%', 112.5, 39, 'Ciorba de fasole in paine', 'RomeIT', 'MadridSP');

insert into bilete(id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    denumire_meniu, oras_plecare, oras_sosire)
values(34, '05:36', to_date('12-07-2019', 'DD-MM-YYYY'), '22:41', to_date('13-07-2019', 'DD-MM-YYYY') + 1, 120, null, 120, 37, null, 'BerlinD', 'MadridSP');

insert into bilete(id_calator, ora_plecare, data_plecare, ora_sosire, data_sosire, pret_initial, tip_reducere, pret_final, nr_tren,
                    denumire_meniu, oras_plecare, oras_sosire)
values(32, '07:20', to_date('15-08-2020', 'DD-MM-YYYY'), '03:25', to_date('15-08-2020', 'DD-MM-YYYY') + 1, 110, 'Elev 50%', 55, 38, 'Cartofi prajiti cu piept de pui la gratar', 'RomeIT', 'BuchRO');

commit;

--LUCREAZA_IN
insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(36, 20, to_date('25-03-2018', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(36, 29, to_date('25-03-2018', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(40, 25, to_date('26-04-2019', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru)
values(39, 45);

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(37, 28, to_date('10-11-2019', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru)
values(37, 29);

insert into lucreaza_in(nr_tren, id_membru)
values(36, 43);

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(36, 41, to_date('06-12-2021', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(39, 42, to_date('05-02-2019', 'DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru)
values(37, 27);

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(38, 45, to_date('13-05-2022','DD-MM-YYYY'));

insert into lucreaza_in(nr_tren, id_membru, data_ultima)
values(38, 42, to_date('13-05-2022','DD-MM-YYYY'));

commit;    

--SERVESTE
insert into serveste(id_membru, id_calator, denumire_meniu, nota_client)
values(41, 31, 'Paella', 8);

insert into serveste(id_membru, id_calator, denumire_meniu)
values(43, 35, 'Paella');

insert into serveste(id_membru, id_calator, denumire_meniu, nota_client)
values(42, 35, 'Piure de cartofi cu friptura de porc', 10);

insert into serveste(id_membru, id_calator, denumire_meniu, nota_client)
values(43, 34, 'Ciorba de fasole in paine', 6);

insert into serveste(id_membru, id_calator, denumire_meniu, nota_client)
values(44, 33, 'Paste carbonara', 7);

insert into serveste(id_membru, id_calator, denumire_meniu, nota_client)
values(45, 35, 'Pulpe de pui la cuptor cu cartofi si salata', 9);

insert into serveste(id_membru, id_calator, denumire_meniu, nota_client)
values(41, 31,'Cartofi prajiti cu piept de pui la gratar' , 5);

insert into serveste(id_membru, id_calator, denumire_meniu, nota_client)
values(45, 33,'Ciorba de fasole in paine' , 7);

insert into serveste(id_membru, id_calator, denumire_meniu, nota_client)
values(42, 34,'Paste carbonara' , 4);

insert into serveste(id_membru, id_calator, denumire_meniu)
values(41, 35,'Cartofi prajiti cu piept de pui la gratar');

commit;

--GATESTE
insert into gateste(id_membru, denumire_meniu)
values(25, 'Cartofi prajiti cu piept de pui la gratar');

insert into gateste(id_membru, denumire_meniu)
values(26, 'Cartofi prajiti cu piept de pui la gratar');

insert into gateste(id_membru, denumire_meniu)
values(27, 'Paste carbonara');

insert into gateste(id_membru, denumire_meniu)
values(27, 'Piure de cartofi cu friptura de porc');

insert into gateste(id_membru, denumire_meniu)
values(28, 'Pulpe de pui la cuptor cu cartofi si salata');

insert into gateste(id_membru, denumire_meniu)
values(28, 'Ciorba de fasole in paine');

insert into gateste(id_membru, denumire_meniu)
values(29, 'Ciorba de fasole in paine');

insert into gateste(id_membru, denumire_meniu)
values(28, 'Piure de cartofi cu friptura de porc');

insert into gateste(id_membru, denumire_meniu)
values(26, 'Paella');

insert into gateste(id_membru, denumire_meniu)
values(28, 'Paste carbonara');

insert into gateste(id_membru, denumire_meniu)
values(27, 'Ciorba de fasole in paine');

insert into gateste(id_membru, denumire_meniu)
values(29, 'Piure de cartofi cu friptura de porc');

commit;

--insert into orase_plecare(id_oras, nume, nume_tara)
--values('BuchRO', 'Bucuresti', 'Romania');
--
--insert into orase_plecare(id_oras, nume, nume_tara)
--values('RomeIT', 'Roma', 'Italia');
--
--insert into orase_plecare(id_oras, nume, nume_tara)
--values('MadridSP', 'Madrid', 'Spania');
--
--insert into orase_plecare(id_oras, nume, nume_tara)
--values('ParisFR', 'Paris', 'Franta');

--insert into orase_plecare(id_oras, nume, nume_tara)
--values('BerlinD', 'Berlin', 'Germania');



--LEGATE
insert into legate(oras1, oras2)
values('BerlinD', 'ParisFR');

insert into legate(oras1, oras2, an_constructie)
values('BerlinD', 'RomeIT', 1990);

insert into legate(oras1, oras2, an_constructie)
values('BerlinD', 'BuchRO', 2000);

insert into legate(oras1, oras2, an_constructie)
values('BuchRO', 'MadridSP', 2005);

insert into legate(oras1, oras2)
values('ParisFR', 'RomeIT');

insert into legate(oras1, oras2, an_constructie)
values('BuchRO', 'ParisFR', 2000);

insert into legate(oras1, oras2, an_constructie)
values('BerlinD', 'MadridSP', 1975);

insert into legate(oras1, oras2, an_constructie)
values('MadridSP', 'ParisFR', 1990);

insert into legate(oras1, oras2, an_constructie)
values('MadridSP', 'RomeIT', 2008);

insert into legate(oras1, oras2, an_constructie)
values('BuchRO', 'RomeIT', 2010);

commit;
--CONTROLEAZA
insert into controleaza(id_calator, ora_plecare, data_plecare, id_membru)
values(32, '07:20', to_date('15-08-2020', 'DD-MM-YYYY'), 20);

insert into controleaza(id_calator, ora_plecare, data_plecare, id_membru)
values(30, '10:50', to_date('18-06-2022', 'DD-MM-YYYY'), 24);

insert into controleaza(id_calator, ora_plecare, data_plecare, id_membru)
values(35, '08:49', to_date('18-06-2022', 'DD-MM-YYYY'), 21);

insert into controleaza(id_calator, ora_plecare, data_plecare, id_membru)
values(32, '06:57', to_date('18-06-2022', 'DD-MM-YYYY'), 23);

insert into controleaza(id_calator, ora_plecare, data_plecare, id_membru)
values(33, '13:05', to_date('18-06-2022', 'DD-MM-YYYY'), 22);

insert into controleaza(id_calator, ora_plecare, data_plecare, id_membru)
values(34, '05:36', to_date('12-07-2019', 'DD-MM-YYYY'), 21);

insert into controleaza(id_calator, ora_plecare, data_plecare, id_membru)
values(34, '05:36', to_date('12-07-2019', 'DD-MM-YYYY'), 24);

insert into controleaza(id_calator, ora_plecare, data_plecare, id_membru)
values(35, '08:49', to_date('18-06-2022', 'DD-MM-YYYY'), 23);

insert into controleaza(id_calator, ora_plecare, data_plecare, id_membru)
values(32, '06:57', to_date('18-06-2022', 'DD-MM-YYYY'), 24);

insert into controleaza(id_calator, ora_plecare, data_plecare, id_membru)
values(35, '08:49', to_date('18-06-2022', 'DD-MM-YYYY'), 24);

commit;

