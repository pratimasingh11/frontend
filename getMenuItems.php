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

// Check if category_id is provided
if (isset($_GET['category_id'])) {
    $categoryId = intval($_GET['category_id']); // Ensure category_id is an integer

    // Prepare the SQL query to fetch products for the given category_id
    $sql = "SELECT product_name, product_price, image_url FROM products WHERE category_id = $categoryId AND is_available = 1";
    $result = $conn->query($sql);

    if ($result && $result->num_rows > 0) {
        $menuItems = [];
        while ($row = $result->fetch_assoc()) {
            $menuItems[] = [
                'product_name' => $row['product_name'],
                'product_price' => $row['product_price'],
                'image_url' => 'http://10.0.2.2/minoriiproject/' . $row['image_url'], // Update URL if needed
            ];
        }

        // Return success response with products
        echo json_encode([
            'success' => true,
            'menu_items' => $menuItems
        ]);
    } else {
        // No products found for this category
        echo json_encode([
            'success' => false,
            'message' => 'No menu items found for the selected category.'
        ]);
    }
} else {
    // Category ID not provided
    echo json_encode([
        'success' => false,
        'message' => 'Category ID is required.'
    ]);
}

// Close the database connection
$conn->close();
?>