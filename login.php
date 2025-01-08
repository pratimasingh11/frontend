<?php
// Enable error reporting to debug issues
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Connect to the database
$host = "localhost";
$db_name = "easymeal";
$db_user = "root";
$db_password = "";

$conn = new mysqli($host, $db_user, $db_password, $db_name);

// Check if the connection is successful
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}

// Retrieve the POST data
$email = trim($_POST['email'] ?? ''); 
$password = $_POST['password'] ?? '';

// Validate inputs
if (empty($email) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Email and password are required"]);
    exit;
}

// Sanitize the email (optional but recommended)
$email = filter_var($email, FILTER_SANITIZE_EMAIL);

// Checking if the email exists in the database
$sql = "SELECT * FROM users WHERE email = ?";
$stmt = $conn->prepare($sql); // Use prepared statements to prevent SQL injection
$stmt->bind_param("s", $email); // Bind the email parameter
$stmt->execute(); // Execute the query

$result = $stmt->get_result(); // Get the result of the query
if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "User not found"]);
    exit;
}

// Verify the password
$user = $result->fetch_assoc(); // Fetch the user data as an associative array
if (!password_verify($password, $user['password_hash'])) { // Compare the entered password with the stored hash
    echo json_encode(["success" => false, "message" => "Invalid password"]);
    exit;
}

// Return a success response
echo json_encode(["success" => true, "message" => "Login successful", "user" => ["id" => $user['user_id'], "email" => $user['email'], "role" => $user['role']]]);

$conn->close();
?>
