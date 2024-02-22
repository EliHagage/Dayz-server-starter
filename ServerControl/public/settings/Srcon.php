<?php

require_once 'RCon.php';

use Rcon\Rcon;

// Function to log data to a file
function logData($data) {
    $logFile = 'log.txt';
    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "$timestamp: $data" . PHP_EOL;
    file_put_contents($logFile, $logEntry, FILE_APPEND);
}

// Retrieve data from POST request
$data = file_get_contents('php://input');
$jsonData = json_decode($data, true);

// Log the received JSON data
logData('Received JSON data: ' . print_r($jsonData, true));

// Extract RCON details and command
$host = $jsonData['host'] ?? '';
$port = $jsonData['port'] ?? '';
$pass = $jsonData['pass'] ?? '';
$command = $jsonData['command'] ?? '';

// Log the extracted data
logData("Host: $host, Port: $port, Password: $pass, Command: $command");

// Connect to the RCON server and execute the command
$rcon = new Rcon();

$serverData = [
    'host' => $host,
    'port' => $port,
    'pass' => $pass
];

$rcon->connect($serverData);

$response = '';

if (!empty($command)) {
    $response = $rcon->sendCommand($command);
}

// Log the response from the server
logData("Response from server: $response");

?>
