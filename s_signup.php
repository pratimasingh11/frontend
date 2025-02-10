<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json");
header("Access-Control-Allow-Headers: Content-Type");
// Enabling error reporting for debugging
ini_set('display_errors', 1); // Show errors directly in the page
error_reporting(E_ALL); // Report all types of errors

// Database connection
$host = "localhost";
$username = "root";
$password = "";
$dbname = "easymeals";

// Creating the database connection
$conn = new mysqli($host, $username, $password, $dbname);

// Checking the connection error
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the data from Flutter (POST request)
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$college = $_POST['college'] ?? '';

// Validate input
if (empty($email) || empty($password) || empty($college)) {
    echo json_encode(["success" => false, "message" => "All fields are required."]);
    exit;
}

// Hash the password
$password_hash = password_hash($password, PASSWORD_DEFAULT);
$role = 'seller';

// Start transaction for atomic operation
$conn->begin_transaction();
try {
    // Check if the branch already exists
    $branchCheckStmt = $conn->prepare("SELECT branch_id FROM branches WHERE branch_name = ?");
    $branchCheckStmt->bind_param("s", $college);
    $branchCheckStmt->execute();
    $branchCheckStmt->bind_result($branch_id);
    $branchExists = $branchCheckStmt->fetch();
    $branchCheckStmt->close();

    if (!$branchExists) {
        // Insert the branch if it doesn't exist
        $insertBranchStmt = $conn->prepare("INSERT INTO branches (branch_name) VALUES (?)");
        $insertBranchStmt->bind_param("s", $college);
        $insertBranchStmt->execute();
        $branch_id = $insertBranchStmt->insert_id;
        $insertBranchStmt->close();
    }

    // Insert the user data into the users table
    $userStmt = $conn->prepare("INSERT INTO users (email, password_hash, branch_id, role) VALUES (?, ?, ?, ?)");
    $userStmt->bind_param("ssis", $email, $password_hash, $branch_id, $role);

    if ($userStmt->execute()) {
        $conn->commit();
        echo json_encode(["success" => true, "message" => "User signed up successfully!"]);
    } else {
        throw new Exception("Error: " . $userStmt->error);
    }

    $userStmt->close();
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}

$conn->close();
?>
