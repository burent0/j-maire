<?php
session_start();

$servername = "localhost";
$dbusername = "root";
$dbpassword = "";
$dbname = "adminsys";

$conn = new mysqli($servername, $dbusername, $dbpassword, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$uname = $_POST['username'] ?? '';
$pwd = $_POST['password'] ?? '';

$sql = "SELECT uid, username, password FROM users WHERE username = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $uname);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $row = $result->fetch_assoc();

    if (password_verify($pwd, $row['password'])) {
        $_SESSION['uid'] = $row['uid'];
        $_SESSION['username'] = $row['username'];
        header("Location: dashboard.php");
        exit();
    } else {
        header("Location: index.php?error=wrongpassword");
        exit();
    }
} else {
    header("Location: index.php?error=wrongusername");
    exit();
}

$stmt->close();
$conn->close();
?>