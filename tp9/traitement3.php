<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Traitement 3</title>
</head>
<body>
    <h1> Question 2 : Traitement 3 </h1>
        <?php
            if(isset($_REQUEST['jour'])) {
                $jour = $_REQUEST['jour'];
                $texte = 'delete sejour where jour < ' . $jour;
                $connection = oci_connect('c##jandria_a', 'jandria_a', 'dbinfo');
                $ordre = oci_parse($connection, $texte);
                oci_execute($ordre);
                echo "nombre de lignes détruites : ". oci_num_rows($ordre);
                oci_close($connection);
            } else{
                echo "Veuillez entrer un jour";
            }
        ?>
    
</body>
</html>