<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Content-Type: application/json");

$host = "localhost";
$username = "root";
$password = "";
$dbname = "easymeals";
$conn = new mysqli($host, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => "Connection failed: " . $conn->connect_error]));
}

// Fetch Categories
if (isset($_GET['action']) && $_GET['action'] === 'fetch_categories') {
    $branch_id = $_GET['branch_id'] ?? null;

    if ($branch_id) {
        $stmt = $conn->prepare("SELECT category_id, category_name FROM categories WHERE branch_id = ?");
        $stmt->bind_param("i", $branch_id);
        $stmt->execute();
        $result = $stmt->get_result();

        $categories = $result->fetch_all(MYSQLI_ASSOC);
        echo json_encode(['success' => true, 'categories' => $categories]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid or missing branch ID']);
    }
    exit;
}

// Add or Edit Product
if (isset($_GET['action']) && in_array($_GET['action'], ['add_product', 'edit_product'])) {
    $product_name = $_POST['product_name'] ?? '';
    $product_price = $_POST['product_price'] ?? 0.0;
    $category_id = $_POST['category_id'] ?? null;
    $branch_id = $_POST['branch_id'] ?? null;
    $is_available = $_POST['is_available'] ?? 1;

    if (empty($product_name) || !is_numeric($product_price) || $product_price <= 0) {
        echo json_encode(['success' => false, 'message' => 'Invalid product details']);
        exit;
    }

    $image_path = null;

    if (isset($_FILES['image_path'])) {
        $image_name = $_FILES['image_path']['name'];
        $image_tmp_name = $_FILES['image_path']['tmp_name'];
        $upload_dir = 'uploads/';
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }
        $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];
        $extension = strtolower(pathinfo($image_name, PATHINFO_EXTENSION));
        if (!in_array($extension, $allowed_extensions)) {
            echo json_encode(['success' => false, 'message' => 'Invalid file type']);
            exit;
        }
        $image_path = $upload_dir . uniqid() . '.' . $extension;
        move_uploaded_file($image_tmp_name, $image_path);
    }

    if ($_GET['action'] === 'edit_product') {
        $product_id = $_POST['product_id'] ?? null;
        if (!$product_id) {
            echo json_encode(['success' => false, 'message' => 'Product ID is required for editing']);
            exit;
        }

        if ($image_path === null) {
            $fetchStmt = $conn->prepare("SELECT image_url FROM products WHERE product_id = ?");
            $fetchStmt->bind_param("i", $product_id);
            $fetchStmt->execute();
            $result = $fetchStmt->get_result();
            $image_path = $result->fetch_assoc()['image_url'] ?? null;
            $fetchStmt->close();
        }

        $stmt = $conn->prepare("UPDATE products SET product_name = ?, product_price = ?, category_id = ?, branch_id = ?, is_available = ?, image_url = ? WHERE product_id = ?");
        $stmt->bind_param("sdiiisi", $product_name, $product_price, $category_id, $branch_id, $is_available, $image_path, $product_id);
    } else {
        $stmt = $conn->prepare("INSERT INTO products (product_name, product_price, category_id, branch_id, is_available, image_url) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sdiiis", $product_name, $product_price, $category_id, $branch_id, $is_available, $image_path);
    }

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => ucfirst($_GET['action']) . ' successful']);
    } else {
        echo json_encode(['success' => false, 'message' => $stmt->error]);
    }
    exit;
}

// Fetch Products
if (isset($_GET['action']) && $_GET['action'] === 'fetch_products') {
    $branch_id = $_GET['branch_id'] ?? null;

    if ($branch_id) {
        $stmt = $conn->prepare("SELECT product_id, product_name, product_price, category_id, is_available, image_url FROM products WHERE branch_id = ?");
        $stmt->bind_param("i", $branch_id);
        $stmt->execute();
        $products = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        echo json_encode(['success' => true, 'products' => $products]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid or missing branch ID']);
    }
    exit;
}

$conn->close();
?>
