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
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}

if (isset($_POST['add_offers']) || isset($_POST['edit_offers'])) {
    // Use 'offer_name' to get the value
    $offer_name = $_POST['offer_name'] ?? '';  // Correct field name
    $branch_id = $_POST['branch_id'] ?? null;
    $image_path = null;

    // Handle image upload
    if (isset($_FILES['image_path']) && $_FILES['image_path']['error'] == 0) {
        $image_name = $_FILES['image_path']['name'];
        $image_tmp_name = $_FILES['image_path']['tmp_name'];
        $upload_dir = 'uploads/';
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }
        $image_path = $upload_dir . uniqid() . '_' . basename($image_name);
        move_uploaded_file($image_tmp_name, $image_path);
    }

    if (isset($_POST['edit_offers'])) {
        $offer_id = $_POST['offers_id'];  // Correct field name
        
        // If no new image is uploaded, retain the existing image path
        if ($image_path === null) {
            $query = "SELECT image_path FROM offers WHERE offer_id = ?";
            $stmt = $conn->prepare($query);
            $stmt->bind_param("i", $offer_id);
            $stmt->execute();
            $result = $stmt->get_result();
            if ($row = $result->fetch_assoc()) {
                $image_path = $row['image_path'];
            }
        }

        // Update the offer
        $query = "UPDATE offers SET offer_name = ?, image_path = ?, branch_id = ? WHERE offer_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ssii", $offer_name, $image_path, $branch_id, $offer_id);
    } elseif (isset($_POST['add_offers'])) {
        // Add a new offer
        $query = "INSERT INTO offers (offer_name, image_path, branch_id) VALUES (?, ?, ?)";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ssi", $offer_name, $image_path, $branch_id);
    }

    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => $stmt->error]);
    }
}

if (isset($_GET['fetch_offers'])) {
    $branch_id = $_GET['branch_id'] ?? null;
    $query = "SELECT offer_id, offer_name, image_path FROM offers WHERE branch_id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $branch_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $offers = [];
    while ($row = $result->fetch_assoc()) {
        $row['image_url'] = 'http://localhost/minoriiproject/' . $row['image_path'];
        $offers[] = $row;
    }
    echo json_encode(["success" => true, "offers" => $offers]);
}

$conn->close();
?>
