<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <meta name="description" content="">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Smart IT Exit Exam Portal </title>
    <link rel="icon" type="image/x-icon" href="photos\graduation-solid-24.png">

    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <link rel="stylesheet" href="style/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="style\css\footerHome.css">

</head>
 
<body>
    <div class="preloader"></div>
    <nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
        <a class="navbar-brand"><img src="photos/Logo.jpg.png" class="logo">Smart IT Exit Exam Portal </a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <ul class="navbar-nav ml-auto">
                <li class="nav-item">
                    <a class="nav-link" href="instructor">Instructor Login <span class="sr-only">(current)</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="student">Student Login</a>
                </li>
                <li class="nav-item">
                <a  class="nav-link" href="Community_Student\loginForm.html">Community Student Groups</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="docs">Docs</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#contact">Contact Us</a>
                </li>

            </ul>

        </div>
    </nav>
    <!-- end   Navbar -->
    <!-- start header -->
    <header id="home" class="block">

        <div class="header-overlay d-flex align-items-center">
            <div class="container">
                <div class="header-title d-flex justify-content-center">
                    <div>
                        <h1 class="text-white"> Welcome To Smart IT Exit Exam Portal </h1>
                        <div class="d-flex justify-content-center">
                            <a class="btn btn-success text-white title-link mt-2" style="margin-right:20px" href="student">I'm Student</a>
                            <a class="btn btn-primary text-white title-link mt-2" href="instructor">I'm Instructor</a> &nbsp; &nbsp; &nbsp;
                            <a class="btn btn-primary text-white title-link mt-2" href="instructor">I'm Admin</a> 

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </header>
    <script src="https://code.jquery.com/jquery-2.2.4.min.js" integrity="sha256-BbhdlvQf/xTY9gja0Dq3HiwQF8LaCRTXxZKRutelT44=" crossorigin="anonymous"></script>
    <script src="https://unpkg.com/@popperjs/core@2"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-backstretch/2.1.18/jquery.backstretch.min.js" integrity="sha256-OZZMwc3o7txR3vFfunl0M9yk3SayGp444eZdL9QDi1Y=" crossorigin="anonymous"></script>


    <!--
    <script type="text/javascript">
	  jQuery(document).ready(function(){
		$.backstretch(" photos/Logo.jpg.png");
	  });
	  </script>-->
    <script src="style/js/home.js"></script>
    <script src="//code.tidio.co/1dg24wnziwuqhzscnzgxp44sifozqbkp.js" async></script> <!--Bot Services -->

    <?php
    require_once 'card.php';
    echo "<br>" . "<br>" . "<hr>";
    require_once 'CustomerSaye.php';
    echo "<br>" . "<br>" . "<hr>";
    require_once 'AboutUsStudent.php';
    echo "<br>" . "<br>" . "<hr>";
    require_once 'AboutUsInstructor.php';
    echo "<br>" . "<br>" . "<hr>";
    require_once 'ContactSupport\ContactForm.php';
    ?>
    <footer class="new_footer_area bg_color">

        <div class="new_footer_top">

            <div class="container">

                <div class="row">
                    <div class="col-lg-3 col-md-6">
                        <div class="f_widget company_widget wow fadeInLeft" data-wow-delay="0.2s" style="visibility: visible; animation-delay: 0.2s; animation-name: fadeInLeft;">
                            <h3 class="f-title f_600 t_color f_size_18">Get in Touch</h3>
                            <p>Don’t miss any updates of our new templates and extensions.!</p>
                            <form action="#" class="f_subscribe_two mailchimp" method="post" novalidate="true" _lpchecked="1">
                                <input type="text" name="EMAIL" class="form-control memail" placeholder="Email">
                                <button class="btn btn_get btn_get_two" type="submit">Subscribe</button>
                                <p class="mchimp-errmessage" style="display: none;"></p>
                                <p class="mchimp-sucmessage" style="display: none;"></p>
                            </form>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6">
                        <div class="f_widget about-widget pl_70 wow fadeInLeft" data-wow-delay="0.4s" style="visibility: visible; animation-delay: 0.4s; animation-name: fadeInLeft;">
                            <h3 class="f-title f_600 t_color f_size_18">Google Map</h3>
                            <iframe loading="lazy" src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d1792639.800147406!2d33.81530419520989!3d28.6522439030018!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x145263a9ca0a5d73%3A0x3c81bff759cd21cb!2sThe%20Egyptian%20E-learning%20University%20(EELU)%20in%20Hurghada!5e0!3m2!1sar!2seg!4v1715612685014!5m2!1sar!2seg" width="250" height="250" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade">
                            </iframe>
                        </div>
                    </div>

                    <div class="col-lg-3 col-md-6">
                        <div class="f_widget about-widget pl_70 wow fadeInLeft" data-wow-delay="0.6s" style="visibility: visible; animation-delay: 0.6s; animation-name: fadeInLeft;">
                            <h3 class="f-title f_600 t_color f_size_18">Help</h3>
                            <ul class="list-unstyled f_list">
                                <li><a href="System Manuel.pdf" download>FAQ</a></li>
                                <li><a href="System Manuel.pdf" download>Term &amp; conditions PDF</a></li>
                                <li><a href="System Manuel.pdf" download>Reporting</a></li>
                                <li><a href="System Manuel.pdf" download>Documentation</a></li>
                                <li><a href="System Manuel.pdf" download>Support Policy</a></li>
                                <li><a href="System Manuel.pdf" download>Privacy</a></li>
                            </ul>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6">
                        <div class="f_widget social-widget pl_70 wow fadeInLeft" data-wow-delay="0.8s" style="visibility: visible; animation-delay: 0.8s; animation-name: fadeInLeft;">
                            <h3 class="f-title f_600 t_color f_size_18">Social Media Team</h3>
                            <div class="f_social_icon">
                                <a href="#" class="fab fa-facebook"></a>
                                <a href="#" class="fab fa-twitter"></a>
                                <a href="#" class="fab fa-linkedin"></a>
                                <a href="#" class="fab fa-pinterest"></a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="VideoShow"> Discover website by video
                <iframe loading="lazy" frameBorder='0' width='540' height='260' webkitallowfullscreen mozallowfullscreen allowfullscreen allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" src="https://www.awesomescreenshot.com/embed?id=27711787&shareKey=5683384ce57a4ee2a9a1cbf6043dd605"></iframe>
            </div>
            <div class="footer_bg">
                <div class="footer_bg_onee"></div>
                <div class="footer_bg_one"></div>
                <div class="footer_bg_two"></div>
            </div>
        </div>
        <div class="footer_bottom">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-lg-6 col-sm-7">
                        <p class="mb-0 f_400">CopyRights &copy;<?php echo $current_time = date(' Y'); ?>
                            All rights reserved for Faculty of Team EELU Hurghada </small></p>
                    </div>
                    <div class="col-lg-6 col-sm-5 text-right">
                        <p>Made by <i class="icon_heart"></i> Developer Click Here <a href="https://www.linkedin.com/in/josephmagdy" target="_blank">Joseph Magdy</a></p>
                    </div>
                </div>
            </div>
        </div>
    </footer>
    <style>
        html,
        body {
            width: 100%;
            margin: 0;
            padding: 0;
        }
    </style>
</body>

</html>