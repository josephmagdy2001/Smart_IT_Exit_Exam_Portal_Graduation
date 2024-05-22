 <!DOCTYPE html>
 <html lang="en">

 <head>
     <meta charset="UTF-8">
     <meta name="viewport" content="width=device-width, initial-scale=1.0">
     <title>Feedback Responses</title>
     <link rel="stylesheet" href="styles.css">
     <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
 
 </head>

 <body>
 <div class="container">
        <a href="/online-exam-system-master/instructor/?instructors"><input id="btn1" class='btn btn-warning' type="button" value="Back"></a>
        <h2>Feedback Responses Of Test </h2>
         <table id="feedbackTable">
             <thead>
             <button id="nextPageBtn"   >></button>
             <button id="previousPageBtn"   ><</button>


                 <tr>
                     <th>Name</th>
                     <th>Student ID</th>
                     <th>Have a problem?</th>
                     <th>What is The problem</th>
                     <th>Satisfied | Dissatisfied</th>
                     <th>What is Your Suggestion </th>
                     <th>Created At</th>
                     <th>Delete permanently</th>
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
$sql = "SELECT id, name, ID_Student, type, favorite_sport, favorite_sport_person, feedback, created_at FROM survey_responses";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        echo "<tr>";
        echo "<td>" . $row['name'] . "</td>";
        echo "<td>" . $row['ID_Student'] . "</td>";
        echo "<td>" . $row['type'] . "</td>";
        echo "<td>" . $row['favorite_sport'] . "</td>";
        echo "<td>" . $row['favorite_sport_person'] . "</td>";
        echo "<td>" . $row['feedback'] . "</td>";
        echo "<td>" . $row['created_at'] . "</td>";
        echo "<td><form method='post' action='remove_feedback.php'>";
        echo "<input type='hidden' name='feedback_id' value='" . $row['id'] . "'>";
        echo "<button type='submit' class='btn btn-danger'>Remove Feedback</button>";
        echo "</form></td>";
        echo "</tr>";
    }
} else {
    echo "<tr><td colspan='8'>No feedback responses found</td></tr>";
}
$conn->close();
?>


             </tbody>
         </table>
         <script>
  document.addEventListener("DOMContentLoaded", function () {
  var table = document.getElementById("feedbackTable");
  var rowsPerPage = 5; // Number of rows per page
  var rows = table.getElementsByTagName("tr");
  var currentPage = 1;

  // Function to display rows for the current page
  function displayRows(page) {
    var startIndex = (page - 1) * rowsPerPage;
    var endIndex = startIndex + rowsPerPage;

    for (var i = 0; i < rows.length; i++) {
      rows[i].style.display = i >= startIndex && i < endIndex ? "" : "none";
    }
  }

  // Initial display of rows
  displayRows(currentPage);

  // Pagination button event listener for next page
  var nextPageBtn = document.getElementById("nextPageBtn");
  nextPageBtn.addEventListener("click", function () {
    if (currentPage < Math.ceil(rows.length / rowsPerPage)) {
      currentPage++;
      displayRows(currentPage);
    } else {
      // Handle reaching the last page (optional)
      console.log("You're already on the last page."); // Or provide a visual indicator
    }
  });

  // Pagination button event listener for previous page (fixed)
  var previousPageBtn = document.getElementById("previousPageBtn");
  previousPageBtn.addEventListener("click", function () {
    if (currentPage > 1) {
      currentPage--;
      displayRows(currentPage);
    } else {
      // Handle reaching the first page (optional)
      console.log("You're already on the first page."); // Or provide a visual indicator
    }
  });
});
</script>
 
 

     </div>
<?php

require_once 'barchartofStudent.php';


?>
     <style>
         body {
             font-family: Arial, sans-serif;
               margin: 0;
             padding: 0;
             background-image: linear-gradient(90deg, rgba(233, 233, 233, 1), rgba(172, 172, 172, 1));


         }

         .container {
             width: 100%;
             margin: 20px auto;
         }

         h2 {
             text-align: center;
             margin-bottom: 20px;
         }

         table {
             width: 100%;
              border: 5px solid rgba(25, 25, 55, 1);
              background-color: #f2f2f2;
  
         }

         table,
         th,
         td {
              font-weight: bold;
             border: 5px solid rgba(255, 255, 255,  0.5);

 

         }

         th,
         td {
             padding: 80px;
             text-align: left;
             text-align: center;
          

         }

         th {
             background-color: #f2f2f2;
         }

         #btn1 {
             width: 7rem;
             height: 5vh;
         }
     </style>
 </body>

 </html>