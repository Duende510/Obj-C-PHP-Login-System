<?php
$dbHost = "localhost";
$dbUsername = ""; 
$dbPassword = "";
$dbname = "";

$conn = new mysqli($dbHost, $dbUsername, $dbPassword, $dbname);

if ($conn->connect_error) 
{
    die("Connection failed: " . $conn->connect_error);
}

$username = $_POST['username'];
$password = $_POST['password'];
$deviceIdentifier = $_POST['device_identifier'];

$stmt = $conn->prepare("SELECT * FROM banned_devices WHERE device_identifier = ?");
$stmt->bind_param("s", $deviceIdentifier);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) 
{
    echo json_encode(array("status" => "error", "message" => "Device is banned"));
} else {
    $stmt = $conn->prepare("INSERT INTO users (username, password, device_identifier) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $username, $password, $deviceIdentifier);

    if ($stmt->execute()) 
    {
        echo json_encode(array("status" => "success", "message" => "Registration successful"));
    } else {
        echo json_encode(array("status" => "error", "message" => "Registration failed"));
    }
}

$stmt->close();
$conn->close();
?>
