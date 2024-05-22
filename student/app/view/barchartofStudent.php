<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "o6u_onlineq";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Count how many users responded with Yes, No, or Both
$sql = "SELECT   
            SUM(CASE WHEN type = 'Yes' THEN 1 ELSE 0 END) AS yes_count,
            SUM(CASE WHEN type = 'No' THEN 1 ELSE 0 END) AS no_count,
            SUM(CASE WHEN type = 'Both' THEN 1 ELSE 0 END) AS both_count
        FROM survey_responses";
$result = $conn->query($sql);
$row = $result->fetch_assoc();

 $yesCount = $row['yes_count'];
$noCount = $row['no_count'];
$bothCount = $row['both_count'];
  
if ($yesCount == 0 && $noCount == 0 && $bothCount == 0    ) {
    $message = "No feedback responses found.";
} else {
    $message = "Number Of Students Have Problem Said:  Yes =($yesCount ) || No =($noCount) || Both =($bothCount)";
}

$conn->close();
?>
<!DOCTYPE html>
<html>
<head>
    <title>Feedback Responses</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="container">
         <table id="feedbackTable">
            <tr>
                <th>Type</th>
                <th>Count</th>
            </tr>
            <tr>
                <td>Yes</td>
                <td><?php echo $yesCount; ?></td>
            </tr>
            <tr>
                <td>No</td>
                <td><?php echo $noCount; ?></td>
            </tr>
            <tr>
                <td>Both</td>
                <td><?php echo $bothCount; ?></td>
            </tr>
        </table>
        <?php if($yesCount > 0 || $noCount > 0 || $bothCount > 0): ?>
            <canvas id="feedbackChart" width="400" height="400"></canvas>
        <?php endif; ?>
    </div>

    <style>
        body{
            background-image: linear-gradient(90deg, rgba(233, 233, 233, 1), rgba(172, 172, 172, 1));
        }
        canvas {
            max-width: 600px;
        }
        .container {
            max-width: 1100px;
        }
        
        #feedbackTable {
            border-collapse: collapse;
            width: 100%;
        }
        #feedbackTable th, #feedbackTable td {
            border: 1px solid #dddddd;
            text-align: left;
            padding: 8px;
        }
        #searchInput {
            margin-bottom: 10px;
            padding: 8px;
            width: 100%;
            box-sizing: border-box;
        }
    </style>

 

    <script>
        <?php if($yesCount > 0 || $noCount > 0 || $bothCount > 0): ?>
            var ctx = document.getElementById('feedbackChart').getContext('2d');
            var myChart = new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: ['Yes', 'No', 'Both'],
                    datasets: [{
                        label: 'Feedback Responses',
                        data: [<?php echo $yesCount; ?>, <?php echo $noCount; ?>, <?php echo $bothCount; ?>],
                        backgroundColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 206, 86, 1)'
                        ],
                        borderColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 206, 86, 1)'
                        ],
                        borderWidth: 5
                    }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        <?php endif; ?>
    </script>
</body>
</html>
