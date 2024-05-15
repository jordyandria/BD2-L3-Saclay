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
drop table sejour;
drop table client;
drop table village;

create table client(
    idc int,
    nom varchar2(10),
    age int,
    avoir int default 2000
);

create table village(
    idv int,
    ville varchar2(12),
    activite varchar2(10),
    prix int,
    capacite int
);

create table sejour(
    ids int,
    idc int,
    idv int,
    jour int
);

----------------------------------------------------------
-- 1.
insert into village values(10, 'NY', 'resto', 50, 200);
insert into village values(11, 'NY', 'MOMA', 60, 300);
insert into village values(12, 'Chatelaillon', 'kitesurf', 100, 20);
insert into village values(13, 'Chatelaillon', 'piscine', 20, 100);

-- 2.
select * from village;

-- 3.
update village
    set capacite = capacite + 20,
        prix = prix + 10
    where ville = 'NY';

select * from village;

INSERT INTO sejour (ids, idc, idv, jour) VALUES (1, 1, 11, 90);
INSERT INTO sejour (ids, idc, idv, jour) VALUES (2, 2, 2, 110);
INSERT INTO sejour (ids, idc, idv, jour) VALUES (3, 1, 3, 80);
INSERT INTO sejour (ids, idc, idv, jour) VALUES (4, 3, 1, 120);

-- 4.
select * from sejour;

-- 5.
select count(*) 
    from sejour 
    where jour<100;
delete sejour where jour<100;

select * from sejour;

-- 6.
insert into client (idc, nom, age) values (1, 'Doe', 20);
insert into client (idc, nom, age) values (2, 'Smith', 25);

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

insert into sejour (ids, idc, idv, jour) values (102, 2, 12, 100);

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







