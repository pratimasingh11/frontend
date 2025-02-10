<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

ini_set('display_errors', 1);
error_reporting(E_ALL);

$host = "localhost";
$db_name = "easymeals";
$db_user = "root";
$db_password = "";

$conn = new mysqli($host, $db_user, $db_password, $db_name);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed"]));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user_id = $_POST['user_id'];
    $branch_id = $_POST['branch_id'];
    $order_time = date('Y-m-d H:i:s');
    $bill_number = $_POST['bill_number'];
    $total_price = $_POST['total_price'];
    $total_order = $_POST['total_order'];
    $loyalty_points = $_POST['loyalty_points'];
    $remaining_after_loyalty = $_POST['remaining_after_loyalty'];
    $subscription_credit_used = $_POST['subscription_credit_used'];
    $final_total = $_POST['final_total'];
    $delivery_date_time = $_POST['delivery_date_time'] ?? null;

    // Decode items from JSON string
    $items = isset($_POST['items']) ? json_decode($_POST['items'], true) : [];

    if ($items === null || empty($items)) {
        echo json_encode(["success" => false, "message" => "Invalid or empty items"]);
        exit;
    }

    // Insert order into `orders` table
    $query = "INSERT INTO orders (user_id, branch_id, order_time, bill_number, total_price, total_order, loyalty_points, remaining_after_loyalty, subscription_credit_used, final_total, delivery_date_time, status, items) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?)";

    if ($stmt = $conn->prepare($query)) {
        $items_json = json_encode($items); // Convert items to JSON format

        $stmt->bind_param("iissdiiiddss", $user_id, $branch_id, $order_time, $bill_number, $total_price, $total_order, $loyalty_points, $remaining_after_loyalty, $subscription_credit_used, $final_total, $delivery_date_time, $items_json);

        if ($stmt->execute()) {
            $order_id = $conn->insert_id; // Get the last inserted order ID

            // Insert each item into `order_items` table
            $item_query = "INSERT INTO order_items (order_id, product_id, quantity, price_per_unit, total_price) VALUES (?, ?, ?, ?, ?)";
            
            if ($item_stmt = $conn->prepare($item_query)) {
                foreach ($items as $item) {
                    if (!isset($item['product_id'], $item['quantity'], $item['price'])) {
                        echo json_encode(["success" => false, "message" => "Invalid item data"]);
                        continue;
                    }
                
                    $product_id = intval($item['product_id']);
                    $quantity = intval($item['quantity']);
                    $price_per_unit = floatval($item['price']);
                    $total_price = $quantity * $price_per_unit;
                
                    $item_stmt->bind_param("iiidd", $order_id, $product_id, $quantity, $price_per_unit, $total_price);
                
                    if (!$item_stmt->execute()) {
                        error_log("Failed to insert order item: " . $item_stmt->error);
                        echo json_encode(["success" => false, "message" => "Order item insert failed"]);
                        exit;
                    }
                }
                $item_stmt->close();
            } else {
                echo json_encode(["success" => false, "message" => "Failed to prepare item statement"]);
                exit;
            }

            echo json_encode(["success" => true, "message" => "Order placed successfully", "order_id" => $order_id]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to place order"]);
        }
        $stmt->close();
    } else {
        echo json_encode(["success" => false, "message" => "Database query failed"]);
    }
}

$conn->close();
?>