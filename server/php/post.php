<?php

# DB Connect

$dsn = 'mysql:dbname=snssample;host='.$_ENV['RDS_HOSTNAME'];;
$user = $_ENV['RDS_USERNAME'];
$password = $_ENV['RDS_PASSWORD'];

try {
    $dbh = new PDO($dsn, $user, $password);
} catch (PDOException $e) {
    exit();
}

# Confirmation of posted message

if(!isset($_POST['author']) || !isset($_POST['message'])){
    print "<p>Invalid parameter!</p>";
    print '<a href="index.php">back</a>';
    exit();
}

$author = $_POST['author'];
$message = $_POST['message'];

if(trim($_POST['author'])=="" || trim($_POST['message'])==""){
    print "<p>Message or Author is empty</p>";
    print '<a href="index.php">back</a>';
    exit();
}

if(mb_strlen($author, "UTF-8")>10 || mb_strlen($message, "UTF-8")>100){
    print "<p>Too long parameter</p>";
    print '<a href="index.php">back</a>';
    exit();
}

# post message

$sql = "insert into messages (author, message, created_at) values (?, ?, now())";
$prepare = $dbh->prepare($sql);
$result = $prepare->execute(array($_POST['author'], $_POST['message']));

if(!$result){
    print "<p>DB Error</p>";
    print '<a href="index.php">back</a>';
    exit();
}

# Assemble the screen

print '<p>success!</p>';
print '<a href="index.php">back</a>';
