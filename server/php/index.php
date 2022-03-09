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

# Get the last 10 messages

$sql = "select author, message from messages order by created_at desc limit 10";
$prepare = $dbh->prepare($sql);
$prepare->execute();
$result = $prepare->fetchAll();

# Assemble the screen

## Title

print "<h1>Guest Book </h1>";

## Messages

print "<p>";
foreach($result as $value){
  print "[".htmlspecialchars($value["author"])."] ".htmlspecialchars($value["message"])."<br />";
}
print "</p>";

## Post form

print '<form action="post.php" method="POST">';
print '<p><div><label>Your name (max 10 characters)</label><br/><input type="text" name="author" size="10" maxlength="10"></div></p>';
print '<p><div><label>message (max 100 characters)</label><br/><input type="text" name="message" size="100" maxlength="100"></div></p>';
print '<input type="submit" value="send">';
print '</form>';
