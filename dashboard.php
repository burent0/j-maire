<?php
session_start();

if (!isset($_SESSION['uid'])) {
    header("Location: index.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard</title>
  <link rel="stylesheet" href="style.css">
</head>

<body>
  <div class="container">
    <div class="form-box">
      <h2>Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></h2>
      <p><a href="menu_list.php">Manage Farm Menu</a></p>
      <p><a href="logout.php">Logout</a></p>
    </div>
  </div>
</body>

</html>