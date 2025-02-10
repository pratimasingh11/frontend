<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Database connection
$host = "localhost";
$username = "root";
$password = "";
$dbname = "easymeals";

$conn = new mysqli($host, $username, $password, $dbname);
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Database connection error"]);
    exit;
}

$response = array();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (isset($_GET['user_id'])) {
        $user_id = intval($_GET['user_id']);

        $query = "SELECT full_name, profile_picture FROM users WHERE user_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $user = $result->fetch_assoc();
            $response['success'] = true;
            $response['full_name'] = $user['full_name'];
            $response['profile_picture'] = !empty($user['profile_picture']) 
                ? "http://10.0.2.2/minoriiproject/uploads/" . $user['profile_picture'] 
                : null;
        } else {
            $response['success'] = false;
            $response['message'] = "User not found";
        }
    } else {
        $response['success'] = false;
        $response['message'] = "Missing user_id";
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['user_id']) && isset($_FILES['profile_picture'])) {
        $user_id = intval($_POST['user_id']);
        $upload_dir = $_SERVER['DOCUMENT_ROOT'] . "/minoriiproject/uploads/";

        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }

        $file_name = "profile_" . $user_id . "_" . time() . ".jpg";
        $file_path = $upload_dir . $file_name;

        if (move_uploaded_file($_FILES['profile_picture']['tmp_name'], $file_path)) {
            $update_query = "UPDATE users SET profile_picture = ? WHERE user_id = ?";
            $stmt = $conn->prepare($update_query);
            $stmt->bind_param("si", $file_name, $user_id);
            if ($stmt->execute()) {
                $response['success'] = true;
                $response['message'] = "Profile picture uploaded successfully!";
                $response['profile_picture'] = "http://10.0.2.2/minoriiproject/uploads/" . $file_name;
            } else {
                $response['success'] = false;
                $response['message'] = "Failed to update database";
            }
        } else {
            $response['success'] = false;
            $response['message'] = "Failed to upload image";
        }
    } else {
        $response['success'] = false;
        $response['message'] = "Missing parameters";
    }
} else {
    $response['success'] = false;
    $response['message'] = "Invalid request method";
}

echo json_encode($response);
?>
