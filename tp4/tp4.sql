/*
Liste des actions :
Programmeur :
0 - Creer les tables client, village, sejour

Employes
1- creer village
2- consulter village
3- modifier village
4- consulter les sejours
5- faire le traitement 3

Client
6- Traitement 1
7- Traitement 2
8- consulter villages pour lesquels aucun sejour
9- consulter toutes ses informations :
     dans client
     dans sejour
     dans village

systeme : 
10- traitement 4 (quand destruction d'une ligne de sejour)
*/

----------------------------------------------------------
set serveroutput on;

drop table sejour cascade constraints;
drop table client cascade constraints;
drop table village cascade constraints;
drop table archive cascade constraints;

drop sequence seq_client;
drop sequence seq_village;
drop sequence seq_sejour;

create sequence seq_client start with 1;
create sequence seq_village start with 10;
create sequence seq_sejour start with 100;

create table client(
    idc int primary key,
    nom varchar2(10) not null,
    age int not null, check (age >= 8 and age <= 120),
    avoir int default 2000, check (avoir >= 0 and avoir <= 2000)
);

create table village(
    idv int primary key,
    ville varchar2(12) not null,
    activite varchar2(10), 
    prix int not null, check (prix >= 0 and prix <= 2000),
    capacite int not null, check (capacite > 0)
);
    
create table sejour(
    ids int primary key,
    idc int not null, foreign key (idc) references client,
    idv int not null, foreign key (idv) references village,
    jour int not null, check (jour >= 1 and jour <= 365),
    unique (idc, jour)
);

create table archive(
    ids int not null, foreign key (ids) references sejour,
    idc int not null, foreign key (idc) references client,
    idv int not null, foreign key (idv) references village,
    jour int not null, check (jour >= 1 and jour <= 365),
    avoir int
);


----------------------------------------------------------
-- 1.
insert into village values(seq_village.nextval, 'NY', 'resto', 50, 200);
insert into village values(seq_village.nextval, 'NY', 'MOMA', 60, 300);
insert into village values(seq_village.nextval, 'Chatelaillon', 'kitesurf', 100, 20);
insert into village values(seq_village.nextval, 'Chatelaillon', 'piscine', 20, 100);

/* modele d'ordre :
creer_village(v, a, p, c) :
    insert into village values(seq_village.nextval, v, a, p, c);
    -- rem : pas de retour
*/

create or replace procedure creer_village(la_ville village.ville%type, 
    l_activite village.activite%type, 
    le_prix village.prix%type, 
    la_capacite village.capacite%type)
is
begin 
    insert into village 
    values(seq_village.nextval, la_ville, l_activite, le_prix, la_capacite);
end;
/

exec creer_village('Grenoble', 'Ski', 150, 100);

-- 2.
select * from village;

-- 3.
update village
    set capacite = capacite + 20,
        prix = prix + 10
    where ville = 'NY';

/* modele d'ordre : ignore pour simplifier
parametres possibles : colonne et valeur de selection, valeur de modification
pour capacite et activite ; pas de retour ; 
colonne de selection en parametre est informel, mais on pourrait si on 
voulait coder par un entier chaque colonne et faire un switch
*/

select * from village;

-- INSERT INTO sejour (ids, idc, idv, jour) VALUES (seq_sejour.nextval, 1, 11, 90);
-- INSERT INTO sejour (ids, idc, idv, jour) VALUES (seq_sejour.nextval, 2, 2, 110);
-- INSERT INTO sejour (ids, idc, idv, jour) VALUES (seq_sejour.nextval, 1, 3, 80);
-- INSERT INTO sejour (ids, idc, idv, jour) VALUES (seq_sejour.nextval, 3, 1, 120);

-- 4.
select * from sejour;

-- 5.
select count(*) 
    from sejour 
    where jour<100;
delete sejour where jour<100;

/* modele d'ordre :
traitement3(le_jour) :
    select count(*)
        from sejour
        where jour < le_jour
        renvoie resultat dans : le_nombre;
    delete sejour 
        where jour < le_jour;
   retour traitement3 : le_nombre;

(variante possible : compter lignes, detruire, recompter et faire difference)
*/

create or replace function traitement3(
    le_jour sejour.jour%type)
    return integer
is
    le_nombre integer;
begin
    select count(*)
        into le_nombre
	from sejour
	where jour < le_jour;
    delete sejour
        where jour < le_jour;
    return le_nombre;
end;
/

create or replace procedure traitement3_out(
    le_jour sejour.jour%type,
    le_nombre out integer)
is
begin
    select count(*)
        into le_nombre
	from sejour
	where jour < le_jour;
    delete sejour
        where jour < le_jour;
end;
/

select * from sejour;
declare
    n int;
begin
    traitement3_out(364, n);
    dbms_output.put_line('Nombre de sejours detruits : '||n);
end;
/
select * from sejour;
declare
    n int;
begin
    traitement3_out(365, n);
    dbms_output.put_line('Nombre de sejours detruits : '||n);
end;
/

select * from sejour;

-- 6.
insert into client (idc, nom, age) values (seq_client.nextval, 'Doe', 20);
insert into client (idc, nom, age) values (seq_client.nextval, 'Smith', 25);

/* modele d'ordre :
traitement1(le_nom, l_age) :
    l_idc := seq_client.nextval; -- rem : variante par rapport a action 1
    insert into client(idc, nom, age) 
        values(l_idc, le_nom, l_age);
    retour traitement1 : l_idc;
*/

create or replace function traitement1(
    le_nom client.nom%type, l_age client.age%type)
    return client.idc%type
is
    l_idc client.idc%type;
begin 
    l_idc := seq_client.nextval;
    insert into client (idc, nom, age)
        values (l_idc, le_nom, l_age);
    return l_idc;
end;
/

select * from client;
exec dbms_output.put_line('nouvel identifiant : '||traitement1('Jeanne', 23));
select * from client;
exec dbms_output.put_line('nouvel identifiant : '||traitement1('Jules', 23));
select * from client;

select * from client;

-- 7.
-- Pour Smith
select idv, prix, activite 
    from village
    where ville = 'Chatelaillon'
        order by prix;
-- ici le plus cher est 100

update client
    set avoir = avoir - 100
    where idc = 2
        and nom = 'Smith';

insert into sejour (ids, idc, idv, jour) values (seq_sejour.nextval, 2, 12, 100);

select * from client;
select * from sejour;

/*
traitement2(l_idc, la_ville, le_jour)
    select idv, prix, actvite
        from village
        where ville = la_ville
        order by prix decresc
        renvoie resultat dans : l_idv, le_prix, l_activite;
    si resultat existe alors 
        l_ids := seq_sejour.nextval; -- rem : il faut le renvoyer
        insert into sejour 
            values(l_ids, l_idc, l_idv, le_jour);
        update client 
            set avoir = avoir - le_prix
            where idc = l_idc;
    sinon 
        l_idv := -1; 
        l_ids = -1; 
        l_activite := 'neant';
    retour traitement2 : l_idv, l_ids, l_activite;
*/ 

create or replace procedure traitement2(
    l_idc client.idc%type,
    la_ville village.ville%type,
    le_jour sejour.jour%type, 
    l_idv out village.idv%type, 
    l_ids out sejour.ids%type, 
    l_activite out village.activite%type)
is
    cursor c is
        select idv, prix, activite
            from village
            where ville = la_ville
            order by prix desc;
    l_prix village.prix%type;
begin
    open c;
    fetch c into l_idv, l_prix, l_activite;
    if c%found then
        l_ids := seq_sejour.nextval;
        insert into sejour 
            values(l_ids, l_idc, l_idv, le_jour);
        update client
            set avoir = avoir - l_prix
            where idc = l_idc;
    else
        l_idv := -1;
        l_ids := -1;
        l_activite := 'neant';
    end if;
end;
/

-- 8.
select * from village
    where idv not in (select idv from sejour);

-- 9.
-- authentification (consultation client) : 
-- exemple sur Rita, identifiant 1 :
select *
 from client
 where idc = 1
   and nom = 'Doe';

-- consultation autres tables : 

select ids, sejour.idc, idv, jour 
  from sejour, client
  where sejour.idc = client.idc
    and client.idc = 1
    and client.nom = 'Doe';

select village.idv, ville, activite, prix, capacite
  from village, sejour, client
  where sejour.idc = client.idc
    and client.idc = 1
    and client.nom = 'Doe'
    and village.idv = sejour.idv;

/* modeles d'ordre : 
authentification(l_idc, le_nom) :
    select *
        from client
        where idc = l_idc
          and nom = le_nom
        resultat dans le_client;
    si resultat existe alors
        print('bienvenue'||le_client);
    sinon
        print('desole, erreur identifiant/nom');
*/

create or replace procedure authentification(l_idc client.idc%type, le_nom client.nom%type)
is
    cursor c is
        select *
            from client
            where idc = l_idc
              and nom = le_nom;
    le_client c%rowtype;
    message varchar(50);
begin
    open c;
    fetch c into le_client;
    if c%found then
        message := 'Bienvenue ' || le_client.nom  || ', ' || le_client.age || ' ans, avoir : ' || le_client.avoir;
    else
        message := 'desole, erreur identifiant/nom';
    end if;
    dbms_output.put_line(message);
end;
/

/*
consulter_informations(l_idc) :
    select ids, idv, jour
        from sejour
        where sejour.idc = l_idc
        afficher toutes les lignes resultat;
    select village.idv, ville, activite, prix, capacite
        from village, sejour
        where sejour.idc = l_idc
          and village.idv = sejour.idv
        afficher toutes les lignes resultat;
*/

create or replace procedure consulter_informations1(l_idc client.idc%type)
is
    cursor c_village is
        select village.idv, ville, activite, prix, capacite
            from village, sejour
            where sejour.idc = l_idc
                and village.idv = sejour.idv;
    le_village c_village%rowtype;
begin
    dbms_output.put_line('Les sejour : ');
    for x in (
        select ids, idv, jour
            from sejour
            where sejour.idc = l_idc
    )
    loop 
        dbms_output.put_line('sejour : ids : ' || x.ids || '; idv : ' || x.idv || '; ' || x.jour || ' jours');
    end loop;
    dbms_output.put_line('Les villages : ');
    open c_village;
    fetch c_village into le_village;
    while c_village%found loop
        dbms_output.put_line('village : idv : ' || le_village.idv || ', a ' || le_village.ville || ', avec ' || le_village.activite || ', de ' || le_village.prix || 'euros, pour ' || le_village.capacite || 'personnes');
        fetch c_village into le_village;
    end loop;
    close c_village;
end;
/

CREATE OR REPLACE PROCEDURE consulter_informations2(l_idc client.idc%type)
IS
    CURSOR c_village IS
        SELECT v.idv, v.ville, v.activite, v.prix, v.capacite
        FROM village v
        JOIN sejour s ON v.idv = s.idv
        WHERE s.idc = l_idc;
    
    le_village c_village%rowtype;
    
BEGIN
    -- Affichage des séjours
    DBMS_OUTPUT.PUT_LINE('Les sejours : ');
    FOR x IN (
        SELECT ids, idv, jour
        FROM sejour
        WHERE idc = l_idc
    )
    LOOP 
        DBMS_OUTPUT.PUT_LINE('Szjour : ids : ' || x.ids || '; idv : ' || x.idv || '; ' || x.jour || ' jours');
    END LOOP;

    -- Affichage des villages
    DBMS_OUTPUT.PUT_LINE('Les villages : ');
    FOR le_village IN c_village LOOP
        DBMS_OUTPUT.PUT_LINE('Village : idv : ' || le_village.idv || ', a ' || le_village.ville || ', avec ' || le_village.activite || ', de ' || le_village.prix || ' euros, pour ' || le_village.capacite || ' personnes');
    END LOOP;
END;
/






-------------------------------------------------------------------------------
-- 10. (action faite par le systeme)

-- on suppose que le programmeur a cree dans l'action 0 la table
-- archive(ids, idc, idv, jour, avoir)

/* modele d'ordre : 
traitement 4(l_ids, l_idc, l_idv, le_jour)) : 
    -- ligne detruite supposee en parametre a ce stade du cours
    select avoir 
        from client 
        where idc = l_idc
        renvoie resultat dans : l_avoir
    insert into archive values(l_ids, l_idc, l_idv, le_jour, l_avoir);
*/

create or replace procedure traintement4(l_ids sejour.ids%type, 
    l_idc sejour.idc%type, 
    l_idv sejour.idv%type, 
    le_jour sejour.jour%type) 
is
    l_avoir client.avoir%type;
begin
    select avoir
        into l_avoir
        from client
        where idc = l_idc;
    insert into archive values(l_ids, l_idc, l_idv, le_jour, l_avoir);
end;
/