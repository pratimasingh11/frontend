<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');

$host = 'localhost';
$username = 'root';
$password = ''; // Replace with your actual database password
$dbname = 'easymeals';

// Connect to the database
$conn = new mysqli($host, $username, $password, $dbname);

// Check for connection error
if ($conn->connect_error) {
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]);
    exit();
}

// Check if branch_id is provided
if (isset($_GET['branch_id'])) {
    $branchId = intval($_GET['branch_id']); // Ensure branch_id is an integer

    // Prepare the SQL query to fetch category_id, category_name, and image_path
    $sql = "SELECT category_id, category_name, image_path FROM categories WHERE branch_id = $branchId";
    $result = $conn->query($sql);

    if ($result && $result->num_rows > 0) {
        $categories = [];
        while ($row = $result->fetch_assoc()) {
            // Create full URL for the image path
            $imagePath = 'http://10.0.2.2/minoriiproject/' . $row['image_path']; // Update the base URL as necessary

            // Add category_id, category_name, and image path to the result
            $categories[] = [
                'category_id' => intval($row['category_id']), // Include category_id
                'category_name' => $row['category_name'],
                'image_path' => $imagePath
            ];
        }

        // Return success response with categories
        echo json_encode([
            'success' => true,
            'categories' => $categories
        ]);
    } else {
        // No categories found
        echo json_encode([
            'success' => false,
            'message' => 'No categories found for the given branch ID'
        ]);
    }
} else {
    // Branch ID not provided
    echo json_encode([
        'success' => false,
        'message' => 'Branch ID is required'
    ]);
}

// Close the database connection
$conn->close();
?>