select * from client;
select * from village;
select * from sejour;

declare
    iv village.idv%type;
    l_ids sejour.ids%type;
    a village.activite%type;
begin
    traitement2(4, 'Grenoble', 361, iv, l_ids, a);
    dbms_output.put_line('idv '||iv||', ids '||l_ids||', activite '||a);
    traitement2(4, 'Grenoble', 360, iv, l_ids, a);
    dbms_output.put_line('idv '||iv||', ids '||l_ids||', activite '||a);
end;
/
select * from sejour;