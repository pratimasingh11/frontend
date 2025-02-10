<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Database credentials
$servername = "localhost";
$username = "root"; 
$password = ""; 
$dbname = "easymeals"; 

// Connect to MySQL
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed: " . $conn->connect_error]));
}

// Handling POST request for subscribing
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Get request data
    $data = json_decode(file_get_contents("php://input"), true);

    // Validate input
    if (!isset($data['user_id'], $data['subscription_id'], $data['start_date'], $data['end_date'], $data['status'])) {
        echo json_encode(["success" => false, "message" => "Missing required fields"]);
        exit;
    }

    $user_id = $conn->real_escape_string($data['user_id']);
    $subscription_id = $conn->real_escape_string($data['subscription_id']);
    $start_date = $conn->real_escape_string($data['start_date']);
    $end_date = $conn->real_escape_string($data['end_date']);
    $status = $conn->real_escape_string($data['status']);

    // Check if the user already has an active subscription
    $sql_check = "SELECT * FROM user_subscriptions WHERE user_id = '$user_id' AND status = 'active' AND end_date >= CURDATE()";
    $result = $conn->query($sql_check);

    if ($result->num_rows > 0) {
        // User already has an active subscription
        echo json_encode(["success" => false, "message" => "You are already subscribed"]);
        exit;
    } else {
        // Insert new subscription
        $sql = "INSERT INTO user_subscriptions (user_id, subscription_id, start_date, end_date, status)
                VALUES ('$user_id', '$subscription_id', '$start_date', '$end_date', 'active')";

        if ($conn->query($sql) === TRUE) {
            echo json_encode(["success" => true, "message" => "Subscription successful"]);
        } else {
            echo json_encode(["success" => false, "message" => "Database error: " . $conn->error]);
        }
    }
}

// Close connection
$conn->close();
?>
