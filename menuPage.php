<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');

$host = 'localhost';
$username = 'root';
$password = ''; 
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

// Check if category_id is provided
if (isset($_GET['category_id'])) {
    $categoryId = intval($_GET['category_id']); // Ensure category_id is an integer

    // Prepare the SQL query
    $sql = "SELECT product_id, product_name, product_price, image_url FROM products 
            WHERE category_id = $categoryId AND is_available = 1"; // Filter only available products
    $result = $conn->query($sql);

    if ($result && $result->num_rows > 0) {
        $products = [];
        while ($row = $result->fetch_assoc()) {
            // Create full URL for the image path
            $imagePath = 'http://10.0.2.2/minoriiproject/' . $row['image_url']; // Update the base URL as necessary

            // Add product details to the result
            $products[] = [
                'product_id' =>intval( $row['product_id']),
                'product_name' => $row['product_name'],
                'product_price' => $row['product_price'],
                'image_url' => $imagePath
            ];
        }

        // Return success response
        echo json_encode([
            'success' => true,
            'products' => $products
        ]);
    } else {
        // No products found
        echo json_encode([
            'success' => false,
            'message' => 'No products found for the given category ID'
        ]);
    }
} else {
    // Category ID not provided
    echo json_encode([
        'success' => false,
        'message' => 'Category ID is required'
    ]);
}

// Close the database connection
$conn->close();
?>