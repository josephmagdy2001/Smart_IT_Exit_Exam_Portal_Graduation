<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Us Messages</title>
    <link rel="stylesheet" href="styles.css">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
    <div class="container">
        <h2>Contact Us OF Technical Support</h2>
        <a href="/online-exam-system-master/instructor/?instructors "><input id="btn1" class='btn btn-warning' type="button" value="Back"></a>
<style>
    #btn1{
    width: 7rem;
    height: 5vh;
}
</style>
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Subject</th>
                    <th>Message</th>
                    <th>Created At</th>
                    <th>Delete</th>
                </tr>
            </thead>
            <tbody>
                <?php
                // Establish database connection
                $servername = "localhost";
                $username = "root";
                $password = "";
                $dbname = "o6u_onlineq";
                
                $conn = new mysqli($servername, $username, $password, $dbname);
                if ($conn->connect_error) {
                    die("Connection failed: " . $conn->connect_error);
                }
                
                // Fetch data from database
                $sql = "SELECT id, name, email, subject, message, created_at FROM ContactSupport";
                $result = $conn->query($sql);
                
                // Display data in table rows
                if ($result->num_rows > 0) {
                    while ($row = $result->fetch_assoc()) {

                        echo "<tr>";
                        echo "<td>" . $row['name'] . "</td>";
                        echo "<td>" . $row['email'] . "</td>";
                        echo "<td>" . $row['subject'] . "</td>";
                        echo "<td>" . $row['message'] . "</td>";
                        echo "<td>" . $row['created_at'] . "</td>";
                        echo "<td>";
                        echo "<form method='post' action='delete_contact.php'>";
                        echo "<input type='hidden' name='contact_id' value='" . $row['id'] . "'>";
                        echo "<button type='submit' class='btn btn-danger'>Delete</button>";
                        echo "</form>";
                        echo "</td>";
                        echo "</tr>";
 
                    }
                } else {
                    echo "<tr><td colspan='6'>No contact messages found</td></tr>";
                }
                $conn->close();
                ?>
            </tbody>
        </table>
    </div>

    <style>
        body {
            font-family: Arial, sans-serif;
  background-image: linear-gradient(90deg, rgba(233, 233, 233, 1), rgba(172, 172, 172, 1));
            margin: 0;
            padding: 0;
        }

        .container {
            width: 80%;
            margin: 20px auto;
        }

        h2 {
            text-align: center;
            margin-bottom: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        table, th, td {
            border: 1px solid #ddd;
            font-weight: bold;
        }

        th, td {
            padding: 8px;
            text-align: left;
            text-align: center;
        }
       tr, td{
          max-width:  90%;
        }

        th {
            background-color: #f2f2f2;
        }
    </style>
</body>
</html>
