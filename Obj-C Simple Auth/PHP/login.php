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

if(isset($_POST['username']) && isset($_POST['password']) && isset($_POST['device_identifier'])) 
{
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
        $stmt = $conn->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
        $stmt->bind_param("ss", $username, $password);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) 
        {
            echo json_encode(array("status" => "success", "message" => "Login successful"));
        } else {
            echo json_encode(array("status" => "error", "message" => "Invalid username or password."));
        }
    }
} else {
    echo json_encode(array("status" => "error", "message" => "Missing parameters."));
}

if ($stmt !== null) {
    $stmt->close();
}

$conn->close();
?>
