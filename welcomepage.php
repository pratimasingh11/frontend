<?php
error_reporting(0);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Content-Type: application/json");
header("Access-Control-Allow-Headers: Content-Type, X-Session-ID");

$host = 'localhost';
$username = 'root';
$password = '';
$dbname = 'easymeals';

$conn = new mysqli($host, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed: " . $conn->connect_error]));
}

// Read input JSON
$input = json_decode(file_get_contents("php://input"), true);

// Ensure both branch_id and user_id are provided
$branch_id = $input['branch_id'] ?? null;
$user_id = $input['user_id'] ?? null;

if (empty($branch_id) || empty($user_id)) {
    echo json_encode(["success" => false, "message" => "Branch ID and User ID are required"]);
    exit;
}

// Fetch branch details
$sql = "SELECT branch_name FROM branches WHERE branch_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param('i', $branch_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        "success" => true,
        "branch_name" => $row['branch_name']
    ]);
} else {
    echo json_encode(["success" => false, "message" => "No branch found"]);
}

$stmt->close();
$conn->close();
?>
