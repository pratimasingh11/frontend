<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json'); // Ensure response type is JSON

// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "easymeals";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_POST['fetch_items']) && $_POST['fetch_items'] == '1') {
        fetchItems();
    } elseif (isset($_POST['add_item']) && $_POST['add_item'] == '1') {
        addItem();
    } elseif (isset($_POST['update_item']) && $_POST['update_item'] == '1') {
        updateItem();
    }
}

function fetchItems() {
    global $conn;

    $branch_id = $_POST['branch_id'] ?? '';
    if (empty($branch_id)) {
        echo json_encode(['success' => false, 'message' => 'Branch ID is required']);
        return;
    }

    $stmt = $conn->prepare("SELECT item_id, item_name, quantity, max_quantity FROM inventory WHERE branch_id = ?");
    $stmt->bind_param("i", $branch_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $items = [];
        while ($row = $result->fetch_assoc()) {
            $items[] = $row;
        }
        echo json_encode(['success' => true, 'items' => $items]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No items found']);
    }
    $stmt->close();
}

function addItem() {
    global $conn;

    $item_name = $_POST['item_name'] ?? '';
    $quantity = (int) ($_POST['quantity'] ?? 0);
    $max_quantity = (int) ($_POST['max_quantity'] ?? 0);
    $branch_id = $_POST['branch_id'] ?? '';

    if (empty($item_name) || $quantity <= 0 || $max_quantity <= 0 || empty($branch_id)) {
        echo json_encode(['success' => false, 'message' => 'Invalid input']);
        return;
    }

    $stmt = $conn->prepare("INSERT INTO inventory (item_name, quantity, max_quantity, branch_id) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("siii", $item_name, $quantity, $max_quantity, $branch_id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Item added successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to add item']);
    }
    $stmt->close();
}

function updateItem() {
    global $conn;

    $item_id = $_POST['item_id'] ?? '';
    $item_name = $_POST['item_name'] ?? '';
    $quantity = (int) ($_POST['quantity'] ?? 0);
    $max_quantity = (int) ($_POST['max_quantity'] ?? 0);
    $branch_id = $_POST['branch_id'] ?? '';

    if (empty($item_id) || empty($item_name) || $quantity <= 0 || $max_quantity <= 0 || empty($branch_id)) {
        echo json_encode(['success' => false, 'message' => 'Invalid input']);
        return;
    }

    $stmt = $conn->prepare("UPDATE inventory SET item_name = ?, quantity = ?, max_quantity = ? WHERE item_id = ? AND branch_id = ?");
    $stmt->bind_param("siiii", $item_name, $quantity, $max_quantity, $item_id, $branch_id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Item updated successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update item']);
    }
    $stmt->close();
}
?>
