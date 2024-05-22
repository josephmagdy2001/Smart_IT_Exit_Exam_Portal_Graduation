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

// Check if feedback_id is set and not empty
if (isset($_POST['feedback_id']) && !empty($_POST['feedback_id'])) {
    // Sanitize input to prevent SQL injection
    $feedback_id = mysqli_real_escape_string($conn, $_POST['feedback_id']);

    // Prepare and execute delete query
    $sql = "DELETE FROM survey_responses WHERE id = '$feedback_id'";
    if ($conn->query($sql) === TRUE) {
        // Feedback successfully deleted
        header("Location: feedback.php"); // Redirect to feedback display page
        exit();
    } else {
        // Error deleting feedback
        echo "Error: " . $conn->error;
    }
} else {
    // Feedback ID not set or empty
    echo "Feedback ID not provided.";
}

$conn->close();
?>
