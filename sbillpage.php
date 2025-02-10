<?php
// Database connection
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

// Fetch all orders
$sql = "SELECT * FROM orders";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $orders = [];
    while ($row = $result->fetch_assoc()) {
        // Decode JSON items if necessary
        $row['items'] = json_decode($row['items'] ?? '[]', true);
        $orders[] = $row;
    }
    echo json_encode(["success" => true, "orders" => $orders]);
} else {
    echo json_encode(["success" => false, "message" => "No orders found"]);
}

$conn->close();
?>