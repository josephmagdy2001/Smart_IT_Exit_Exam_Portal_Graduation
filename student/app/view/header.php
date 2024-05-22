<?php
if (!defined('NotDirectAccess')){
	die('Direct Access is not allowed to this page');
}
?>
  <html>

  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Online Exam System</title>
    <meta name="description" content="Online Exam System">
    <meta name="viewport" content="width=650, shrink-to-fit=yes, initial-scale=0.6">
    <link rel="apple-touch-icon" href="../favicon.ico">
    <link rel="shortcut icon" href="../favicon.ico">
    <link rel="stylesheet" href="../style/css/icheck-bootstrap.min.css">
		<link href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
		<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/dt/dt-1.10.20/b-1.6.1/b-colvis-1.6.1/b-print-1.6.1/r-2.2.3/sl-1.3.1/datatables.min.css"/>
    <link rel="stylesheet" href="style/css/pagination.css">

    <link rel="stylesheet" href="style/css/student.css">
    <script src="style/js/countdown.js"></script>
  </head>
<div class="preloader"></div>
<section>
  <div class='air air1'></div>
  <div class='air air2'></div>
  <div class='air air3'></div>
  <div class='air air4'></div>
  <div class='welcome'>Welcome To Smart IT Exit Exam Portal</div>

</section>
<style>
	*{
  margin: 0;
  padding: 0;
 
 }
 body {  
  overflow-x: hidden;  
 
}

.Welcome {
  display: flex;
  justify-content: center;
  animation: slide 40s infinite;
  font-size: xx-large;
  margin-top: 1rem;
  padding: 10px;
  position: relative; /* Ensure z-index works */
  z-index: 1001; 
  font-weight: bolder; 
  }

@keyframes slide {
  0%, 100% {
    transform: translateX(100%);
    color: red; /* Initial color */
  }
  25% {
    transform: translateX(0%);
    color: black; /* Change color during transition */
  }
  50% {
    transform: translateX(-100%);
    color: greenyellow; /* Change color during transition */
  }
  75% {
    transform: translateX(0%);
    color: black; /* Change color during transition */
  }
}

section {
  position: relative;
  width: 100%;
  height: 15vh;
  background: #3586ff;
  overflow: hidden;
}

section .air {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 100px;
  background: url(https://1.bp.blogspot.com/-xQUc-TovqDk/XdxogmMqIRI/AAAAAAAACvI/AizpnE509UMGBcTiLJ58BC6iViPYGYQfQCLcBGAsYHQ/s1600/wave.png);
  background-size: 1000px;
}

section .air.air1 {
  animation: wave 30s linear infinite;
  z-index: 1000;
  opacity: 1;
  animation-delay: 0s;
  bottom: 0;
}

section .air.air2 {
  animation: wave2 15s linear infinite;
  z-index: 999;
  opacity: 0.5;
  animation-delay: -5s;
  bottom: 10px;
}

section .air.air3 {
  animation: wave 30s linear infinite;
  z-index: 998;
  opacity: 0.2;
  animation-delay: -2s;
  bottom: 15px;
}

section .air.air4 {
  animation: wave2 5s linear infinite;
  z-index: 997;
  opacity: 0.7;
  animation-delay: -5s;
  bottom: 20px;
}

@keyframes wave {
  0% {
    background-position-x: 0px;
  }
  100% {
    background-position-x: 1000px;
  }
}

@keyframes wave2 {
  0% {
    background-position-x: 0px;
  }
  100% {
    background-position-x: -1000px;
  }
}
 
</style>
  