<?php
header("Content-Type: application/json");
// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "easymeals";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['error' => 'Database connection failed']));
}

if (isset($_GET['user_id'])) {
    $user_id = intval($_GET['user_id']);

    $stmt = $conn->prepare("SELECT full_name, profile_picture FROM users WHERE user_id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        echo json_encode([
            "fullname" => $row['full_name'],
            "profilePicture" => $row['profile_picture'] ?: "default_profile.png", // Default image if null
        ]);
    } else {
        echo json_encode(["error" => "User not found"]);
    }
} else {
    echo json_encode(["error" => "Missing user_id"]);
}

$conn->close();
?>