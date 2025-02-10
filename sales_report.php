<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *"); // Allow all origins
header("Access-Control-Allow-Methods: GET");

// Database Connection
$host = "localhost"; // Change this if needed
$username = "root"; // Your database username
$password = ""; // Your database password
$database = "easymeals"; // Your database name

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Get branch_id and filter type from URL
$branch_id = isset($_GET['branch_id']) ? intval($_GET['branch_id']) : 0;
$filter = isset($_GET['filter']) ? $_GET['filter'] : 'Daily';

// Debugging: Log the received parameters
error_log("Received branch_id: $branch_id, filter: $filter");

// Define SQL Query for Orders
if ($filter === "Daily") {
    $order_query = "SELECT DATE(order_time) AS label, SUM(total_order) AS totalOrders
                    FROM orders WHERE branch_id = $branch_id
                    GROUP BY DATE(order_time)";
    $product_query = "SELECT DATE(o.order_time) AS label, p.product_name, SUM(oi.quantity) AS totalQuantity
                      FROM order_items oi
                      JOIN orders o ON oi.order_id = o.id
                      JOIN products p ON oi.product_id = p.product_id
                      WHERE o.branch_id = $branch_id
                      GROUP BY DATE(o.order_time), p.product_name
                      ORDER BY totalQuantity DESC";
} elseif ($filter === "Weekly") {
    $order_query = "SELECT YEARWEEK(order_time) AS label, SUM(total_order) AS totalOrders
                    FROM orders WHERE branch_id = $branch_id
                    GROUP BY YEARWEEK(order_time)";
    $product_query = "SELECT YEARWEEK(o.order_time) AS label, p.product_name, SUM(oi.quantity) AS totalQuantity
                      FROM order_items oi
                      JOIN orders o ON oi.order_id = o.id
                      JOIN products p ON oi.product_id = p.product_id
                      WHERE o.branch_id = $branch_id
                      GROUP BY YEARWEEK(o.order_time), p.product_name
                      ORDER BY totalQuantity DESC";
} else { // Monthly
    $order_query = "SELECT DATE_FORMAT(order_time, '%Y-%m') AS label, SUM(total_order) AS totalOrders
                    FROM orders WHERE branch_id = $branch_id
                    GROUP BY DATE_FORMAT(order_time, '%Y-%m')";
    $product_query = "SELECT DATE_FORMAT(o.order_time, '%Y-%m') AS label, p.product_name, SUM(oi.quantity) AS totalQuantity
                      FROM order_items oi
                      JOIN orders o ON oi.order_id = o.id
                      JOIN products p ON oi.product_id = p.product_id
                      WHERE o.branch_id = $branch_id
                      GROUP BY DATE_FORMAT(o.order_time, '%Y-%m'), p.product_name
                      ORDER BY totalQuantity DESC";
}

// Fetch Orders Data
$order_result = $conn->query($order_query);
if (!$order_result) {
    die(json_encode(["error" => "Order Query failed: " . $conn->error]));
}

$order_data = [];
if ($order_result->num_rows > 0) {
    while ($row = $order_result->fetch_assoc()) {
        $order_data[] = ["label" => $row["label"], "totalOrders" => (int)$row["totalOrders"]];
    }
}

// Fetch Product Sales Data
$product_result = $conn->query($product_query);
if (!$product_result) {
    die(json_encode(["error" => "Product Query failed: " . $conn->error]));
}

$product_data = [];
if ($product_result->num_rows > 0) {
    while ($row = $product_result->fetch_assoc()) {
        $product_data[] = [
            "label" => $row["label"],
            "product_name" => $row["product_name"],
            "totalQuantity" => (int)$row["totalQuantity"]
        ];
    }
}

// Combine both datasets into a single response
$response = [
    "orders" => $order_data,
    "products" => $product_data
];

echo json_encode($response);
$conn->close();
?>