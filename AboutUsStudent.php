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
  align-items: center;
  justify-content: center;
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
  color: #007bff;
}

.text p {
   line-height: 40px;
  font-weight: bold;
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
.icon {
            margin-right: 10px;
            color: #007bff;
             font-size: x-large;
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
                <h1>Advantages To Students</h1>
                <p><i class="fas fa-book-open  icon"></i> Ease of use and ability to login and take exams and tests nowadays to keeping up with technology.</p>
                <p><i class="fas fa-book-open  icon"></i> The possibility of communicating with teachers is a problem if it encounters a problem, the first application of its kind that focuses on training students and learners at all educational levels and career advancement to perform comprehensive trainings, tests and exams quickly, easily and at the lowest possible cost. </p>
                <p><i class="fas fa-book-open  icon"></i> The application maintains the privacy of each student and his teachers and the information exchanged between them. </p>
                <p><i class="fas fa-book-open  icon"></i> The app reports and corrects errors for each student so that students can focus on these questions and avoid making these mistakes again. </p>
                <p><i class="fas fa-book-open  icon"></i> A student can easily share their test results and performance reports with their teachers and parents. </p>
                <p><i class="fas fa-book-open  icon"></i> He application saves the student his time, effort and money in obtaining and photographing tests, and school delay in correcting them and informing him of the results of his tests. </p>
                <p><i class="fas fa-book-open  icon"></i> Ability to see all groups and all tests with answers details and all points of questions and percent.</p>
                <p><i class="fas fa-book-open  icon"></i> Saves the student a lot of time and effort. </p>
                <p><i class="fas fa-book-open  icon"></i> Easy communication with the teaching assistant.</p>

            </div>
            <img loading="lazy" src="https://th.bing.com/th/id/OIP.jbb9KQCLOr98CvOyRvW7CgHaEK?rs=1&pid=ImgDetMain" class="pic">
        </div>
    </section>

</body>

</html>