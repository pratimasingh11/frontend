<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "easymeals";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, X-Session-ID");
header('Content-Type: application/json');

// Get the raw POST data
$data = json_decode(file_get_contents("php://input"), true);

// Debugging: Log incoming data
error_log(print_r($data, true));

if (!$data || !isset($data['order_id'])) {
    echo json_encode(["success" => false, "message" => "Order ID is missing"]);
    exit();
}

$order_id = $data['order_id'];

// Prepare the SQL statement to mark the order as delivered
$sql = "UPDATE orders SET status = 'delivered' WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $order_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode(["success" => true, "message" => "Order marked as delivered"]);
    } else {
        echo json_encode(["success" => false, "message" => "Order not found or already delivered"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Database error: " . $stmt->error]);
}

// Close the statement
$stmt->close();
$conn->close();
?>