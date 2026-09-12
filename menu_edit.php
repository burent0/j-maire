<?php
require 'connection.php';

$offering_id = isset($_GET['offering_id']) && $_GET['offering_id'] !== '' ? (int)$_GET['offering_id'] : null;
$price_variant_id = isset($_GET['price_variant_id']) && $_GET['price_variant_id'] !== '' ? (int)$_GET['price_variant_id'] : null;
$type_id = isset($_GET['type_id']) && $_GET['type_id'] !== '' ? (int)$_GET['type_id'] : null;
$back_url = 'menu_list.php' . ($type_id ? '?type_id=' . $type_id : '');

$data = [
    'category_id'   => '',
    'name'          => '',
    'description'   => '',
    'variant_label' => 'default',
    'price'         => '',
    'notes'         => ''
];

// Load existing values when editing
if ($offering_id) {
    $stmt = $connFarm->prepare("SELECT category_id, name, description FROM offerings WHERE id = ?");
    $stmt->bind_param("i", $offering_id);
    $stmt->execute();
    $res = $stmt->get_result();
    if ($row = $res->fetch_assoc()) {
        $data['category_id'] = $row['category_id'];
        $data['name'] = $row['name'];
        $data['description'] = $row['description'];
    }
    $stmt->close();

    if ($price_variant_id) {
        $stmt = $connFarm->prepare("SELECT variant_label, price, notes FROM price_variants WHERE id = ?");
        $stmt->bind_param("i", $price_variant_id);
        $stmt->execute();
        $res = $stmt->get_result();
        if ($row = $res->fetch_assoc()) {
            $data['variant_label'] = $row['variant_label'];
            $data['price'] = $row['price'];
            $data['notes'] = $row['notes'];
        }
        $stmt->close();
    }
}

// Handle save
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $category_id   = (int)$_POST['category_id'];
    $name          = trim($_POST['name']);
    $description   = trim($_POST['description']) !== '' ? trim($_POST['description']) : null;
    $variant_label = trim($_POST['variant_label']) !== '' ? trim($_POST['variant_label']) : 'default';
    $price         = trim($_POST['price']) !== '' ? (float)trim($_POST['price']) : null;
    $notes         = trim($_POST['notes']) !== '' ? trim($_POST['notes']) : null;

    if ($offering_id) {
        // Update the offering itself
        $stmt = $connFarm->prepare("UPDATE offerings SET category_id = ?, name = ?, description = ? WHERE id = ?");
        $stmt->bind_param("issi", $category_id, $name, $description, $offering_id);
        $stmt->execute();
        $stmt->close();

        if ($price_variant_id) {
            if ($price !== null) {
                $stmt = $connFarm->prepare("UPDATE price_variants SET variant_label = ?, price = ?, notes = ? WHERE id = ?");
                $stmt->bind_param("sdsi", $variant_label, $price, $notes, $price_variant_id);
                $stmt->execute();
                $stmt->close();
            } else {
                // Price cleared: remove this variant row
                $stmt = $connFarm->prepare("DELETE FROM price_variants WHERE id = ?");
                $stmt->bind_param("i", $price_variant_id);
                $stmt->execute();
                $stmt->close();
            }
        } elseif ($price !== null) {
            // No variant existed before, but a price was entered now
            $stmt = $connFarm->prepare("INSERT INTO price_variants (offering_id, variant_label, price, notes) VALUES (?, ?, ?, ?)");
            $stmt->bind_param("isds", $offering_id, $variant_label, $price, $notes);
            $stmt->execute();
            $stmt->close();
        }
    } else {
        // New offering
        $stmt = $connFarm->prepare("INSERT INTO offerings (category_id, name, description) VALUES (?, ?, ?)");
        $stmt->bind_param("iss", $category_id, $name, $description);
        $stmt->execute();
        $new_offering_id = $stmt->insert_id;
        $stmt->close();

        if ($price !== null) {
            $stmt = $connFarm->prepare("INSERT INTO price_variants (offering_id, variant_label, price, notes) VALUES (?, ?, ?, ?)");
            $stmt->bind_param("isds", $new_offering_id, $variant_label, $price, $notes);
            $stmt->execute();
            $stmt->close();
        }
    }

    header("Location: $back_url");
    exit();
}

// Categories for the dropdown
$cat_result = $connFarm->query("
    SELECT c.id, c.name AS category_name, ot.name AS type_name
    FROM categories c
    JOIN offering_types ot ON c.offering_type_id = ot.id
    ORDER BY ot.id, c.name
");
?>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= $offering_id ? 'Edit Item' : 'Add New Item' ?></title>
  <link rel="stylesheet" href="style.css">
</head>

<body>
  <div class="container">
    <div class="form-box">
      <h2><?= $offering_id ? 'Edit Item' : 'Add New Item' ?></h2>
      <form method="post">
        <select name="category_id" required style="width:100%;padding:12px;background:#eee;border-radius:6px;border:none;font-size:16px;color:#333;margin-bottom:20px;">
          <option value="">-- Select category --</option>
          <?php while ($c = $cat_result->fetch_assoc()): ?>
            <option value="<?= $c['id'] ?>" <?= (string)$c['id'] === (string)$data['category_id'] ? 'selected' : '' ?>>
              <?= htmlspecialchars($c['type_name'] . ' - ' . $c['category_name']) ?>
            </option>
          <?php endwhile; ?>
        </select>

        <input type="text" name="name" placeholder="Item name" value="<?= htmlspecialchars($data['name']) ?>" required />
        <input type="text" name="description" placeholder="Description (optional)" value="<?= htmlspecialchars($data['description'] ?? '') ?>" />
        <input type="text" name="variant_label" placeholder="Variant label (e.g. Medium, Adult, or leave as default)" value="<?= htmlspecialchars($data['variant_label']) ?>" />
        <input type="number" step="0.01" name="price" placeholder="Price (leave blank if none listed)" value="<?= htmlspecialchars((string)($data['price'] ?? '')) ?>" />
        <input type="text" name="notes" placeholder="Notes (optional)" value="<?= htmlspecialchars($data['notes'] ?? '') ?>" />

        <button type="submit">Save</button>
        <p><a href="<?= htmlspecialchars($back_url) ?>">Cancel</a></p>
      </form>
    </div>
  </div>
</body>

</html>