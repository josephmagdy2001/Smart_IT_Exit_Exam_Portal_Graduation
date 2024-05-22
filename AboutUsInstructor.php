<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>An About Us Page |</title>
    <style>
      * {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.about-us {
  width: 100%;
  background-image: linear-gradient(90deg, rgba(233, 233, 233, 1), rgba(172, 172, 172, 1));
  display: flex;
  align-items: left;
  justify-content: center;
  margin-bottom: 50px;
 
}

.pic {
  height: 50vh;
  width: 40%;
  max-width: 600px;
  border-radius: 20%; /* Adjust the border radius to your preference */
  border: 5px solid whitesmoke; /* Add border color */
 margin-bottom: 50px;
 margin-top: 50px;
 
}

.about {
  max-width: 1800px;
  display: flex;
  justify-content: space-between;
  gap: 5rem;
}

.text {
  width: 100%;
}

.text h1 {
  font-size: 2.5rem;
   margin-bottom: 20px;
  text-align: center;
}

.text p {
  font-size: 20px;
   font-weight: bold;
text-align: left;
padding-left: 50px;


}
.icon {
            margin-right: 10px;
        }


/* Style btn top */
#scrollToTopBtn {
  display: none;
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 100;
  font-size: 24px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 20%;
  cursor: pointer;
  margin-bottom: 100px;
}

#scrollToTopBtn:hover {
  background-color: #0056b3;
}

/* Media queries */
@media screen and (max-width: 768px) {
  .pic {
    border-radius: 20%;
  }
  
  .about {
    flex-direction: column;
    align-items: center;
  }
  
  .text {
    margin-top: 20px;
  }
}

    </style>
</head>

<body>
    <section class="about-us">
        <div class="about">
            <div class="text">
                <h1>Advantages To Instructors</h1>
                <p><i class="fas fa-book-open  icon"></i> Ease of use and ability to create a groups and courses .</p>
                <p><i class="fas fa-book-open  icon"></i> Easy to add students to groups and can update and delete </p>
                <p><i class="fas fa-book-open  icon"></i> Easy to add manually questions to quiz and determine points of each questions </p>
                <p><i class="fas fa-book-open  icon"></i> Easy to find a five types of questions (multiple select - multiple chose -true&false - essay -matching) . </p>
                <p><i class="fas fa-book-open  icon"></i> Save time to make a quiz very quickly to groups . </p>
                <p><i class="fas fa-book-open  icon"></i> Can determine the difficulty levels of questions as easy & moderate & hard . </p>
                <p><i class="fas fa-book-open  icon"></i> Can determine on show results after test sessions and on test pass percnt .</p>
                <p><i class="fas fa-book-open  icon"></i> Can see Piechart of answers students and how many students enter quiz and who don't enter quiz by select name group to see that </p>
                <p><i class="fas fa-book-open  icon"></i> Easy communication with students.</p>
                <p><i class="fas fa-book-open  icon"></i> Can solve problems with students solve bad or don't pass test by different solutions </p>

            </div>
            <img loading="lazy" src="https://th.bing.com/th/id/OIP.95HG3rDtrjTmwzqCZ79t-gHaE7?w=1100&h=733&rs=1&pid=ImgDetMain" class="pic">
        </div>
    </section>
    
    <script>
        window.onscroll = function() {
            scrollFunction()
        };

        function scrollFunction() {
            if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
                document.getElementById("scrollToTopBtn").style.display = "block";
            } else {
                document.getElementById("scrollToTopBtn").style.display = "none";
            }
        }

        function topFunction() {
            document.body.scrollTop = 0; // For Safari
            document.documentElement.scrollTop = 1; // For Chrome, Firefox, IE and Opera
        }
    </script>
</body>
<footer>
    <button onclick="topFunction()" id="scrollToTopBtn" title="Go to top">&#8593;Top</button>

</footer>

</html>