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

// Query to fetch resources shared by the logged-in student
$user_id = $_SESSION['id'];
$sql = "SELECT * FROM resources_students ";
echo"Hi Try to add a new resource ";
$result = $conn->query($sql);

$conn->close();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <title>Shared Resources</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 8px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>Shared Resources</h1>
    <a href="http://localhost/online-exam-system-master/student/?home"><input id="btn1" class='btn btn-warning' type="button" value="Back"></a>

    <table>
        <thead>
            <tr>
                <th>User ID</th>
                <th>Title</th>
                <th>Description</th>
                <th>URL</th>
                <th>Created At</th>
            </tr>
        </thead>
        <tbody>
            <?php
            if ($result->num_rows > 0) {
                while ($row = $result->fetch_assoc()) {
                    echo "<tr>";
                    echo "<td>" . $row['id'] . "</td>";
                    echo "<td>" . $row['title_of_resources'] . "</td>";
                    echo "<td>" . $row['description'] . "</td>";
                    echo "<td><a href='" . $row['url'] . "' target='_blank'>" . $row['url'] . "</a></td>";
                    echo "<td>" . $row['created_at'] . "</td>";
                    echo "</tr>";
                }
            } else {
                echo "<tr><td colspan='5'>No resources shared yet.</td></tr>";
            }
            ?>
        </tbody>
    </table>
</body>
</html>
