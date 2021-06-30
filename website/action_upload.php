<?php
//local.php
if(isset($_POST["submit"])){
    // Move file to a temp location
    $uploadDir = 'uploads_local/';
    $uploadFile = $uploadDir . basename($_FILES['file']['name']);
    if (move_uploaded_file($_FILES['file']['tmp_name'], $uploadFile)){
        
        // set array to send data to remote server
        $remoteData = array(
            'fileName' => $uploadFile,
            'fileData' => base64_encode($uploadFile)
        );

        // start curl set up for remote file upload
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, 'http://localhost/server.php');
        curl_setopt($curl, CURLOPT_TIMEOUT, 30);
        curl_setopt($curl, CURLOPT_POST, 1);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($curl, CURLOPT_POSTFIELDS, $remoteData);
        $response = curl_exec($curl);
        curl_close($curl);
        echo $response;   // set response to server.php file 
    } else {
        echo "Your file not uploaded to server.";
    }
} ?> 