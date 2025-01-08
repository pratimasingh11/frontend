<?php
// Enabling error reporting for debugging
ini_set('display_errors', 1); // Show errors directly in the page
error_reporting(E_ALL); // Report all types of errors

// Database connection
$host = "localhost";
$username = "root";
$password = "";
$dbname = "easymeal";

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

// Map college to branch_id
$collegeBranches = [
    'Apex College' => 1,
    'Herald College' => 2,
    'Islington College' => 3,
    'Kavya College' => 4,
    'KIST College' => 5,
    'Kathmandu Engineering College' => 6,
    'Texas College' => 7,
    'Trinity College' => 8,
];

$branch_id = $collegeBranches[$college] ?? null;

if (!$branch_id) {
    echo json_encode(["success" => false, "message" => "Invalid college selected."]);
    exit;
}

// Hash the password
$password_hash = password_hash($password, PASSWORD_DEFAULT);

// Defining the role (in this case, it's 'seller')
$role = 'seller';

// Inserting the data into the database with both branch_id and branch_name
$sql = "INSERT INTO users (email, password_hash, branch_id, branch_name, role) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);

// Binding the parameters (s = string, i = integer)
$stmt->bind_param("ssiss", $email, $password_hash, $branch_id, $college, $role);

// Execute the query and check if it's successful
if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "User signed up successfully!"]);
} else {
    echo json_encode(["success" => false, "message" => "Error: " . $stmt->error]);
}

// Close the statement and the connection
$stmt->close();
$conn->close();

?>
