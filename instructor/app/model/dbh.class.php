<?php
class dbh {
  public $host = "localhost";
  public $username = "root";
  public $pwd = "";
  public $dbName = "o6u_onlineq";

  public function connect(){
    $conn = 'mysql:host=' . $this->host . ';dbname=' . $this->dbName;
    $pdo = new PDO($conn,$this->username,$this->pwd);
 

    return $pdo;
  }
}
