

declare
    cours_pb cours.titre%type;
    enseignant_depannage enseignant.ide%type;
begin
    p2023_traitement3(cours_pb, enseignant_depannage);
end;
/   

select * from cours;
select * from enseignant;