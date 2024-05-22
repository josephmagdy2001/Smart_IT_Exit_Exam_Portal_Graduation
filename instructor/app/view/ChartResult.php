<?php
if (!defined('NotDirectAccess')) {
    die('Direct Access is not allowed to this page');
}
require_once 'header.php';
require_once 'navbar.php';

class ResultAnalyzer extends dbh
{
    public function getAllResultIDs()
    {
        $stmt = $this->connect()->query("
            SELECT DISTINCT resultID FROM result_answers
        ");
        $result = $stmt->fetchAll(PDO::FETCH_COLUMN);
        return $result;
    }

    public function getQuestionDifficultyStats($resultID)
    {
        $stmt = $this->connect()->prepare("
            SELECT q.difficulty, COUNT(ra.questionID) AS solvedCount
            FROM result_answers ra
            INNER JOIN question q ON ra.questionID = q.id
            WHERE ra.resultID = :resultID AND ra.isCorrect = 1
            GROUP BY q.difficulty
        ");
        $stmt->bindParam(":resultID", $resultID);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $result;
    }
    public function getNumStudentsPerTestName()
    {
        $stmt = $this->connect()->query("
        SELECT t.name, COUNT(DISTINCT r.studentID) AS numStudents
        FROM test t
        LEFT JOIN result r ON t.id = r.testID
        GROUP BY t.name
    ");
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $results;
    }

    public function showBarChartForCourse($courseID, $instructorID)
    {
        // Retrieve data from the database based on the provided course ID and instructor ID

        // Example SQL query to retrieve data
        // Adjust this query according to your database structure and requirements
        $stmt = $this->connect()->prepare("
            SELECT * FROM test WHERE courseID = :courseID AND instructorID = :instructorID
        ");
        $stmt->bindParam(":courseID", $courseID);
        $stmt->bindParam(":instructorID", $instructorID);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $result;
        // Process the retrieved data if needed

    }

    public function getTotalStudentsInGroup()
    {
        try {
            // Connect to the database
            $conn = new PDO("mysql:host=localhost;dbname=o6u_onlineq", "root", "");
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

            // Prepare SQL query to count distinct student IDs from the group
            $stmt = $conn->prepare("SELECT COUNT(DISTINCT studentID) AS totalStudents FROM result");
            $stmt->execute();

            // Fetch the total number of students
            $totalStudents = $stmt->fetch(PDO::FETCH_ASSOC)['totalStudents'];

            return $totalStudents;
        } catch (PDOException $e) {
            // Handle any exceptions (e.g., output error message for debugging)
            echo "Error: " . $e->getMessage();
            return null; // Return null on failure
        }
    }

    public function getAllGroups()
    {
        try {
            // Connect to the database
            $conn = new PDO("mysql:host=localhost;dbname=o6u_onlineq", "root", "");
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

            // Retrieve all groups
            $stmt = $conn->query("SELECT id, name FROM groups");
            $groups = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return $groups;
        } catch (PDOException $e) {
            // Handle any exceptions (e.g., output error message for debugging)
            echo "Error: " . $e->getMessage();
            return null; // Return null on failure
        }
    }

    public function getStudentsNotEnteredQuiz($groupID)
    {
        try {
            // Connect to the database
            $conn = new PDO("mysql:host=localhost;dbname=o6u_onlineq", "root", "");
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

            // Retrieve the list of all students in the group
            $stmtAllStudents = $conn->prepare("SELECT DISTINCT studentID FROM groups_has_students WHERE groupID = :groupID");
            $stmtAllStudents->bindParam(':groupID', $groupID);
            $stmtAllStudents->execute();
            $allStudents = $stmtAllStudents->fetchAll(PDO::FETCH_COLUMN);

            // Retrieve the list of students who entered the quiz
            $stmtEnteredStudents = $conn->prepare("SELECT DISTINCT studentID FROM result WHERE groupID = :groupID");
            $stmtEnteredStudents->bindParam(':groupID', $groupID);
            $stmtEnteredStudents->execute();
            $enteredStudents = $stmtEnteredStudents->fetchAll(PDO::FETCH_COLUMN);

            // Find students who did not enter the quiz
            $notEnteredStudents = array_diff($allStudents, $enteredStudents);

            return $notEnteredStudents;
        } catch (PDOException $e) {
            // Handle any exceptions (e.g., output error message for debugging)
            echo "Error: " . $e->getMessage();
            return null; // Return null on failure
        }
    }
} // end The Class Methods ********************************

class Joe extends dbh
{
    // Database connection
    public function fetchResultData()
    {
        try {
            $conn = $this->connect();
            // Set the PDO error mode to exception
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

            // SQL query to fetch result data including test name and group name
            $sql = "SELECT r.id, r.studentID, r.testID, r.groupID, t.name AS testName, g.name AS groupName,
                    r.endTime AS testEndTime, r.startTime AS testStartTime,
                    TIMEDIFF(r.endTime, r.startTime) AS timeDifference
                    FROM result r
                    JOIN test t ON r.testID = t.id
                    JOIN groups g ON r.groupID = g.id";

            // Prepare statement
            $stmt = $conn->prepare($sql);

            // Execute statement
            $stmt->execute();

            // Fetch result
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return $result;
        } catch (PDOException $e) {
            echo "Connection failed: " . $e->getMessage();
        }
    }
}

// Instantiate the Joe class
$joe = new Joe();
// Call the fetchResultData() method to get the result data
$resultData = $joe->fetchResultData();

class PointTest extends dbh
{
    public function getTestPoints($resultID)
    {
        $stmt = $this->connect()->prepare("
            SELECT SUM(q.points) AS testPoints
            FROM result_answers ra
            INNER JOIN question q ON ra.questionID = q.id
            WHERE ra.resultID = :resultID AND ra.isCorrect = 1
        ");
        $stmt->bindParam(":resultID", $resultID);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['testPoints'];
    }
}

// Instantiate the classes
$resultAnalyzer = new ResultAnalyzer();
$pointTest = new PointTest();
// Get all result IDs
$resultIDs = $resultAnalyzer->getAllResultIDs();
$totalStudents = $resultAnalyzer->getTotalStudentsInGroup();

 

// If no result is found, display a 404 Not Found message
if (empty($resultIDs)) {
    header("HTTP/1.0 404 Not Found");
    include 'AccessDenied.php';
    exit;
}

////////////////******************** */
 $groups = $resultAnalyzer->getAllGroups();
if ($groups !== null) {
    // Display the list of groups as options in a form
    echo "<form class='Joe' method='post'>";
    echo "Select a group to view students who did not enter the quiz: ";
    echo "<select class='selectname' name='groupID'>";
    foreach ($groups as $group) {
        $id = $group['id'];
        $name = $group['name'];
        echo "<option value='$id'>$name</option>";
    }
    echo "</select>";
    echo "<input class=' btn btn-primary' type='submit' value='Submit'>";
    echo "</form>";

    // Check if a group ID was submitted
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        // Retrieve the selected group ID
        $selectedGroupID = $_POST['groupID'];

        // Get students who did not enter the quiz for the selected group
        $notEnteredStudents = $resultAnalyzer->getStudentsNotEnteredQuiz($selectedGroupID);

        if ($notEnteredStudents !== null) {
            if (empty($notEnteredStudents)) {
                echo " <h5>All students in Group $selectedGroupID have taken the test <b>So Don't Have a Result and Don't Show on Table </b>.</h5>";
            } else {
                echo "<h5>Students who did not enter the quiz from Group $selectedGroupID:<br></h5>";
                foreach ($notEnteredStudents as $student) {
                    echo "<h5>- Student ID: $student<br></h5> ";
                }
            }
        } else {
            echo "Failed to retrieve data.";
        }
    } else {
        echo "<h4>Try To Select .</h4>";
    }
} else {
    echo " <h4>No groups available.</h4>";
}

// Prepare data for the chart
 $labels = ['Easy', 'Moderate', 'Hard'];
$datasets = [];

foreach ($resultIDs as $resultID) {
    // Get the question difficulty stats for each result ID
    $questionStats = $resultAnalyzer->getQuestionDifficultyStats($resultID);
    $testPoints = $pointTest->getTestPoints($resultID);
    $numStudentsArray = $resultAnalyzer->getNumStudentsPerTestName(); // Retrieve all test names and their corresponding student counts

    $data = [0, 0, 0];

    // Populate data array with solved counts for each difficulty level
    foreach ($questionStats as $stat) {
        switch ($stat['difficulty']) {
            case 1:
                $data[0] = $stat['solvedCount'];
                break;
            case 2:
                $data[1] = $stat['solvedCount'];
                break;
            case 3:
                $data[2] = $stat['solvedCount'];
                break;
            default:
                break;
        }
    }

    $numStudents = 1;
    foreach ($numStudentsArray as $test) {
        if ($test['name'] == 'ResultID: ' . $resultID) {
            $numStudents = $test['numStudents'];
            break;
        }
    }

    // Add dataset for the current result ID
    $datasets[] = [
        'label' => 'Result Number: ' . $resultID . ' (Points: ' . $testPoints . ')',
        'data' => $data,
        'backgroundColor' => [
            'rgba(255, 150, 180, 0.5)',
            'rgba(54, 162, 235, 0.5)',
            'rgba(255, 206, 20, 0.5)',
        ],
        'borderColor' => [
            'rgba(255, 99, 132, 1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 206, 86, 5)',
        ],
        'borderWidth' => 0.5,
    ];

}
$labelsJSON = json_encode($labels);
$datasetsJSON = json_encode($datasets);
?>
<!DOCTYPE html>
<html>

<head>
    <title>Question Difficulty Stats</title>
    <!-- Include Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body>
    <canvas id="myChart" width="300" height="100">Your browser does not support the canvas element</canvas>

    <script>
        // Parse JSON data
        var labels = <?php echo $labelsJSON; ?>;
        var datasets = <?php echo $datasetsJSON; ?>;

        // Create data for the chart
        var chartData = {
            labels: labels,
            datasets: datasets
        };

        // Get the context of the canvas element we want to select
        var ctx = document.getElementById('myChart').getContext('2d');

        // Create the chart
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: chartData,
            options: {
                plugins: {
                    title: {
                        display: true,
                        text: 'Bar ChartData Of All Students ',
                        color: 'green',
                        font: {
                            size: 30,
                            family: 'cursive',
                            weight: 'bold',
                            style: 'oblique'
                        }
                    }
                },
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        });
    </script>
<style>
    .center-table {
  margin-left: auto;
  margin-right: auto;
  font-size: larger;
}
.Joe{
    font-size: x-large;
     
}
.selectname{
    font-size: large;
}
</style>
    <?php
    
// Display the result data in a table
if (!empty($resultData)) {
    // Larger, More Prominent Heading
    echo "<h2 style='font-size: 2em; font-family: cursive; font-weight: bold; font-style: oblique; color: green; text-align: center; margin-bottom: 1em;'>Result Data in Details:</h2>"; 

    // Table Styling (Retained from your original code)
    echo "<table class='center-table' border='3' style='text-align: center; width: 50%; height:400px; '>";
    echo "<tr><th style='color: red;'>Result Number</th><th style='color: red;'>Student ID</th> <th style='color: red;'>Test Name</th> <th style='color: red;'>Group Name</th><th style='color: red;'>Group Number</th><th style='color: red;'>Time Token</th></tr>";
    
    // Row Colors and Counters
    $rowColors = array('lightblue', 'lightgreen', 'Thistle', 'Thistle', 'Thistle');
    $index = 0;
    $uniqueStudentIDs = []; 
    $rowCount = 0;

    // Loop through Result Data
    foreach ($resultData as $row) {
        $color = $rowColors[$index % count($rowColors)]; 

        echo "<tr style='background-color: $color;'>";
        echo "<td>" . $row['id'] . "</td>";
        echo "<td>" . $row['studentID'] . "</td>";
        echo "<td>" . $row['testName'] . "</td>";
        echo "<td>" . $row['groupName'] . "</td>";
        echo "<td>" . $row['groupID'] . "</td>";
        echo "<td>" . $row['timeDifference'] . "</td>";
        echo "</tr>";

        $index++;
        $uniqueStudentIDs[] = $row['studentID'];
        $rowCount++;
    }

    echo "</table>";

    // Summary Messages with Formatting
    $uniqueStudentCount = count(array_unique($uniqueStudentIDs));
    echo "<p style='font-size: 1.2em;font-weight: bold; text-align: center;margin-top: 1em;'>Total Number of Students Who Entered the Quiz : <span style='font-weight: bold;'> $rowCount</span></p>"; 
    echo "<p style='font-size: 1.2em; font-weight: bold;text-align: center;'>Total Number of Unique Students : <span style='font-weight: bold;'> $uniqueStudentCount</span></p>";
} else {
    // No Data Message (Retained, but could be styled for consistency)
    echo "No result data found."; 
}
?>
</body>

</html>