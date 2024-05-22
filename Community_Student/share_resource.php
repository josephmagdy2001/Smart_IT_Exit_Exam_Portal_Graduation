<?php
session_start();

if (!isset($_SESSION['id'])) {
    header("Location: login.html");
    exit();
}

$user_id = $_SESSION['id'];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Share Resource</title>
    <link rel="stylesheet" href="login.css">
</head>
<body>
    <div class="form-container">
        <h1>Share a Resource</h1>
        <form action="submit_resource.php" method="POST" class="share-form">
            <input type="hidden" name="user_id" value="<?php echo $user_id; ?>">
            <div class="form-group">
                <label for="student_id" class="form-label">Student ID:</label>
                <input type="text" id="student_id" name="student_id" value="<?php echo $user_id; ?>" readonly class="form-input">
            </div>
            <div class="form-group">
                <label for="title" class="form-label">Title:</label>
                <input type="text" id="title" name="title" required class="form-input">
            </div>
            <div class="form-group">
                <label for="description" class="form-label">Description:</label>
                <textarea id="description" name="description" required class="form-input"></textarea>
            </div>
            <div class="form-group">
                <label for="url" class="form-label">URL:</label>
                <input type="url" id="url" name="url" required class="form-input">
            </div>
            <button type="submit" class="submit-button">Share</button>
        </form>
    </div>
</body>
</html>

