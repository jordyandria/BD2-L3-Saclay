/* Contraintes SQL et non SQL. 

Contraintes SQL (bonus en partiel/examen si presentation comme suit) :

client :
    idc pk
    nom not null
    age not null check 16<=age<=120
    avoir not null check 0<=avoir<=2000

village :
    idv pk
    ville not null
    activite -- null possible
    prix not null check 0<prix<=2000
    capacite not null check 1<=capacite<=1000

sejour :
    ids pk
    idc fk client not null -- rappel : fk n'implique pas not null
    idv fk village not null
    jour not null check 1<=jour<=365
    (idc, jour) unique 

creer sequences pour client, village, sejour

Contraintes non SQL : 

1. le nombre de sejours pour un centre pour un jour ne peut pas
depasser sa capacite :

  pour tout idv i de capacite n dans village,
  il y a au plus n lignes avec idv i pour chaque jour j dans sejour

2. l'avoir d'un client plus la somme des prix de ses sejours ne peut
exceder 2000 :

  pour tout idc i dans client : avoir + S <= 2000
  en effet, un client part de 2000 et achete des sejours, donc :
  avoir + somme des prix de ses sejours presents + somme des prix de
  ses sejours detruits = 2000 ;
  donc avoir + somme des prix de ses sejours presents <= 2000 ;
  comment obtient-on S : considerons toutes les lignes d'idc i dans
  sejour, et pour chacune, a partir de sa colonne idv dans sejour, son
  prix dans village identifie par idv ; on note S la somme de tous ces
  prix 
*/
  
-------------------------------------------------------------------------------
/* Rappel : 
Null : 
Peuvent etre "null" les valeurs intuitivement non
indispensable au fonctionnement de l'application. De plus, par
convention dans le module les colonnes utilisees en parametres ou a
l'interieur d'un traitement ne peuvent etre "null", mais il n'est pas
impose que celles en sortie d'un traitement ne le soient pas. 
Rappel : fk et check n'impliquent pas not null. 

Contraintes non SQL :
en general, il s'agit de compter un ensemble de lignes d'une table, ou de
comparer des valeurs dans deux tables, ou des variantes de ces situations
(ex : somme d'un ensemble de lignes). */

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
drop table sejour cascade constraints;
drop table client cascade constraints;
drop table village cascade constraints;

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








