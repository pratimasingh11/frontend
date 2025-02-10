<?php
$host = "localhost";
$username = "root";
$password = "";
$dbname = "easymeals";
$conn = new mysqli($host, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => "Connection failed: " . $conn->connect_error]));
}

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, X-Session-ID");
header('Content-Type: application/json');

// Get the raw POST data
$data = json_decode(file_get_contents("php://input"), true);

// Debugging: Log incoming data
error_log(print_r($data, true));

if (!$data || !isset($data['branch_id'])) {
    echo json_encode(["success" => false, "message" => "Branch ID is missing"]);
    exit();
}

$branch_id = $data['branch_id'];

// Prepare the SQL statement
$sql = "SELECT o.id AS order_id, o.bill_number, o.total_price, o.final_total, o.order_time, o.delivery_date_time, o.items, o.loyalty_points, o.remaining_after_loyalty, o.subscription_credit_used, o.status,
               p.product_name AS item_name, oi.quantity, oi.price_per_unit AS price
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        WHERE o.branch_id = ?
        ORDER BY o.id DESC";  // Order by order_id in descending order // Sorting by order_id in descending order
  // Order by order_time in descending order

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $branch_id);

if ($stmt->execute()) {
    $result = $stmt->get_result();
    $orders = [];

    while ($row = $result->fetch_assoc()) {
        $order_id = $row['order_id'];

        if (!isset($orders[$order_id])) {
            $orders[$order_id] = [
                'order_id' => $order_id,
                'bill_number' => $row['bill_number'],
                'total_price' => $row['total_price'],
                'final_total' => $row['final_total'],
                'order_time' => $row['order_time'],
                'delivery_date_time' => $row['delivery_date_time'],
                'items' => [],
                'loyalty_points' => $row['loyalty_points'],
                'remaining_after_loyalty' => $row['remaining_after_loyalty'],
                'subscription_credit_used' => $row['subscription_credit_used'],
                'status' => $row['status'],
            ];
        }

        $orders[$order_id]['items'][] = [
            'item_name' => $row['item_name'],
            'quantity' => $row['quantity'],
            'price' => $row['price'],
        ];
    }

    // Convert associative array to indexed array
    $orders = array_values($orders);

    // Debugging: Print the fetched orders
    error_log(print_r($orders, true));

    echo json_encode(["success" => true, "orders" => $orders]);
} else {
    echo json_encode(["success" => false, "message" => "Database error: " . $stmt->error]);
}

// Close the statement
$stmt->close();
$conn->close();
?>