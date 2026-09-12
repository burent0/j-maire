<?php
require 'connection.php';

$offering_id = isset($_GET['offering_id']) && $_GET['offering_id'] !== '' ? (int)$_GET['offering_id'] : null;
$price_variant_id = isset($_GET['price_variant_id']) && $_GET['price_variant_id'] !== '' ? (int)$_GET['price_variant_id'] : null;
$type_id = isset($_GET['type_id']) && $_GET['type_id'] !== '' ? (int)$_GET['type_id'] : null;

if ($price_variant_id) {
    // Row shown had a specific price variant: remove just that variant
    $stmt = $connFarm->prepare("DELETE FROM price_variants WHERE id = ?");
    $stmt->bind_param("i", $price_variant_id);
    $stmt->execute();
    $stmt->close();
} elseif ($offering_id) {
    // Row had no price variant (e.g. an Activity): remove the whole offering
    $stmt = $connFarm->prepare("DELETE FROM offerings WHERE id = ?");
    $stmt->bind_param("i", $offering_id);
    $stmt->execute();
    $stmt->close();
}

header("Location: menu_list.php" . ($type_id ? "?type_id=$type_id" : ""));
exit();
?>