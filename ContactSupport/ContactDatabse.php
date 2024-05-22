<?php
// Database connection
$servername = "localhost"; // Change this to your MySQL server name
$username = "root"; // Change this to your MySQL username
$password = ""; // Change this to your MySQL password
$dbname = "o6u_onlineq";

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Form submission handling
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Prepare and bind parameters
    $stmt = $conn->prepare("INSERT INTO ContactSupport (name, email, subject, message) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $name, $email, $subject, $message);

    // Set parameters and execute
    $name = $_POST['contact_nom'];
    $email = $_POST['contact_email'];
    $subject = $_POST['contact_sujet'];
    $message = $_POST['contact_message'];

    if ($stmt->execute() === TRUE) {
        // Redirect to success page
        header("Location: /online-exam-system-master/ContactSupport/success.php?success=1");
        exit();
    } else {
        echo "Error: " . $stmt->error;
    }

    $stmt->close();
}

// Close connection
$conn->close();
?>
