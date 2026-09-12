<?php
require 'connection.php';

// Offering types for the filter dropdown
$types_result = $connFarm->query("SELECT id, name FROM offering_types ORDER BY id");
$types = $types_result->fetch_all(MYSQLI_ASSOC);

// Selected type (default to the first one)
$selected_type_id = isset($_GET['type_id']) && $_GET['type_id'] !== ''
    ? (int)$_GET['type_id']
    : ($types[0]['id'] ?? 0);

$sql = "SELECT
            c.name AS category,
            o.id AS offering_id,
            o.name AS item,
            o.description AS item_description,
            pv.id AS price_variant_id,
            pv.variant_label,
            pv.price,
            pv.notes
        FROM offerings o
        JOIN categories c ON o.category_id = c.id
        JOIN offering_types ot ON c.offering_type_id = ot.id
        LEFT JOIN price_variants pv ON pv.offering_id = o.id
        WHERE ot.id = ?
        ORDER BY c.id, o.name, pv.variant_label";

$stmt = $connFarm->prepare($sql);
$stmt->bind_param("i", $selected_type_id);
$stmt->execute();
$result = $stmt->get_result();
?>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>J'Maire Farm Menu</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: Poppins, Arial, sans-serif; }
    body { background: #f4f4f4; padding: 30px; color: #333; }
    .wrap { max-width: 1150px; margin: 0 auto; }
    h2 { color: #3D583C; margin-bottom: 15px; }
    .toolbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap; gap: 10px; }
    .toolbar label { font-size: 14px; margin-right: 8px; }
    .toolbar select {
      padding: 8px 12px;
      border-radius: 6px;
      border: 1px solid #ccc;
      font-size: 14px;
      background: #fff;
    }
    .add-btn {
      display: inline-block;
      padding: 10px 20px;
      background: #3D583C;
      color: #fff;
      border-radius: 6px;
      text-decoration: none;
      font-size: 14px;
    }
    .add-btn:hover { background: #88c486; }
    table { width: 100%; border-collapse: collapse; background: #fff; }
    th, td { padding: 10px 12px; border: 1px solid #ddd; text-align: left; font-size: 14px; }
    th { background: #3D583C; color: #fff; }
    tr:nth-child(even) { background: #fafafa; }
    .actions a { margin-right: 12px; text-decoration: none; color: #3D583C; font-weight: 500; font-size: 13px; }
    .actions a.delete-link { color: #c0392b; }
  </style>
</head>

<body>
  <div class="wrap">
    <h2>J'Maire Farm Menu</h2>

    <div class="toolbar">
      <form method="get">
        <label for="type_id">Viewing:</label>
        <select name="type_id" id="type_id" onchange="this.form.submit()">
          <?php foreach ($types as $t): ?>
            <option value="<?= $t['id'] ?>" <?= $t['id'] == $selected_type_id ? 'selected' : '' ?>>
              <?= htmlspecialchars($t['name']) ?>
            </option>
          <?php endforeach; ?>
        </select>
      </form>
      <a class="add-btn" href="menu_edit.php?type_id=<?= $selected_type_id ?>">+ Add New Item</a>
    </div>

    <table>
      <tr>
        <th>Category</th>
        <th>Item</th>
        <th>Description</th>
        <th>Variant</th>
        <th>Price</th>
        <th>Notes</th>
        <th>Actions</th>
      </tr>
      <?php while ($row = $result->fetch_assoc()): ?>
      <tr>
        <td><?= htmlspecialchars($row['category']) ?></td>
        <td><?= htmlspecialchars($row['item']) ?></td>
        <td><?= htmlspecialchars($row['item_description'] ?? '') ?></td>
        <td><?= htmlspecialchars($row['variant_label'] ?? '') ?></td>
        <td><?= $row['price'] !== null ? number_format((float)$row['price'], 2) : '' ?></td>
        <td><?= htmlspecialchars($row['notes'] ?? '') ?></td>
        <td class="actions">
          <a href="menu_edit.php?offering_id=<?= (int)$row['offering_id'] ?>&price_variant_id=<?= $row['price_variant_id'] !== null ? (int)$row['price_variant_id'] : '' ?>&type_id=<?= $selected_type_id ?>">Edit</a>
          <a class="delete-link"
             href="menu_delete.php?offering_id=<?= (int)$row['offering_id'] ?>&price_variant_id=<?= $row['price_variant_id'] !== null ? (int)$row['price_variant_id'] : '' ?>&type_id=<?= $selected_type_id ?>"
             onclick="return confirm('Delete this row?');">Delete</a>
        </td>
      </tr>
      <?php endwhile; ?>
    </table>
  </div>
</body>

</html>