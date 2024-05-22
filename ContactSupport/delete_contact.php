<?php
session_start();
// Establish database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "o6u_onlineq";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check if contact_id is set and not empty
if(isset($_POST['contact_id']) && !empty($_POST['contact_id'])) {
    // Prepare SQL statement to delete contact message
    $stmt = $conn->prepare("DELETE FROM ContactSupport WHERE id = ?");
    $stmt->bind_param("i", $contact_id);

    // Set parameter
    $contact_id = $_POST['contact_id'];

    // Execute statement
    if ($stmt->execute()) {
        echo "Contact message deleted successfully.";
    } else {
        echo "Error deleting contact message: " . $conn->error;
    }

    // Close statement
    $stmt->close();
} else {
    echo "Invalid request.";
}

// Close database connection
$conn->close();

// Redirect back to the page displaying contact us messages
header("Location: ViewFeedbackAdmin.php");
exit();
?>
