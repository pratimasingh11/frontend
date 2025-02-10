<?php
// Error handling settings
error_reporting(0);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt'); // Log errors to a file

// Start session only if not already active
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

// Set response headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Content-Type: application/json");
header("Access-Control-Allow-Headers: Content-Type, X-Session-ID");

// Log session details for debugging
error_log("Received Session ID: " . ($_SERVER['HTTP_X_SESSION_ID'] ?? 'None'));

// Set session ID if provided
if (!empty($_SERVER['HTTP_X_SESSION_ID'])) {
    session_write_close(); // Close any existing session
    session_id($_SERVER['HTTP_X_SESSION_ID']);
    session_start();
    error_log("Session restored. Current Session ID: " . session_id());
}

// Database connection
$host = "localhost";
$username = "root";
$password = "";
$dbname = "easymeals";

$conn = new mysqli($host, $username, $password, $dbname);
if ($conn->connect_error) {
    error_log("Database connection failed: " . $conn->connect_error);
    echo json_encode(["success" => false, "message" => "Database connection error"]);
    exit;
}

// Fetch request body
$data = json_decode(file_get_contents("php://input"), true);
$branch_id = $data['branch_id'] ?? null;

if (!$branch_id) {
    echo json_encode(["success" => false, "message" => "Branch ID is missing."]);
    exit;
}

// Fetch branch details
$sql = "SELECT branch_name FROM branches WHERE branch_id = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    error_log("Query preparation failed: " . $conn->error);
    echo json_encode(["success" => false, "message" => "Query preparation failed."]);
    exit;
}

$stmt->bind_param("i", $branch_id);
if ($stmt->execute()) {
    $result = $stmt->get_result();
    if ($row = $result->fetch_assoc()) {
        echo json_encode(["success" => true, "branch_name" => $row['branch_name'], "branch_id" => $branch_id]);
    } else {
        echo json_encode(["success" => false, "message" => "Branch not found."]);
    }
} else {
    error_log("Query execution error: " . $stmt->error);
    echo json_encode(["success" => false, "message" => "Query execution error."]);
}

// Close connections
$stmt->close();
$conn->close();
?>
