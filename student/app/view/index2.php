<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Feedback Page</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="feedback-container">
        <?php
            // Check if the success parameter is present in the URL
            if (isset($_GET['success']) && $_GET['success'] == 1) {
                echo '<div class="feedback-message">';
                echo '<p>Your Feedback Sent successfully</p>';
                echo '<button onclick="window.history.back()">Go Back</button>';
                echo '</div>';
            }
        ?>
    </div>
    <style>
        body {
    font-family: Arial, sans-serif;
    background-color: #f0f0f0;
    margin: 0;
    padding: 0;
}

.feedback-container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
     
}

.feedback-message {
    background-color: #ffffff;
    padding: 40px;
    border-radius: 5px;
    box-shadow: 10px 20px 20px 10px  rgba(255, 50, 0, 0.1);
    text-align: center;
     width: 30rem;
     height: 7rem;
}

.feedback-message p {
    margin: 0;
    font-size: xx-large;
}

.feedback-message button {
    padding: 10px 20px;
    margin-top: 35px;
    background-color: #007bff;
    color: #ffffff;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    width: 10rem;
    font-size: x-large;

}

.feedback-message button:hover {
    background-color: #0056b3;
}

    </style>
</body>
</html>
