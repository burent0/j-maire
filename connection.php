<?php
$servername = "localhost";
$dbusername = "root";
$dbpassword = "";

$connAdmin = new mysqli($servername, $dbusername, $dbpassword, "adminsys");
if ($connAdmin->connect_error) {
    die("Connection to adminsys failed: " . $connAdmin->connect_error);
}

$connFarm = new mysqli($servername, $dbusername, $dbpassword, "jmaire_farm");
if ($connFarm->connect_error) {
    die("Connection to jmaire_farm failed: " . $connFarm->connect_error);
}
?>