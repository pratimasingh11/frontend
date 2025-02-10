<?php
header("Content-Type: application/json");

// Database connection
$host = "localhost";
$db_name = "easymeals";
$db_user = "root";
$db_password = "";
$secret_key = "5a66fd7ee8d84fb2b262799ed23c2f78"; // Your Khalti Secret Key

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$conn = new mysqli($host, $db_user, $db_password, $db_name);

// Check if this request is for initiating payment
if (isset($_POST['amount'], $_POST['user_id'], $_POST['email'])) {
    $amount = $_POST['amount'] * 100; // Convert to paisa
    $user_id = $_POST['user_id'];
    $email = $_POST['email'];
    $order_id = "ORDER-" . uniqid();

    $payload = [
        "return_url" => "http://10.0.2.2/minoriiproject/payment_success.php", // Replace with your actual return URL
        "website_url" => "http://10.0.2.2/minoriiproject", // Replace with your actual website URL
        "amount" => $amount,
        "purchase_order_id" => $order_id,
        "purchase_order_name" => "Order from EasyMeals",
        "customer_info" => [
            "name" => "User_$user_id",
            "email" => $email,
            "phone" => "9800000000" // Replace with actual phone number if available
        ]
    ];

    $headers = [
        "Authorization: Key $secret_key",
        "Content-Type: application/json"
    ];

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, "https://a.khalti.com/api/v2/epayment/initiate/");
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($http_code == 200) {
        $api_response = json_decode($response, true);
        if (isset($api_response['payment_url'])) {
            echo json_encode([
                "success" => true,
                "payment_url" => $api_response['payment_url']
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "message" => "Payment initiation failed: payment_url not found",
                "response" => $api_response
            ]);
        }
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Payment initiation failed: HTTP $http_code",
            "response" => $response
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Invalid request: Missing required parameters"
    ]);
}

$conn->close();
?>
