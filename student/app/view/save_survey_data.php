<?php
session_start();

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "o6u_onlineq";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Prepare and bind parameters
$stmt = $conn->prepare("INSERT INTO survey_responses (name, ID_Student, type, favorite_sport, favorite_sport_person, feedback) VALUES (?, ?, ?, ?, ?, ?)");
$stmt->bind_param("sissss", $name, $id, $type, $favorite_sport, $favorite_sport_person, $feedback);

// Set parameters and execute
$name = $_POST['name'];
$id = $_POST['ID_Student'];
$type = $_POST['type'];
$favorite_sport = $_POST['favorite-sport'];
$favorite_sport_person = $_POST['favorite--sport'];
$feedback = $_POST['feedback'];

$stmt->execute();

header("Location: index2.php?success=1");

$stmt->close();
$conn->close();
?>
