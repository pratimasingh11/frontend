<?php
// Database connection
$host = 'localhost';  
$db_name = 'easymeal';
$username = 'root';   
$password = '';

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name;charset=utf8", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode(['success' => false, 'error' => "Connection failed: " . $e->getMessage()]));
}

// Function to fetch all categories
if ($_SERVER['REQUEST_METHOD'] == 'GET' && isset($_GET['fetch_categories'])) {
    try {
        $stmt = $conn->prepare("SELECT category_id, category_name, image_path FROM categories");
        $stmt->execute();
        $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'categories' => $categories]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}

// Add category
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['add_category'])) {
    $category_name = trim($_POST['category_name']);
    $branch_id = $_POST['branch_id'];
    $image_path = $_POST['image_path'];

    if (empty($category_name) || empty($branch_id)) {
        echo json_encode(['success' => false, 'error' => 'Category name and branch ID are required.']);
        exit;
    }

    try {
        $stmt = $conn->prepare("INSERT INTO categories (category_name, branch_id, image_path) VALUES (?, ?, ?)");
        $result = $stmt->execute([$category_name, $branch_id, $image_path]);
        echo json_encode(['success' => $result, 'errorInfo' => $stmt->errorInfo()]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}

// Edit category
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['edit_category'])) {
    $category_id = $_POST['category_id'];
    $category_name = trim($_POST['category_name']);
    $branch_id = $_POST['branch_id'];
    $image_path = $_POST['image_path'];

    if (empty($category_id) || empty($category_name) || empty($branch_id)) {
        echo json_encode(['success' => false, 'error' => 'All fields are required.']);
        exit;
    }

    try {
        $stmt = $conn->prepare("UPDATE categories SET category_name = ?, branch_id = ?, image_path = ? WHERE category_id = ?");
        $result = $stmt->execute([$category_name, $branch_id, $image_path, $category_id]);
        echo json_encode(['success' => $result]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}
?>
