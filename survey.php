<!-- Index.html -->
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, 
				initial-scale=1.0">
	<!-- Linking css file -->
	<link rel="stylesheet" href="style.css">
	<title>Survey Form</title>
</head>

<body>

	<!-- Creating the form container -->
	<div class="container1">

		 

		<h1>Survey Form</h1>

		<!-- Contains error -->
		<h4 id="errorText"></h4>

		<!-- Form element -->
		<form id="surveyForm" action="\online-exam-system-master\student\app\view\save_survey_data.php" method="post">

			<label for="name">
				Name:
			</label><br>
			<input type="text" id="name" name="name" required><br>

			<label for="D_Student">
				ID:
			</label><br>
			<input type="number" id="ID" name="ID_Student" required><br>


			<label>
			Did you face any problem during the Test
			</label><br>
			<input type="radio" id="indoor" name="type" value="Yes" required>

			<label for="Yes">
				Yes
			</label><br>
			<input type="radio" id="outdoor" name="type" value="No" required>

			<label for="No">
				No
			</label><br>
			<input type="radio" id="both" name="type" value="Both" required>

			<label for="both">
				Maybe
			</label><br>

			<label for="favourite-sport">
			Mention the problems you encountered during Test
			</label><br>
			<input type="text" id="favorite-sport" name="favorite-sport" required><br>

			<label for="favorite--sport">
				Are you confident in your abilities to take exams online
			</label><br>
			<input type="text" id="favorite--sport" name="favorite--sport" required><br>

			<label for="favorite-sport-person">
				How satisfied or dissatisfied are you with Us
			</label><br>
			<input type="text" id="favorite-sport-person" name="favorite-sport-person" required><br>


			<label for="feedback">
				What are the future plans or improvements that you have or would like to have for your online exam system project (optional):
			</label><br>
			<input type="textarea" id="feedback" name="feedback"><br>



			<button type="submit">
				Submit
			</button>
		</form>
		
	</div>
	

	<!-- linking javascript file -->
	<script src="script.js"></script>
	<style>
		/* Style.css */

		/* Form container */

		/* Global styles */

 


		* {
			margin: 0;
			padding: 0;
			box-sizing: border-box;
		}

		.container1 {


			max-width: 600px;

			transform: scale(0.8);
			padding: 20px;
			background-color: #fff;
			border-radius: 10px;
			box-shadow: 0 0 10px rgba(0, 0, 255, 0.1);
			background-color: #50404d;
			color: whitesmoke;
			font-size: 22px;

		}

		h1 {
			text-align: center;


		}

		label {
			margin-top: 1rem;
		}

		input {
			padding: 10px;
			box-sizing: border-box;
			margin: 1.2rem 0;
			font-size: larger;
		}

		/* Styling specific input types */
		input[type="text"],
		input[type="number"] {
			width: 100%;
		}

		input[type="textarea"] {
			width: 100%;
			height: 10rem;
		}

		button {
			width: 100%;
			padding: 10px;
			background-color: #4caf50;
			color: white;
			border: none;
			border-radius: 5px;
			cursor: pointer;
			font-size: x-large;
		}

		button:hover {
			background-color: #45a049;
		}

		.error {
			border: 3px solid red;
		}

		.errorText {
			padding: 1rem;
			border: 2px solid red;
			box-shadow: rgba(149, 157, 165, 0.2) 0px 4px 12px;
			font-size: 1.2rem;
			font-family: "Lucida Sans",
				"Lucida Sans Regular",
				sans-serif;
		}

		.successText {
			padding: 1rem;
			border: 4px solid green;
			box-shadow: rgba(149, 157, 165, 0.2) 0px 4px 12px;
			font-size: 1.2rem;
			font-family: "Lucida Sans",
				"Lucida Sans Regular",
				sans-serif;
		}
	</style>

</body>
<script src="//code.tidio.co/1dg24wnziwuqhzscnzgxp44sifozqbkp.js" async></script>

</html>