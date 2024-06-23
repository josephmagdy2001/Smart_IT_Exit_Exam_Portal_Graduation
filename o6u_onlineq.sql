-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 23, 2024 at 02:51 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `o6u_onlineq`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `generateInstructorInvites` (IN `count` INT)   BEGIN
  DECLARE i INT DEFAULT 0;
  WHILE i < count DO
    INSERT INTO instructor_invitations(`code`) VALUES (
      CRC32(CONCAT(NOW(), RAND()))
    );
    SET i = i + 1;
  END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getStudentTests` (IN `studID` INT)   BEGIN
			SET @ct :=  convert_tz(now(),@@session.time_zone,'+02:00');
			SELECT t.id,t.name,g.name groupName,i.name instructor,ts.endTime,ts.id settingID,
			CASE WHEN (@ct BETWEEN ts.startTime AND ts.endTime) THEN 'Available'
			WHEN @ct < ts.startTime THEN 'Not Started Yet'
			when @ct > ts.endTime THEN 'Finished'
			ELSE 'Not Available'
			END AS status
			from groups g
      inner join groups_has_students gs
      on gs.studentID = studID and g.id = gs.groupID
      inner join test t
      on t.id = g.assignedTest
      inner join test_settings ts
      on ts.id = g.settingID
      inner join instructor i
      on i.id = t.instructorID
			WHERE t.id NOT IN (SELECT testID from result where studentID = gs.studentID);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getTestByCode` (IN `code` VARCHAR(100))   BEGIN
	SELECT t.id,t.name,c.name category,i.name instructor,ts.endTime,ti.settingID,ts.passPercent,ts.duration,ts.random,ts.startTime,ts.sendToStudent,getQuestionsInTest(t.id) questions from test_invitations ti
      inner join test t 
      on t.id = ti.testID
      LEFT join test_settings ts
      on ts.id = ti.settingID
      inner join category c
      on c.id = t.categoryID
      inner join instructor i
      on i.id = t.instructorID
			where ti.id = AES_DECRYPT(UNHEX(code), 'O6U');

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getTestById` (IN `studID` INT, IN `tID` INT)   BEGIN
      SELECT t.id,t.name,c.name category,i.name instructor,getQuestionsInTest(t.id) questions,ts.startTime,ts.duration,ts.passPercent,ts.endTime,ts.id settingID,ts.random from groups g
      inner join groups_has_students gs
      on gs.studentID = studID and g.id = gs.groupID
      inner join test t
      on t.id = g.assignedTest
      inner join test_settings ts
      on ts.id = g.settingID
      inner join category c
      on c.id = t.categoryID
      inner join instructor i
      on i.id = t.instructorID
      where (convert_tz(now(),@@session.time_zone,'+02:00') BETWEEN ts.startTime AND ts.endTime)
      AND t.id NOT IN (SELECT testID from result where studentID = gs.studentID) AND t.id = tID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertRandomRules` (IN `studID` INT, IN `tID` INT, IN `cid` INT, IN `diff` INT, IN `lim` INT)   INSERT INTO tempquestions(resultID, questionID,rand)
SELECT (SELECT MAX(id) FROM result WHERE studentID = studID) AS resultID, id,(select floor(0+ RAND() * 10000)) FROM question q
WHERE NOT EXISTS (SELECT 1 FROM tests_has_questions WHERE testID = tID AND questionID = q.id)
AND !deleted 
AND courseID = cid 
AND difficulty = diff LIMIT lim$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Result_getQuestionsAnswers` (IN `rid` INT)   select 
 DISTINCT q.id,q.question,q.`type`,
getResultGivenAnswers(ra.resultID,ra.questionID) AS GivenAnswers,
getQuestionRightAnswers(q.id) AS CorrectAnswers,
checkAnswer(ra.id,q.id) AS RightQuestion,
q.points * isCorrect AS points

from result_answers ra 
LEFT JOIN question q
on q.id = ra.questionID
where resultID = rid$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `checkAnswer` (`resID` INT, `qID` INT) RETURNS TINYINT(1)  BEGIN
    DECLARE RES INT;
    IF ((SELECT type FROM question WHERE id = qID) = 0 OR (SELECT type FROM question WHERE id = qID) = 3) THEN
        SELECT COUNT(*) INTO RES FROM (
            SELECT answerID FROM result_answers ra WHERE resultID = resID AND questionID = qID
            AND answerID IN (SELECT id FROM question_answers WHERE isCorrect = 1 AND questionID = ra.questionID)
        ) AS t
        HAVING COUNT(*) = (SELECT COUNT(*) FROM question_answers WHERE questionID = qID AND isCorrect = 1);
        IF RES > 0 THEN
            RETURN TRUE;    
        ELSE
            RETURN FALSE;                           
        END IF;
    ELSEIF ((SELECT type FROM question WHERE id = qID) = 2) THEN
        SELECT COUNT(*) INTO RES FROM result_answers RA WHERE resultID = resID AND questionID = qID
        AND textAnswer IN (SELECT answer FROM question_answers WHERE questionID = RA.questionID);      
        IF RES > 0 THEN
            RETURN TRUE;    
        ELSE
            RETURN FALSE;                           
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `generateGroupInvites` (`groupID` INT, `count` INT, `pf` VARCHAR(50)) RETURNS INT(11)  BEGIN
  DECLARE i INT DEFAULT 0;
  WHILE i < count DO
    INSERT INTO group_invitations(groupID,`code`) VALUES (
      groupID,CONCAT(COALESCE(pf,''),CRC32(CONCAT(NOW(), RAND())))
    );
    SET i = i + 1;
  END WHILE;
	RETURN 0;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getQuestionRightAnswers` (`qid` INT) RETURNS VARCHAR(255) CHARSET utf8 COLLATE utf8_general_ci  BEGIN
DECLARE C VARCHAR(255);
DECLARE qtype INT;
SET qtype = (select type from question where id = qid);
IF (qtype = 1) THEN
SELECT 'True' INTO C FROM question WHERE id = qID AND isTrue = 1;
	IF C IS NULL THEN
	SET C = 'False';
	END IF;
ELSEIF (qtype = 2) THEN
SELECT GROUP_CONCAT(answer SEPARATOR ', ') into C FROM question_answers
WHERE questionID = qid
GROUP BY questionID;

ELSEIF (qtype = 4) THEN
SELECT GROUP_CONCAT(CONCAT(answer, ' => ', matchAnswer) ORDER BY id SEPARATOR ', ') into C FROM question_answers
WHERE questionID = qid
GROUP BY questionID;
ELSE
SELECT GROUP_CONCAT(answer SEPARATOR ', ') into C FROM question_answers
WHERE questionID = qid AND isCorrect
GROUP BY questionID;
END IF;
RETURN C;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getQuestionsInTest` (`tID` INT) RETURNS INT(11)  BEGIN
DECLARE C INT(11);
SELECT ((SELECT count(*) FROM tests_has_questions WHERE testID = tID) + COALESCE((SELECT SUM(questionsCount) FROM test_random_questions WHERE testID = tID),0)) INTO C;
   IF (C IS NULL) THEN
      SET C = 0;
   END IF;


RETURN C;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getResultGivenAnswers` (`rid` INT, `qid` INT) RETURNS VARCHAR(255) CHARSET utf8 COLLATE utf8_general_ci  BEGIN
DECLARE C VARCHAR(255);
DECLARE qtype INT;
SET qtype = (select type from question where id = qID);
IF (qtype = 1) THEN
	SELECT "True" INTO C FROM result_answers WHERE questionID = qid AND resultID = rid AND isTrue = 1;

	SELECT "False" INTO C FROM result_answers WHERE questionID = qid AND resultID = rid AND isTrue = 0;
ELSEIF (qtype = 4) THEN 
SELECT GROUP_CONCAT(CONCAT(answer, ' => ', textAnswer) ORDER BY a.id SEPARATOR ', ') INTO C FROM result_answers ra
INNER JOIN question_answers a
ON a.id = ra.answerID
WHERE ra.questionID = qid AND ra.resultID = rid;
ELSEIF (qtype = 2 || qtype = 5) THEN 
SELECT textAnswer INTO C FROM result_answers WHERE questionID = qid AND resultID = rid;
ELSE
SELECT GROUP_CONCAT(answer SEPARATOR ', ') INTO C FROM result_answers ra
INNER JOIN question_answers a
ON a.id = ra.answerID
WHERE ra.questionID = qid AND ra.resultID = rid;
END IF;
RETURN C;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getResultGrade` (`rid` INT) RETURNS INT(11)  BEGIN
DECLARE C INT(11);
SELECT SUM(points) INTO C
FROM (
SELECT CASE (SELECT type from question where id = questionID) WHEN 4 THEN
(SELECT SUM(points) FROM question_answers qa WHERE qa.questionID = ra.questionID) 
ELSE 
(SELECT SUM(points) FROM question q WHERE q.id = ra.questionID) 
END AS points from result_answers ra where resultID = rid and isCorrect GROUP BY questionID) as t;


   IF (C IS NULL) THEN
      SET C = 0;
   END IF;


RETURN C;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getResultMaxGrade` (`rid` INT) RETURNS INT(11)  BEGIN
DECLARE C INT(11);
SELECT SUM(points) INTO C
FROM (SELECT CASE (SELECT type FROM question WHERE id = ra.questionID) 
WHEN 4 THEN
(SELECT SUM(points) FROM question_answers WHERE questionID = ra.questionID) 
ELSE 
(SELECT SUM(points) FROM question q WHERE q.id = ra.questionID) 
END points
FROM result_answers ra
WHERE resultID = rid
GROUP BY questionID) AS T;
   IF (C IS NULL) THEN
      SET C = 0;
   END IF;


RETURN C;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getTestGrade` (`tid` INT) RETURNS INT(11)  BEGIN
DECLARE C INT(11);
SELECT SUM(points) INTO C
FROM (
SELECT 
		CASE (SELECT type FROM question WHERE id = thq.questionID) 
		WHEN 4 THEN
		(SELECT SUM(points) FROM question_answers WHERE questionID = thq.questionID) 
		ELSE 
		(SELECT SUM(points) FROM question q WHERE q.id = thq.questionID) 
		END points
FROM tests_has_questions thq
WHERE testID = tid
GROUP BY questionID) AS T;
   IF (C IS NULL) THEN
      SET C = 0;
   END IF;


RETURN C;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Result_CorrectQuestions` (`rid` INT) RETURNS INT(11)  BEGIN
DECLARE C INT(11);
select count(*) INTO C from (select questionID from result_answers where resultID = rid  GROUP BY questionID 
HAVING CASE (SELECT type from question where id = questionID) WHEN 4 THEN 
MAX(isCorrect) = 1 ELSE MIN(isCorrect) = 1 END) t;
IF (C IS NULL) THEN
      SET C = 0;
   END IF;

RETURN C;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Result_WrongQuestions` (`rid` INT) RETURNS INT(11)  BEGIN
DECLARE C INT(11);
select count(*) INTO C from (
select questionID from result_answers where resultID = rid  GROUP BY questionID 
HAVING CASE (SELECT type from question where id = questionID) WHEN 4 THEN 
MAX(isCorrect) = 0 ELSE MIN(isCorrect) = 0 END) t;
IF (C IS NULL) THEN
      SET C = 0;
   END IF;
RETURN C;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `contactsupport`
--

CREATE TABLE `contactsupport` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `contactsupport`
--

INSERT INTO `contactsupport` (`id`, `name`, `email`, `subject`, `message`, `created_at`) VALUES
(36, 'Joseph Magdy Habib', 'josephmagdy56@gmail.com', 'problem in login as Student ', 'the details of problem ......', '2024-05-17 20:24:10');

-- --------------------------------------------------------

--
-- Table structure for table `course`
--

CREATE TABLE `course` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `parent` int(11) DEFAULT NULL,
  `instructorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `course`
--

INSERT INTO `course` (`id`, `name`, `parent`, `instructorID`) VALUES
(86, 'Web3', NULL, 35),
(87, 'MySql', 86, 35),
(88, 'Math', NULL, 35),
(89, 'hhhh', 88, 35),
(90, 'English', NULL, 35),
(91, 'grammer', 90, 35);

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE `groups` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `assignedTest` int(11) DEFAULT NULL,
  `settingID` int(11) DEFAULT NULL,
  `instructorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`id`, `name`, `assignedTest`, `settingID`, `instructorID`) VALUES
(23, 'A', NULL, NULL, 35),
(24, 'b', NULL, NULL, 35),
(25, 'Math', NULL, NULL, 35),
(26, 'cd', NULL, NULL, 35),
(27, 'ED', NULL, NULL, 35),
(28, 'Joseph group', 58, 109, 35);

-- --------------------------------------------------------

--
-- Table structure for table `groups_has_students`
--

CREATE TABLE `groups_has_students` (
  `groupID` int(11) NOT NULL,
  `studentID` int(11) NOT NULL,
  `joinDate` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `groups_has_students`
--

INSERT INTO `groups_has_students` (`groupID`, `studentID`, `joinDate`) VALUES
(23, 2001506, '2024-05-06 00:37:13'),
(23, 2001666, '2024-03-20 23:31:29'),
(23, 2020147, '2024-05-06 18:13:15'),
(24, 2001666, '2024-05-06 21:37:19'),
(24, 2020147, '2024-05-06 21:26:46'),
(26, 2001666, '2024-05-09 21:18:10'),
(27, 2001506, '2024-05-10 19:26:13'),
(27, 2001666, '2024-05-10 19:02:30'),
(28, 2001666, '2024-05-23 19:08:23');

-- --------------------------------------------------------

--
-- Table structure for table `group_invitations`
--

CREATE TABLE `group_invitations` (
  `groupID` int(11) DEFAULT NULL,
  `code` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `instructor`
--

CREATE TABLE `instructor` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password` varchar(100) NOT NULL,
  `phone` varchar(13) NOT NULL,
  `password_token` varchar(100) DEFAULT NULL,
  `token_expire` timestamp NULL DEFAULT NULL,
  `suspended` int(11) NOT NULL DEFAULT 0,
  `isAdmin` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `instructor`
--

INSERT INTO `instructor` (`id`, `name`, `email`, `password`, `phone`, `password_token`, `token_expire`, `suspended`, `isAdmin`) VALUES
(7, '   System Administrator', 'admin@gmail.com', '21232f297a57a5a743894a0e4a801fc3', '', '2215bce121b39e1e2f744d0f78742b9ce9c406995ba5b69710', '2024-05-05 20:56:06', 0, 1),
(35, 'Joseph Magdy Habib', 'joseph12@gmail.com', '471933be6f562bcf71fa0feffa7e4439', '01016122682', '40fd1ee5f30fe05895b2fe6d11e550e474512b17c3d8d2c2d9', '2024-05-11 16:35:14', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `instructor_invitations`
--

CREATE TABLE `instructor_invitations` (
  `code` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `instructor_invitations`
--

INSERT INTO `instructor_invitations` (`code`) VALUES
('3616735092'),
('1118510134'),
('3917257179'),
('171449720');

-- --------------------------------------------------------

--
-- Table structure for table `login_attempts`
--

CREATE TABLE `login_attempts` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `attempt_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `login_attempts`
--

INSERT INTO `login_attempts` (`id`, `email`, `attempt_time`) VALUES
(36, 'joseph12@gmail.com', '2024-05-27 01:55:13'),
(39, 'joseph12@gmail.com', '2024-05-27 02:11:34');

-- --------------------------------------------------------

--
-- Table structure for table `mails`
--

CREATE TABLE `mails` (
  `id` int(11) NOT NULL,
  `resultID` int(11) DEFAULT NULL,
  `studentID` int(11) DEFAULT NULL,
  `instructorID` int(11) DEFAULT NULL,
  `sends_at` timestamp NULL DEFAULT NULL,
  `sent` tinyint(1) DEFAULT 0,
  `type` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `mails`
--

INSERT INTO `mails` (`id`, `resultID`, `studentID`, `instructorID`, `sends_at`, `sent`, `type`) VALUES
(5, NULL, NULL, 7, '2023-12-31 16:10:35', 0, 1),
(6, NULL, NULL, 7, '2023-12-31 16:13:16', 0, 1),
(7, NULL, NULL, 7, '2023-12-31 16:22:10', 0, 1),
(19, NULL, NULL, 7, '2024-02-09 01:20:27', 0, 1),
(40, 49, NULL, NULL, '2024-05-02 19:14:44', 0, 2),
(41, 49, NULL, NULL, '2024-05-02 19:14:44', 0, 3),
(42, NULL, 2001666, NULL, '2024-05-03 19:51:11', 0, 0),
(43, NULL, 2001666, NULL, '2024-05-03 19:56:50', 0, 0),
(44, NULL, NULL, 7, '2024-05-05 19:26:06', 0, 1),
(45, 50, NULL, NULL, '2024-05-05 21:45:12', 0, 2),
(46, 50, NULL, NULL, '2024-05-05 21:45:12', 0, 3),
(47, 51, NULL, NULL, '2024-05-06 18:28:16', 0, 2),
(48, 51, NULL, NULL, '2024-05-06 18:28:16', 0, 3),
(50, 52, NULL, NULL, '2024-05-09 18:27:57', 0, 2),
(51, 52, NULL, NULL, '2024-05-09 18:27:57', 0, 3),
(52, 53, NULL, NULL, '2024-05-10 16:06:03', 0, 2),
(53, 53, NULL, NULL, '2024-05-10 16:06:03', 0, 3),
(54, 54, NULL, NULL, '2024-05-11 14:43:51', 0, 2),
(55, 54, NULL, NULL, '2024-05-11 14:43:51', 0, 3),
(56, NULL, NULL, 35, '2024-05-11 15:05:14', 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `question`
--

CREATE TABLE `question` (
  `id` int(11) NOT NULL,
  `question` varchar(2000) DEFAULT NULL,
  `type` int(1) DEFAULT NULL COMMENT '0 - MCQ / 1 - T/F /2- COMPLETE/',
  `points` int(11) NOT NULL DEFAULT 1,
  `difficulty` tinyint(1) DEFAULT 1,
  `isTrue` tinyint(1) NOT NULL DEFAULT 1,
  `instructorID` int(11) NOT NULL,
  `courseID` int(11) DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `question`
--

INSERT INTO `question` (`id`, `question`, `type`, `points`, `difficulty`, `isTrue`, `instructorID`, `courseID`, `deleted`) VALUES
(217, '<p><strong style=\"font-size: 14px; line-height: var(--cib-type-body1-strong-line-height); font-weight: bold; font-variation-settings: normal; color: rgba(0, 0, 0, 0.894); font-family: SegoeUIVariable, SegoeUI, &quot;Segoe UI&quot;, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft YaHei&quot;, &quot;Meiryo UI&quot;, Meiryo, &quot;Arial Unicode MS&quot;, sans-serif; background-color: rgb(243, 243, 243);\">Question</strong><span style=\"color: rgba(0, 0, 0, 0.894); font-family: SegoeUIVariable, SegoeUI, &quot;Segoe UI&quot;, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft YaHei&quot;, &quot;Meiryo UI&quot;, Meiryo, &quot;Arial Unicode MS&quot;, sans-serif; font-size: 14px; background-color: rgb(243, 243, 243);\">: PHP stands for “Personal Home Page”</span></p>', 1, 2, 1, 0, 35, 87, 0),
(218, '<p><strong style=\"font-size: 14px; line-height: var(--cib-type-body1-strong-line-height); font-weight: bold; font-variation-settings: normal; color: rgba(0, 0, 0, 0.894); font-family: SegoeUIVariable, SegoeUI, &quot;Segoe UI&quot;, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft YaHei&quot;, &quot;Meiryo UI&quot;, Meiryo, &quot;Arial Unicode MS&quot;, sans-serif; background-color: rgb(243, 243, 243);\">Question</strong><span style=\"color: rgba(0, 0, 0, 0.894); font-family: SegoeUIVariable, SegoeUI, &quot;Segoe UI&quot;, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft YaHei&quot;, &quot;Meiryo UI&quot;, Meiryo, &quot;Arial Unicode MS&quot;, sans-serif; font-size: 14px; background-color: rgb(243, 243, 243);\">: PHP is a server-side scripting language.&nbsp;</span></p>', 1, 2, 1, 1, 35, 87, 0),
(219, '<p><strong style=\"font-size: 14px; line-height: var(--cib-type-body1-strong-line-height); font-weight: bold; font-variation-settings: normal; color: rgba(0, 0, 0, 0.894); font-family: SegoeUIVariable, SegoeUI, &quot;Segoe UI&quot;, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft YaHei&quot;, &quot;Meiryo UI&quot;, Meiryo, &quot;Arial Unicode MS&quot;, sans-serif; background-color: rgb(243, 243, 243);\">Question</strong><span style=\"color: rgba(0, 0, 0, 0.894); font-family: SegoeUIVariable, SegoeUI, &quot;Segoe UI&quot;, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft YaHei&quot;, &quot;Meiryo UI&quot;, Meiryo, &quot;Arial Unicode MS&quot;, sans-serif; font-size: 14px; background-color: rgb(243, 243, 243);\">: PHP can only be embedded within HTML.&nbsp;</span></p>', 1, 2, 1, 0, 35, 87, 0),
(220, '<p><strong style=\"font-size: 14px; line-height: var(--cib-type-body1-strong-line-height); font-weight: bold; font-variation-settings: normal; color: rgba(0, 0, 0, 0.894); font-family: SegoeUIVariable, SegoeUI, &quot;Segoe UI&quot;, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft YaHei&quot;, &quot;Meiryo UI&quot;, Meiryo, &quot;Arial Unicode MS&quot;, sans-serif; background-color: rgb(243, 243, 243);\">Question</strong><span style=\"color: rgba(0, 0, 0, 0.894); font-family: SegoeUIVariable, SegoeUI, &quot;Segoe UI&quot;, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft YaHei&quot;, &quot;Meiryo UI&quot;, Meiryo, &quot;Arial Unicode MS&quot;, sans-serif; font-size: 14px; background-color: rgb(243, 243, 243);\">: PHP supports “multiple inheritance”, a feature where a class can inherit behaviors and features from more than one superclass.&nbsp;</span></p>', 1, 2, 3, 0, 35, 87, 0),
(221, '<p><strong style=\"font-size: 14px; line-height: var(--cib-type-body1-strong-line-height); font-weight: bold; font-variation-settings: normal; color: rgba(0, 0, 0, 0.894); font-family: SegoeUIVariable, SegoeUI, &quot;Segoe UI&quot;, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft YaHei&quot;, &quot;Meiryo UI&quot;, Meiryo, &quot;Arial Unicode MS&quot;, sans-serif; background-color: rgb(243, 243, 243);\">Question</strong><span style=\"color: rgba(0, 0, 0, 0.894); font-family: SegoeUIVariable, SegoeUI, &quot;Segoe UI&quot;, &quot;Helvetica Neue&quot;, Helvetica, &quot;Microsoft YaHei&quot;, &quot;Meiryo UI&quot;, Meiryo, &quot;Arial Unicode MS&quot;, sans-serif; font-size: 14px; background-color: rgb(243, 243, 243);\">: PHP does not support exception handling with try/catch blocks.&nbsp;</span></p>', 1, 2, 3, 0, 35, 87, 0),
(222, '<p>Hi&nbsp;</p>', 1, 2, 2, 1, 35, 87, 0),
(223, '<p>Hi&nbsp;</p>', 1, 2, 2, 1, 35, 87, 0),
(224, '<p>dddd</p>', 1, 5, 3, 0, 35, 87, 0);

-- --------------------------------------------------------

--
-- Table structure for table `question_answers`
--

CREATE TABLE `question_answers` (
  `id` int(11) NOT NULL,
  `questionID` int(11) DEFAULT NULL,
  `answer` varchar(2000) DEFAULT NULL,
  `matchAnswer` varchar(255) DEFAULT NULL,
  `isCorrect` tinyint(1) DEFAULT 1,
  `points` int(2) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `resources_students`
--

CREATE TABLE `resources_students` (
  `id` int(11) NOT NULL,
  `title_of_resources` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `url` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_number` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `resources_students`
--

INSERT INTO `resources_students` (`id`, `title_of_resources`, `description`, `url`, `created_at`, `id_number`) VALUES
(2001666, '..FullStack web developer ', 'sssss', 'https://www.youtube.com/watch?v=xiUTqnI6xk8&pp=ygUDc3Fs', '2024-05-21 16:39:46', 3),
(2001506, '..FullStack web developer ', 'aaaa', 'https://www.youtube.com/watch?v=xiUTqnI6xk8&pp=ygUDc3Fs', '2024-05-21 16:41:25', 4),
(2001506, '..FullStack web developer ', 'fghfgh', 'https://www.youtube.com/watch?v=xiUTqnI6xk8&pp=ygUDc3Fs', '2024-05-21 17:33:02', 12),
(2001506, '..FullStack web developer ', 'fghfgh', 'https://www.youtube.com/watch?v=xiUTqnI6xk8&pp=ygUDc3Fs', '2024-05-21 17:33:37', 13),
(2001506, '..FullStack web developer ', 'ssss', 'https://www.youtube.com/watch?v=xiUTqnI6xk8&pp=ygUDc3Fs', '2024-05-21 17:34:32', 14),
(2001506, 'it ', 'course', 'https://www.youtube.com/watch?v=xiUTqnI6xk8&pp=ygUDc3Fs', '2024-05-21 17:50:43', 15),
(2001506, 'Network resources ', 'this course for CCNA 200-301 ', 'https://www.youtube.com/watch?v=xiUTqnI6xk8&pp=ygUDc3Fs', '2024-05-21 17:56:15', 16),
(2001506, 'php', 'php course ', 'https://www.youtube.com/watch?v=xiUTqnI6xk8&pp=ygUDc3Fs', '2024-05-21 18:58:34', 17),
(2020201, 'php', 'aaaaaaaaaaaaaaaaaaaaaaaa', 'https://www.youtube.com/watch?v=xiUTqnI6xk8&pp=ygUDc3Fs', '2024-05-21 22:29:37', 19),
(2001666, 'php', 'sdsdsd', 'https://www.youtube.com/watch?v=xiUTqnI6xk8&pp=ygUDc3Fs', '2024-05-21 23:37:00', 20);

-- --------------------------------------------------------

--
-- Table structure for table `result`
--

CREATE TABLE `result` (
  `id` int(11) NOT NULL,
  `studentID` int(11) NOT NULL,
  `testID` int(11) NOT NULL,
  `groupID` int(11) DEFAULT NULL,
  `settingID` int(11) DEFAULT NULL,
  `startTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `endTime` timestamp NULL DEFAULT NULL,
  `isTemp` tinyint(1) NOT NULL DEFAULT 1,
  `hostname` varchar(255) DEFAULT NULL,
  `ipaddr` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `result`
--

INSERT INTO `result` (`id`, `studentID`, `testID`, `groupID`, `settingID`, `startTime`, `endTime`, `isTemp`, `hostname`, `ipaddr`) VALUES
(49, 2001666, 53, 23, 100, '2024-05-02 19:14:19', '2024-05-02 19:14:44', 0, 'Joseph', '::1'),
(50, 2001506, 53, 23, 101, '2024-05-05 21:44:48', '2024-05-05 21:45:12', 0, 'Joseph', '::1'),
(51, 2020147, 53, 24, 102, '2024-05-06 18:27:57', '2024-05-06 18:28:16', 0, 'Joseph', '::1'),
(52, 2001666, 54, 26, 103, '2024-05-09 18:27:39', '2024-05-09 18:27:57', 0, 'Joseph', '::1'),
(53, 2001666, 55, 27, 104, '2024-05-10 16:05:34', '2024-05-10 16:06:03', 0, 'Joseph', '::1'),
(54, 2001666, 56, 27, 105, '2024-05-11 14:43:10', '2024-05-11 14:43:51', 0, 'Joseph', '::1');

-- --------------------------------------------------------

--
-- Table structure for table `result_answers`
--

CREATE TABLE `result_answers` (
  `id` int(11) NOT NULL,
  `resultID` int(11) NOT NULL,
  `questionID` int(11) NOT NULL,
  `answerID` int(11) DEFAULT NULL,
  `isTrue` tinyint(1) DEFAULT NULL,
  `textAnswer` varchar(2000) DEFAULT NULL,
  `points` int(3) DEFAULT -1,
  `isCorrect` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `result_answers`
--

INSERT INTO `result_answers` (`id`, `resultID`, `questionID`, `answerID`, `isTrue`, `textAnswer`, `points`, `isCorrect`) VALUES
(504, 49, 218, NULL, 1, NULL, 2, 1),
(505, 49, 223, NULL, 1, NULL, 2, 1),
(506, 49, 222, NULL, 1, NULL, 2, 1),
(507, 49, 220, NULL, 1, NULL, 0, 0),
(508, 49, 221, NULL, 0, NULL, 2, 1),
(509, 49, 219, NULL, 1, NULL, 0, 0),
(510, 49, 217, NULL, 0, NULL, 2, 1),
(511, 50, 220, NULL, 1, NULL, 0, 0),
(512, 50, 219, NULL, 1, NULL, 0, 0),
(513, 50, 223, NULL, 1, NULL, 2, 1),
(514, 50, 218, NULL, 1, NULL, 2, 1),
(515, 50, 222, NULL, 1, NULL, 2, 1),
(516, 50, 221, NULL, 1, NULL, 0, 0),
(517, 50, 217, NULL, 1, NULL, 0, 0),
(518, 51, 221, NULL, 1, NULL, 0, 0),
(519, 51, 219, NULL, 1, NULL, 0, 0),
(520, 51, 218, NULL, 0, NULL, 0, 0),
(521, 51, 222, NULL, 1, NULL, 2, 1),
(522, 51, 217, NULL, 0, NULL, 2, 1),
(523, 51, 220, NULL, 1, NULL, 0, 0),
(524, 51, 223, NULL, 0, NULL, 0, 0),
(525, 52, 221, NULL, 1, NULL, 0, 0),
(526, 52, 220, NULL, 1, NULL, 0, 0),
(527, 52, 223, NULL, 1, NULL, 2, 1),
(528, 52, 219, NULL, 1, NULL, 0, 0),
(529, 52, 218, NULL, 1, NULL, 2, 1),
(530, 52, 222, NULL, 1, NULL, 2, 1),
(531, 52, 217, NULL, 1, NULL, 0, 0),
(532, 52, 224, NULL, 1, NULL, 0, 0),
(533, 53, 224, NULL, 1, NULL, 0, 0),
(534, 53, 217, NULL, 1, NULL, 0, 0),
(535, 53, 223, NULL, 1, NULL, 2, 1),
(536, 53, 218, NULL, 1, NULL, 2, 1),
(537, 53, 222, NULL, 1, NULL, 2, 1),
(538, 53, 221, NULL, 1, NULL, 0, 0),
(539, 53, 220, NULL, 0, NULL, 2, 1),
(540, 54, 221, NULL, 1, NULL, 0, 0),
(541, 54, 217, NULL, 1, NULL, 0, 0),
(542, 54, 220, NULL, 0, NULL, 2, 1),
(543, 54, 222, NULL, 1, NULL, 2, 1),
(544, 54, 223, NULL, 1, NULL, 2, 1),
(545, 54, 218, NULL, 0, NULL, 0, 0);

--
-- Triggers `result_answers`
--
DELIMITER $$
CREATE TRIGGER `as` BEFORE INSERT ON `result_answers` FOR EACH ROW BEGIN
		DECLARE qtype INT;
		DECLARE qpoints INT;
    SET qtype = (SELECT type FROM question where id = NEW.questionID);
		SET qpoints = (SELECT points from question WHERE id = NEW.questionID);
    IF(qtype = 1) THEN
			IF NEW.isTrue = (SELECT isTrue from question where id = NEW.questionID) THEN
			SET NEW.isCorrect = 1;
			SET NEW.points = qpoints;
			ELSE
			SET NEW.isCorrect = 0;
			SET NEW.points = 0;
			END IF;
		ELSEIF(qtype = 5) THEN
			IF NEW.textAnswer = '' THEN
			SET NEW.isCorrect = 0;
			SET NEW.points = 0;
			END IF;
		ELSEIF(qtype = 4) THEN
			IF (NEW.textAnswer = (SELECT matchAnswer from question_answers where id = NEW.answerID)) THEN
				SET NEW.isCorrect = 1;
				SET NEW.points = (SELECT points FROM question_answers where id = NEW.answerID);
			ELSE
				SET NEW.isCorrect = 0;
				SET NEW.points = 0;
			END IF;
    END IF;
    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE `student` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `password_token` varchar(100) DEFAULT NULL,
  `token_expire` timestamp NULL DEFAULT NULL,
  `suspended` tinyint(1) DEFAULT 0,
  `sessionID` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`id`, `name`, `email`, `phone`, `password`, `password_token`, `token_expire`, `suspended`, `sessionID`) VALUES
(2001506, 'Mostafa sasa', 'Sasa12@gmail.com', '01112215387', '$2y$10$azsaNH9IEe10tNXfpuhZfubFNu1JhrT17r3LRSUyejAVgRmx7Id4u', NULL, NULL, 0, '2tqvjrqeq5nv8vbqgmege3loqv'),
(2001666, 'Joseph', 'josephmagdy56@gmail.com', '01112215391', '471933be6f562bcf71fa0feffa7e4439', '1a50466cd741f836315e25c15e79935ae6050749cb86bffd4e', '2024-05-03 21:26:50', 0, '1jr34g3bln91araa3rg43ma12q'),
(2020147, 'Akram', 'akram@gmail.com', '01016122685', '471933be6f562bcf71fa0feffa7e4439', NULL, NULL, 0, 'uklrnsqq5s1n28ank5dtqj72o0'),
(2020201, 'ahmed ', 'ahmed12@gmail.com', '01279848680', '471933be6f562bcf71fa0feffa7e4439', NULL, NULL, 0, '5vvgluehc5ga3a7phqei66akr2');

-- --------------------------------------------------------

--
-- Table structure for table `students_has_tests`
--

CREATE TABLE `students_has_tests` (
  `studentID` int(11) DEFAULT NULL,
  `testID` int(11) DEFAULT NULL,
  `settingID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `subject_name`
--

CREATE TABLE `subject_name` (
  `id` int(11) UNSIGNED NOT NULL,
  `subject_Name` int(255) NOT NULL,
  `code_subject` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `survey_responses`
--

CREATE TABLE `survey_responses` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `ID_Student` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `favorite_sport` varchar(255) NOT NULL,
  `favorite_sport_person` varchar(255) NOT NULL,
  `feedback` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `survey_responses`
--

INSERT INTO `survey_responses` (`id`, `name`, `ID_Student`, `type`, `favorite_sport`, `favorite_sport_person`, `feedback`, `created_at`) VALUES
(40, 'Joseph3', 101010, 'Yes', 'the test is close on me ', 'Yes  ', 'make the search bar on system ', '2024-05-16 12:53:45'),
(49, ' Mostafa sasa', 2000506, 'Yes', 'The website go into drop ', 'Maybe ', 'Make enhancement To website this my Suggestion ', '2024-05-18 20:17:39'),
(50, 'Akram ', 2000741, 'Yes', 'I\'am not able to Start a test ', 'Yes I Love Online Exams', 'suggestion .....', '2024-05-18 20:19:13'),
(53, 'Ahmed Moahmed', 2054789, 'Yes', 'I\'am not able to Start a test ', 'Yes I Love Online Exams', 'suggestion .....', '2024-05-18 20:20:27'),
(54, 'Mena', 2054789, 'No', 'no', 'Yes I Love Online Exams', 'suggestion .....', '2024-05-18 20:20:46'),
(55, 'Mena magdy', 205477, 'Both', 'no', 'Yes I Love Online Exams', 'suggestion .....', '2024-05-18 20:21:01'),
(56, 'Mark', 20548, 'Both', 'no', 'Yes I Love Online Exams', 'suggestion .....', '2024-05-18 20:21:15'),
(57, 'Eyad', 205410, 'Yes', 'no', 'Yes I Love Online Exams', 'suggestion .....', '2024-05-18 20:21:31'),
(58, '  Moahmed', 2020200, 'Yes', 'no', 'Yes I Love Online Exams', 'suggestion .....', '2024-05-21 22:11:26'),
(59, '  ahmed', 2020200, 'Both', 'no', 'Yes I Love Online Exams', 'suggestion .....', '2024-05-21 22:28:45'),
(60, '  ahmed', 2020200, 'Yes', 'no', 'Yes I Love Online Exams', 'suggestion .....', '2024-05-21 23:39:19');

-- --------------------------------------------------------

--
-- Table structure for table `tempquestions`
--

CREATE TABLE `tempquestions` (
  `resultID` int(11) NOT NULL,
  `questionID` int(11) NOT NULL,
  `rand` int(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `test`
--

CREATE TABLE `test` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `courseID` int(11) DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT 0,
  `instructorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `test`
--

INSERT INTO `test` (`id`, `name`, `courseID`, `deleted`, `instructorID`) VALUES
(53, 'test php', 86, 0, 35),
(54, 'cdd', 88, 0, 35),
(55, 'English2', 90, 0, 35),
(56, 'quiz5', 90, 0, 35),
(57, 'test php2', 86, 0, 35),
(58, 'joe', 86, 0, 35);

-- --------------------------------------------------------

--
-- Table structure for table `tests_has_questions`
--

CREATE TABLE `tests_has_questions` (
  `testID` int(11) DEFAULT NULL,
  `questionID` int(11) DEFAULT NULL,
  `rand` int(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `tests_has_questions`
--

INSERT INTO `tests_has_questions` (`testID`, `questionID`, `rand`) VALUES
(53, 217, NULL),
(53, 218, NULL),
(53, 219, NULL),
(53, 220, NULL),
(53, 221, NULL),
(53, 222, NULL),
(53, 223, NULL),
(54, 217, NULL),
(54, 218, NULL),
(54, 219, NULL),
(54, 220, NULL),
(54, 221, NULL),
(54, 222, NULL),
(54, 223, NULL),
(55, 217, NULL),
(55, 218, NULL),
(55, 220, NULL),
(55, 221, NULL),
(55, 222, NULL),
(55, 223, NULL),
(56, 217, NULL),
(56, 218, NULL),
(56, 220, NULL),
(56, 221, NULL),
(56, 222, NULL),
(56, 223, NULL),
(57, 217, NULL),
(57, 218, NULL),
(57, 219, NULL),
(57, 220, NULL),
(57, 221, NULL),
(57, 222, NULL),
(57, 223, NULL),
(57, 224, NULL),
(58, 217, NULL),
(58, 218, NULL),
(58, 219, NULL),
(58, 220, NULL),
(58, 221, NULL),
(58, 222, NULL),
(58, 223, NULL),
(58, 224, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `test_invitations`
--

CREATE TABLE `test_invitations` (
  `id` int(15) NOT NULL,
  `name` varchar(255) NOT NULL,
  `testID` int(11) DEFAULT NULL,
  `settingID` int(11) DEFAULT NULL,
  `used` tinyint(1) DEFAULT 0,
  `useLimit` int(11) DEFAULT NULL,
  `instructorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `test_random_questions`
--

CREATE TABLE `test_random_questions` (
  `testID` int(11) NOT NULL,
  `courseID` int(11) NOT NULL,
  `questionsCount` int(11) NOT NULL,
  `difficulty` int(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `test_settings`
--

CREATE TABLE `test_settings` (
  `id` int(11) NOT NULL,
  `startTime` datetime DEFAULT NULL,
  `endTime` datetime DEFAULT NULL,
  `duration` int(3) DEFAULT NULL,
  `random` tinyint(255) DEFAULT NULL,
  `prevQuestion` int(1) DEFAULT NULL,
  `viewAnswers` tinyint(1) DEFAULT NULL,
  `releaseResult` int(1) DEFAULT 1,
  `sendToStudent` tinyint(1) DEFAULT NULL,
  `sendToInstructor` tinyint(1) DEFAULT NULL,
  `passPercent` int(3) DEFAULT NULL,
  `instructorID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `test_settings`
--

INSERT INTO `test_settings` (`id`, `startTime`, `endTime`, `duration`, `random`, `prevQuestion`, `viewAnswers`, `releaseResult`, `sendToStudent`, `sendToInstructor`, `passPercent`, `instructorID`) VALUES
(100, '2024-05-02 22:13:00', '2024-05-02 23:45:00', 10, 1, 1, 0, 1, 1, 1, 60, 35),
(101, '2024-05-06 00:37:00', '2024-05-06 01:37:00', 10, 1, 1, 0, 1, 1, 1, 60, 35),
(102, '2024-05-06 21:27:00', '2024-05-06 22:27:00', 10, 1, 1, 0, 1, 1, 1, 60, 35),
(103, '2024-05-09 21:20:00', '2024-05-09 22:20:00', 10, 1, 1, 0, 1, 1, 1, 60, 35),
(104, '2024-05-10 19:04:00', '2024-05-10 20:04:00', 10, 1, 1, 0, 1, 1, 1, 60, 35),
(105, '2024-05-11 17:42:00', '2024-05-11 18:42:00', 15, 1, 1, 0, 1, 1, 1, 60, 35),
(109, '2024-05-23 19:09:00', '2024-05-23 20:09:00', 10, 1, 1, 0, 1, 1, 1, 60, 35);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `contactsupport`
--
ALTER TABLE `contactsupport`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `course`
--
ALTER TABLE `course`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE,
  ADD KEY `parent` (`parent`) USING BTREE;

--
-- Indexes for table `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE,
  ADD KEY `settingID` (`settingID`) USING BTREE,
  ADD KEY `groups_ibfk_2` (`assignedTest`) USING BTREE;

--
-- Indexes for table `groups_has_students`
--
ALTER TABLE `groups_has_students`
  ADD UNIQUE KEY `my_unique_key` (`groupID`,`studentID`) USING BTREE,
  ADD KEY `groups_has_students_ibfk_2` (`studentID`) USING BTREE;

--
-- Indexes for table `group_invitations`
--
ALTER TABLE `group_invitations`
  ADD UNIQUE KEY `code` (`code`) USING BTREE,
  ADD KEY `groupID` (`groupID`) USING BTREE;

--
-- Indexes for table `instructor`
--
ALTER TABLE `instructor`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mails`
--
ALTER TABLE `mails`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `resultID` (`resultID`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE,
  ADD KEY `studentID` (`studentID`) USING BTREE;

--
-- Indexes for table `question`
--
ALTER TABLE `question`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `question_ibfk_1` (`instructorID`) USING BTREE,
  ADD KEY `question_ibfk_2` (`courseID`) USING BTREE;

--
-- Indexes for table `question_answers`
--
ALTER TABLE `question_answers`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `answers_ibfk_1` (`questionID`) USING BTREE,
  ADD KEY `matchAnswer` (`matchAnswer`) USING BTREE;

--
-- Indexes for table `resources_students`
--
ALTER TABLE `resources_students`
  ADD PRIMARY KEY (`id_number`),
  ADD KEY `id` (`id`);

--
-- Indexes for table `result`
--
ALTER TABLE `result`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `testID_2` (`testID`,`studentID`) USING BTREE,
  ADD KEY `result_ibfk_2` (`studentID`) USING BTREE,
  ADD KEY `settingID` (`settingID`) USING BTREE,
  ADD KEY `groupID` (`groupID`) USING BTREE;

--
-- Indexes for table `result_answers`
--
ALTER TABLE `result_answers`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `FK_result_answers_result` (`resultID`) USING BTREE,
  ADD KEY `FK_result_answers_question` (`questionID`) USING BTREE,
  ADD KEY `answerID` (`answerID`) USING BTREE;

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `email` (`email`) USING BTREE;

--
-- Indexes for table `students_has_tests`
--
ALTER TABLE `students_has_tests`
  ADD UNIQUE KEY `StudentID` (`studentID`,`testID`) USING BTREE,
  ADD KEY `students_has_tests_ibfk_1` (`studentID`) USING BTREE,
  ADD KEY `students_has_tests_ibfk_2` (`testID`) USING BTREE,
  ADD KEY `students_has_tests_ibfk_3` (`settingID`) USING BTREE;

--
-- Indexes for table `subject_name`
--
ALTER TABLE `subject_name`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code_subject` (`code_subject`);

--
-- Indexes for table `survey_responses`
--
ALTER TABLE `survey_responses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tempquestions`
--
ALTER TABLE `tempquestions`
  ADD UNIQUE KEY `resultID` (`resultID`,`questionID`) USING BTREE,
  ADD KEY `quest` (`questionID`) USING BTREE;

--
-- Indexes for table `test`
--
ALTER TABLE `test`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE,
  ADD KEY `courseID` (`courseID`) USING BTREE;

--
-- Indexes for table `tests_has_questions`
--
ALTER TABLE `tests_has_questions`
  ADD UNIQUE KEY `my_unique_key` (`testID`,`questionID`) USING BTREE,
  ADD KEY `tests_has_questions_ibfk_2` (`questionID`) USING BTREE;

--
-- Indexes for table `test_invitations`
--
ALTER TABLE `test_invitations`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE,
  ADD KEY `settingID` (`settingID`) USING BTREE,
  ADD KEY `test_invitations_ibfk_1` (`testID`) USING BTREE;

--
-- Indexes for table `test_random_questions`
--
ALTER TABLE `test_random_questions`
  ADD UNIQUE KEY `testID_2` (`testID`,`courseID`,`difficulty`) USING BTREE,
  ADD KEY `testID` (`testID`) USING BTREE,
  ADD KEY `courseID` (`courseID`) USING BTREE;

--
-- Indexes for table `test_settings`
--
ALTER TABLE `test_settings`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `instructorID` (`instructorID`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `contactsupport`
--
ALTER TABLE `contactsupport`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `course`
--
ALTER TABLE `course`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=92;

--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `instructor`
--
ALTER TABLE `instructor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- AUTO_INCREMENT for table `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `mails`
--
ALTER TABLE `mails`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `question`
--
ALTER TABLE `question`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=225;

--
-- AUTO_INCREMENT for table `question_answers`
--
ALTER TABLE `question_answers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=912;

--
-- AUTO_INCREMENT for table `resources_students`
--
ALTER TABLE `resources_students`
  MODIFY `id_number` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `result`
--
ALTER TABLE `result`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `result_answers`
--
ALTER TABLE `result_answers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=552;

--
-- AUTO_INCREMENT for table `survey_responses`
--
ALTER TABLE `survey_responses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `test`
--
ALTER TABLE `test`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `test_invitations`
--
ALTER TABLE `test_invitations`
  MODIFY `id` int(15) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `test_settings`
--
ALTER TABLE `test_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=110;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `course`
--
ALTER TABLE `course`
  ADD CONSTRAINT `course_ibfk_1` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `course_ibfk_2` FOREIGN KEY (`parent`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `groups`
--
ALTER TABLE `groups`
  ADD CONSTRAINT `groups_ibfk_1` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `groups_ibfk_2` FOREIGN KEY (`assignedTest`) REFERENCES `test` (`id`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `groups_ibfk_3` FOREIGN KEY (`settingID`) REFERENCES `test_settings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `groups_has_students`
--
ALTER TABLE `groups_has_students`
  ADD CONSTRAINT `groups_has_students_ibfk_1` FOREIGN KEY (`groupID`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `groups_has_students_ibfk_2` FOREIGN KEY (`studentID`) REFERENCES `student` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `group_invitations`
--
ALTER TABLE `group_invitations`
  ADD CONSTRAINT `group_invitations_ibfk_1` FOREIGN KEY (`groupID`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `mails`
--
ALTER TABLE `mails`
  ADD CONSTRAINT `mails_ibfk_1` FOREIGN KEY (`resultID`) REFERENCES `result` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `mails_ibfk_2` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `mails_ibfk_3` FOREIGN KEY (`studentID`) REFERENCES `student` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `question`
--
ALTER TABLE `question`
  ADD CONSTRAINT `question_ibfk_1` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`),
  ADD CONSTRAINT `question_ibfk_2` FOREIGN KEY (`courseID`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `question_answers`
--
ALTER TABLE `question_answers`
  ADD CONSTRAINT `question_answers_ibfk_1` FOREIGN KEY (`questionID`) REFERENCES `question` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `resources_students`
--
ALTER TABLE `resources_students`
  ADD CONSTRAINT `resources_students_ibfk_1` FOREIGN KEY (`id`) REFERENCES `student` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `result`
--
ALTER TABLE `result`
  ADD CONSTRAINT `result_ibfk_2` FOREIGN KEY (`studentID`) REFERENCES `student` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `result_ibfk_3` FOREIGN KEY (`testID`) REFERENCES `test` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `result_ibfk_4` FOREIGN KEY (`settingID`) REFERENCES `test_settings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `result_ibfk_5` FOREIGN KEY (`groupID`) REFERENCES `groups` (`id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `result_answers`
--
ALTER TABLE `result_answers`
  ADD CONSTRAINT `FK_result_answers_result` FOREIGN KEY (`resultID`) REFERENCES `result` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `result_answers_ibfk_1` FOREIGN KEY (`answerID`) REFERENCES `question_answers` (`id`),
  ADD CONSTRAINT `result_answers_ibfk_2` FOREIGN KEY (`questionID`) REFERENCES `question` (`id`);

--
-- Constraints for table `students_has_tests`
--
ALTER TABLE `students_has_tests`
  ADD CONSTRAINT `students_has_tests_ibfk_1` FOREIGN KEY (`studentID`) REFERENCES `student` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `students_has_tests_ibfk_2` FOREIGN KEY (`testID`) REFERENCES `test` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `students_has_tests_ibfk_3` FOREIGN KEY (`settingID`) REFERENCES `test_settings` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `tempquestions`
--
ALTER TABLE `tempquestions`
  ADD CONSTRAINT `tempquestions_ibfk_1` FOREIGN KEY (`resultID`) REFERENCES `result` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `test`
--
ALTER TABLE `test`
  ADD CONSTRAINT `test_ibfk_1` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `test_ibfk_2` FOREIGN KEY (`courseID`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tests_has_questions`
--
ALTER TABLE `tests_has_questions`
  ADD CONSTRAINT `tests_has_questions_ibfk_1` FOREIGN KEY (`testID`) REFERENCES `test` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tests_has_questions_ibfk_2` FOREIGN KEY (`questionID`) REFERENCES `question` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `test_invitations`
--
ALTER TABLE `test_invitations`
  ADD CONSTRAINT `test_invitations_ibfk_1` FOREIGN KEY (`testID`) REFERENCES `test` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `test_invitations_ibfk_3` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `test_invitations_ibfk_4` FOREIGN KEY (`settingID`) REFERENCES `test_settings` (`id`);

--
-- Constraints for table `test_random_questions`
--
ALTER TABLE `test_random_questions`
  ADD CONSTRAINT `test_random_questions_ibfk_1` FOREIGN KEY (`courseID`) REFERENCES `course` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `test_random_questions_ibfk_2` FOREIGN KEY (`testID`) REFERENCES `test` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `test_settings`
--
ALTER TABLE `test_settings`
  ADD CONSTRAINT `test_settings_ibfk_1` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
