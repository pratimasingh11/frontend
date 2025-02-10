<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

$host = "localhost";
$username = "root";
$password = "";
$dbname = "easymeals";

$conn = new mysqli($host, $username, $password, $dbname);

if ($conn->connect_error) { 
    die("Connection failed: " . $conn->connect_error);
}

$full_name = $_POST['full_name'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$college = $_POST['college'] ?? '';

if (empty($full_name) || empty($email) || empty($password) || empty($college)) {
    echo json_encode(["success" => false, "message" => "All fields are required."]);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(["success" => false, "message" => "Invalid email format."]);
    exit;
}

$password_hash = password_hash($password, PASSWORD_DEFAULT);

$conn->begin_transaction();
try {
    $branchCheckStmt = $conn->prepare("SELECT branch_id FROM branches WHERE branch_name = ?");
    if ($branchCheckStmt === false) {
        throw new Exception("Prepare failed: " . $conn->error);
    }
    
    $branchCheckStmt->bind_param("s", $college);
    $branchCheckStmt->execute();
    $branchCheckStmt->bind_result($branch_id);
    $branchExists = $branchCheckStmt->fetch();
    $branchCheckStmt->close();

    if (!$branchExists) {
        $insertBranchStmt = $conn->prepare("INSERT INTO branches (branch_name) VALUES (?)");
        if ($insertBranchStmt === false) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        
        $insertBranchStmt->bind_param("s", $college);
        $insertBranchStmt->execute();
        $branch_id = $insertBranchStmt->insert_id;
        $insertBranchStmt->close();
    }

    $stmt = $conn->prepare("INSERT INTO users (full_name, email, password_hash, branch_id) VALUES (?, ?, ?, ?)");
    if ($stmt === false) {
        throw new Exception("Prepare failed: " . $conn->error);
    }
    
    $stmt->bind_param("sssi", $full_name, $email, $password_hash, $branch_id);

    if ($stmt->execute()) {
        $conn->commit();
        echo json_encode(["success" => true, "message" => "User signed up successfully!"]);
    } else {
        throw new Exception("Error: " . $stmt->error);
    }

    $stmt->close();
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}

$conn->close();

?>