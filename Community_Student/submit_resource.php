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
    if(isset($_POST['user_id'])) {
        $user_id = $conn->real_escape_string($_POST['user_id']);
        $title = $conn->real_escape_string($_POST['title']);
        $description = $conn->real_escape_string($_POST['description']);
        $url = $conn->real_escape_string($_POST['url']);

        // Check if the user_id exists in the student table
        $check_sql = "SELECT * FROM student WHERE id = '$user_id'";
        $check_result = $conn->query($check_sql);
        if($check_result->num_rows > 0) {
            // User exists, proceed with inserting the resource
            $insert_sql = "INSERT INTO resources_students (id, title_of_resources, description, url) VALUES ('$user_id', '$title', '$description', '$url')";
            if ($conn->query($insert_sql) === TRUE) {
                echo "  Resource shared successfully";
            } else {
                echo " Error: " . $conn->error;
            }
        } else {
            echo " User does not exist.";
        }
    } else {
        echo " User ID not provided.";
    }
}

$conn->close();
?>
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resource shared</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

  </head>
  <body>
  <a href="http://localhost/online-exam-system-master"><input id="btn1" class='btn btn-warning' type="button" value="Back"></a>

  </body>
  </html>