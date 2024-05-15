/*
    Enseignant:
        ide int pk
        nom varchar2(50) not null
        specialite varchar(50) not null
        serviceMax int not null check serviceMax <= valeur from LimiteService

    Cours :
        idc int pk
        titre varchar(50) unique not null
        specialite varchar(50) not null 
        volume int not null
        semestre int not null check 1 ou 2
        ide fk enseignant check ide is null or is not null
        check specialite = select specialite from Enseignant where ide = Enseignant.ide

    LimiteService :
        valeur int not null check valeur > 0
    
    creer sequence pour enseignant et cours

    Non sql :
    enseignant a un ou plusieurs cours ou aucun
    un cours ne peut pas avoir lieu deux fois dans l annee
    un cours est enseigne par un seul enseignant

    Responsable:
    - traitement3
    - tout consulter
    - ajouter des cours
    - modifier serviceMax

    Enseignant :
    - traitement2
    - traitement4
    - consulter cours non affectes
    - consulter ses infos
    avec son id


*/

set serveroutput on;

drop table enseignant cascade constraints;
drop table cours cascade constraints;
drop table limiteService cascade constraints;

drop sequence seq_enseignant;
drop sequence seq_cours;

create sequence seq_enseignant start with 1;
create sequence seq_cours start with 500;

create table enseignant(
    ide int primary key,
    nom varchar(50) not null,
    specialite varchar(50) not null,
    serviceMax int not null, check(serviceMax > 0)
);

create table cours(
    idc int primary key,
    titre varchar(50) not null unique,
    volume int not null, check (volume > 0),
    specialite varchar(50) not null,
    semestre int not null, check (semestre in (1, 2)),
    ide int, foreign key (ide) references enseignant
);

create table limiteService(
    valeur int, check (valeur > 0)
);

insert into limiteService values(1500);
insert into enseignant values(seq_enseignant.nextval, 'Dupont', 'Math', 175);
insert into enseignant values(seq_enseignant.nextval, 'Durand', 'Physique', 150);
insert into cours values(seq_cours.nextval, 'Algo', 80, 'Math', 1, 1);
insert into cours(idc, titre, volume, specialite, semestre) values(seq_cours.nextval, 'ISD', 100, 'BD', 2);
insert into cours(idc, titre, volume, specialite, semestre) values(seq_cours.nextval, 'Prog', 100, 'Physique', 1);
insert into cours values(seq_cours.nextval, 'Meca', 100, 'Physique', 2, 2);

select * from enseignant;
select * from cours;

create or replace procedure p2023_traitement3(cours_a_probleme out cours.titre%type, enseignant_depannage out enseignant.ide%type) 
is
    cursor probleme is
        select *
            from cours
            where semestre = 1 
                and ide IS NULL;
    cursor depannage is
        select *
            from cours
            where semestre = 2
                and ide IS NOT NULL;
    cursor bon_enseignant(la_specialite cours.specialite%type) is
        select *
            from enseignant
            where specialite = la_specialite;
    c_probleme probleme%rowtype;
    c_depannage depannage%rowtype;
    c_enseignant enseignant%rowtype;
begin 
    cours_a_probleme := 'neant';
    enseignant_depannage := -1;
    open probleme;
    fetch probleme into c_probleme;
    if probleme%found then
        cours_a_probleme := c_probleme.titre;
        open depannage;
        fetch depannage into c_depannage;
        if depannage%found then
            open bon_enseignant(c_probleme.specialite);
            fetch bon_enseignant into c_enseignant;
            if bon_enseignant%found then
                enseignant_depannage := c_enseignant.ide;
                update cours
                    set ide = c_enseignant.ide
                    where idc = c_probleme.idc;

                update cours
                    set ide = null
                    where idc = c_depannage.idc;
                
            end if;
            close bon_enseignant;
        end if;
        close depannage;
    end if;
    close probleme;
    dbms_output.put_line('Cours a probleme : ' || cours_a_probleme);
    dbms_output.put_line('Enseignant affecte id : ' || enseignant_depannage);
end;
/

set serveroutput on;
declare
    cours_a_probleme cours.titre%type;
    enseignant_depannage enseignant.ide%type;
begin
    p2023_traitement3(cours_a_probleme, enseignant_depannage);
end;
/




