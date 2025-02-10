<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Start session at the beginning
session_start();

// Enable error reporting for debugging
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Database connection
$host = "localhost";
$db_name = "easymeals";
$db_user = "root";
$db_password = "";

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$conn = new mysqli($host, $db_user, $db_password, $db_name);

// Get raw POST data
$data = json_decode(file_get_contents("php://input"), true);
$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

// Validate input
if (empty($email) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Email and password are required"]);
    exit;
}

// Sanitize email
$email = filter_var($email, FILTER_SANITIZE_EMAIL);

// Prepare and execute SQL query
$sql = "SELECT user_id, email, password_hash, role, branch_id FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

// Check if user exists
if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "User not found"]);
    exit;
}

$user = $result->fetch_assoc();

// Verify password
if (empty($user['password_hash']) || !password_verify($password, $user['password_hash'])) {
    echo json_encode(["success" => false, "message" => "Invalid password"]);
    exit;
}

// Check if user 
if ($user['role'] !== 'user') { // ✅ Ensure correct role validation
    echo json_encode(["success" => false, "message" => "Access denied: Not a user"]);
    exit;
}

// Store session variables
$_SESSION['email'] = $user['email'];
$_SESSION['session_id'] = session_id();
$_SESSION['user_id'] = $user['user_id'];
$_SESSION['branch_id'] = $user['branch_id'];

// Response after successful login
echo json_encode([
    "success" => true,
    "message" => "Login successful",
    "session_id" => session_id(),
    "user" => [
        "id" => $user['user_id'],
        "email" => $user['email'],
        "branch_id" => $user['branch_id']
    ]
]);

$stmt->close();
$conn->close();
?>
