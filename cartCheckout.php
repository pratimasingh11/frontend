<?php
// Set the response content type to JSON
header('Content-Type: application/json');

// Database connection
$host = "localhost";
$db_name = "easymeals";
$db_user = "root";
$db_password = "";

$conn = new mysqli($host, $db_user, $db_password, $db_name);

// Check if user_id is passed
if(isset($_POST['user_id'])) {
    $user_id = $_POST['user_id'];
    
    // Query to fetch user email and branch_name based on user_id
    $query = "SELECT u.email, b.branch_name FROM users u
              JOIN branches b ON u.branch_id = b.branch_id
              WHERE u.user_id = ?";
    if ($stmt = $conn->prepare($query)) {
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $stmt->bind_result($email, $branch_name);
        
        // Check if we got a result
        if ($stmt->fetch()) {
            // Return email and branch name as a JSON response
            echo json_encode([
                "success" => true,
                "email" => $email,
                "branch_name" => $branch_name
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "User not found"]);
        }
        $stmt->close();
    } else {
        echo json_encode(["success" => false, "message" => "Database query failed"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "User ID not provided"]);
}

$conn->close();
?>