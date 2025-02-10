<?php
session_start();
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Content-Type: application/json");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Check if session variables exist
if (!isset($_SESSION['session_id']) || !isset($_SESSION['email'])) {
    echo json_encode(["success" => false, "message" => "Session expired, please log in again."]);
    exit;
}

echo json_encode([
    "success" => true,
    "message" => "Session is active",
    "user" => [
        "email" => $_SESSION['email'],
        "user_id" => $_SESSION['user_id'],
        "branch_id" => $_SESSION['branch_id']  
    ]
]);

?>
