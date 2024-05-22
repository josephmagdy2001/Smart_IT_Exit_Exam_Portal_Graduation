<?php
session_start();

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "o6u_onlineq";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $conn->real_escape_string($_POST['email']);
    $phone = $conn->real_escape_string($_POST['phone']);

    // Check if email and phone match a user in the database
    $sql = "SELECT * FROM student WHERE email = '$email' AND phone = '$phone'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        // User authenticated successfully
        $row = $result->fetch_assoc();
        $_SESSION['id'] = $row['id']; // Save user ID in session
        header("Location: share_resource.php");
        exit();
    } else {
        // Authentication failed
        echo "Invalid email or phone number.";
    }
}

$conn->close();
?>
