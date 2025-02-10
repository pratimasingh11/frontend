<?php
header('Content-Type: application/json');

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "easymeals";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get data from the request
$user_id = intval($_POST['user_id']); // User ID from the request
$points_to_add = floatval($_POST['points_to_add']); // Points to add to the user

// SQL query to update the loyalty points for the user
$sql = "UPDATE users SET loyalty_points = loyalty_points + ? WHERE user_id = ?";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(['error' => 'Failed to prepare the statement']);
    $conn->close();
    exit;
}

$stmt->bind_param("di", $points_to_add, $user_id);

// Execute the statement
if ($stmt->execute()) {
    echo json_encode(['success' => 'Loyalty points updated successfully']);
} else {
    echo json_encode(['error' => 'Failed to update loyalty points']);
}

// Close the connection
$stmt->close();
$conn->close();
?>