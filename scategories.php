<?php
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
    die("Connection failed: " . $conn->connect_error);
}

if (isset($_POST['add_category']) || isset($_POST['edit_category'])) {
    $category_name = $_POST['category_name'] ?? '';
    $branch_id = $_POST['branch_id'] ?? null;

    $image_path = null;

    if (isset($_FILES['image_path'])) {
        $image_name = $_FILES['image_path']['name'];
        $image_tmp_name = $_FILES['image_path']['tmp_name'];
        $upload_dir = 'uploads/';
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }
        $image_path = $upload_dir . uniqid() . '_' . $image_name;
        move_uploaded_file($image_tmp_name, $image_path);
    }

    if (isset($_POST['edit_category'])) {
        $category_id = $_POST['category_id'];

        // Fetch existing image path if no new image is uploaded
        if ($image_path === null) {
            $query = "SELECT image_path FROM categories WHERE category_id = ?";
            $stmt = $conn->prepare($query);
            $stmt->bind_param("i", $category_id);
            $stmt->execute();
            $result = $stmt->get_result();
            $row = $result->fetch_assoc();
            $image_path = $row['image_path'];
        }

        $query = "UPDATE categories SET category_name = ?, image_path = ?, branch_id = ? WHERE category_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ssii", $category_name, $image_path, $branch_id, $category_id);
    } else {
        $query = "INSERT INTO categories (category_name, image_path, branch_id) VALUES (?, ?, ?)";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ssi", $category_name, $image_path, $branch_id);
    }

    $stmt->execute();
    echo json_encode(['success' => true]);
}

if (isset($_GET['fetch_categories'])) {
    $branch_id = $_GET['branch_id'] ?? null;
    $query = "SELECT category_id, category_name, image_path FROM categories WHERE branch_id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $branch_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $categories = [];
    while ($row = $result->fetch_assoc()) {
        // We don't send the image path back when editing, just send the URL for new uploads
        $row['image_url'] = 'http://localhost/minoriiproject/uploads/' . $row['image_path'];

        $categories[] = $row;
    }
    echo json_encode(['success' => true, 'categories' => $categories]);
}

$conn->close();
?>