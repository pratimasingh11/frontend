
<?php
// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "easymeal";  // Ensure this is the correct database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle requests
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Fetch items from the database
    if (isset($_POST['fetch_items']) && $_POST['fetch_items'] == '1') {
        fetchItems();
    }
    // Add item
    elseif (isset($_POST['add_item']) && $_POST['add_item'] == '1') {
        addItem();
    }
    // Update item
    elseif (isset($_POST['update_item']) && $_POST['update_item'] == '1') {
        updateItem();
    }
    // Delete item
    elseif (isset($_POST['delete_item']) && $_POST['delete_item'] == '1') {
        deleteItem();
    }
}

// Fetch items from the database
function fetchItems() {
    global $conn;

    $branch_id = $_POST['branch_id'] ?? '';  // Ensure branch_id is set from POST request
    if (empty($branch_id)) {
        echo json_encode(['success' => false, 'message' => 'Branch ID is required']);
        return;
    }

    $stmt = $conn->prepare("SELECT item_id, item_name, quantity FROM inventory WHERE branch_id = ?");
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

// Add new item to the database
function addItem() {
    global $conn;

    $item_name = $_POST['item_name'] ?? '';
    $quantity = $_POST['quantity'] ?? '';
    $branch_id = $_POST['branch_id'] ?? '';

    if (empty($item_name) || empty($quantity) || empty($branch_id)) {
        echo json_encode(['success' => false, 'message' => 'Item name, quantity, and branch ID are required']);
        return;
    }

    $stmt = $conn->prepare("INSERT INTO inventory (item_name, quantity, branch_id) VALUES (?, ?, ?)");
    $stmt->bind_param("ssi", $item_name, $quantity, $branch_id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Item added successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to add item']);
    }
    $stmt->close();
}

// Update item in the database
function updateItem() {
    global $conn;

    $item_id = $_POST['item_id'] ?? '';
    $item_name = $_POST['item_name'] ?? '';
    $quantity = $_POST['quantity'] ?? '';
    $branch_id = $_POST['branch_id'] ?? '';

    if (empty($item_id) || empty($item_name) || empty($quantity) || empty($branch_id)) {
        echo json_encode(['success' => false, 'message' => 'Item ID, name, quantity, and branch ID are required']);
        return;
    }

    $stmt = $conn->prepare("UPDATE inventory SET item_name = ?, quantity = ? WHERE item_id = ? AND branch_id = ?");
    $stmt->bind_param("ssii", $item_name, $quantity, $item_id, $branch_id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Item updated successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update item']);
    }
    $stmt->close();

}
?>
