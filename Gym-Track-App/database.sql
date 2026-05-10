-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: gymtrack
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `body_parts`
--

DROP TABLE IF EXISTS `body_parts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `body_parts` (
  `b_bId` int NOT NULL AUTO_INCREMENT,
  `b_name` varchar(50) NOT NULL,
  `b_description` text,
  PRIMARY KEY (`b_bId`),
  UNIQUE KEY `b_name` (`b_name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `body_parts`
--

LOCK TABLES `body_parts` WRITE;
/*!40000 ALTER TABLE `body_parts` DISABLE KEYS */;
INSERT INTO `body_parts` VALUES (1,'Chest',NULL),(2,'Back',NULL),(3,'Legs',NULL),(4,'Shoulders',NULL),(5,'Arms',NULL),(6,'Core',NULL);
/*!40000 ALTER TABLE `body_parts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercises`
--

DROP TABLE IF EXISTS `exercises`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercises` (
  `e_exerciseId` int NOT NULL AUTO_INCREMENT,
  `e_itemName` varchar(100) NOT NULL,
  `e_itemDescription` text,
  `e_bId` int NOT NULL,
  PRIMARY KEY (`e_exerciseId`),
  UNIQUE KEY `e_itemName` (`e_itemName`),
  KEY `e_bId` (`e_bId`),
  CONSTRAINT `exercises_ibfk_1` FOREIGN KEY (`e_bId`) REFERENCES `body_parts` (`b_bId`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercises`
--

LOCK TABLES `exercises` WRITE;
/*!40000 ALTER TABLE `exercises` DISABLE KEYS */;
INSERT INTO `exercises` VALUES (1,'Barbell Bench Press','0',1),(2,'Dumbbell Bench Press','0',1),(3,'Incline Barbell Bench Press','0',1),(4,'Incline Dumbbell Bench Press','0',1),(5,'Cable Chest Fly','0',1),(6,'Machine Chest Press','0',1),(7,'Dips','0',1),(8,'Dumbbell Fly','0',1),(9,'Pull-up','0',2),(10,'Lat Pulldown','0',2),(11,'Barbell Row','0',2),(12,'Dumbbell Row','0',2),(13,'Seated Cable Row','0',2),(14,'T-Bar Row','0',2),(15,'Deadlift','0',2),(16,'Reverse Fly','0',2),(17,'Straight Arm Pulldown','0',2),(18,'Machine Row','0',2),(19,'Squat','0',3),(20,'Leg Press','0',3),(21,'Romanian Deadlift','0',3),(22,'Leg Extension','0',3),(23,'Leg Curl','0',3),(24,'Lunge','0',3),(25,'Hack Squat','0',3),(26,'Hip Thrust','0',3),(27,'Calf Raise','0',3),(28,'Sumo Squat','0',3),(29,'Barbell Shoulder Press','0',4),(30,'Dumbbell Shoulder Press','0',4),(31,'Lateral Raise','0',4),(32,'Front Raise','0',4),(33,'Bent-over Lateral Raise','0',4),(34,'Arnold Press','0',4),(35,'Cable Lateral Raise','0',4),(36,'Upright Row','0',4),(37,'Machine Shoulder Press','0',4),(38,'Barbell Curl','0',5),(39,'Dumbbell Curl','0',5),(40,'Hammer Curl','0',5),(41,'Cable Curl','0',5),(42,'Tricep Pushdown','0',5),(43,'Skull Crusher','0',5),(44,'Tricep Dip','0',5),(45,'Dumbbell Kickback','0',5),(46,'Plank','0',6),(47,'Side Plank','0',6),(48,'Crunch','0',6),(49,'Reverse Crunch','0',6),(50,'Hanging Leg Raise','0',6),(51,'Russian Twist','0',6),(52,'Mountain Climbers','0',6),(53,'Alternating Heel Touch','0',6),(54,'Leg Raise','0',6),(55,'Cable Crunch','0',6);
/*!40000 ALTER TABLE `exercises` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs` (
  `l_logId` int NOT NULL AUTO_INCREMENT,
  `l_userId` int NOT NULL,
  `l_loginTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `l_loginData` text,
  PRIMARY KEY (`l_logId`),
  KEY `l_userId` (`l_userId`),
  CONSTRAINT `logs_ibfk_1` FOREIGN KEY (`l_userId`) REFERENCES `users` (`u_userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs`
--

LOCK TABLES `logs` WRITE;
/*!40000 ALTER TABLE `logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `records`
--

DROP TABLE IF EXISTS `records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `records` (
  `r_logId` int NOT NULL AUTO_INCREMENT,
  `r_userId` int NOT NULL,
  `r_exerciseId` int NOT NULL,
  `r_logDate` date NOT NULL,
  `r_setNumber` int NOT NULL,
  `r_weight` decimal(5,2) NOT NULL,
  `r_reps` int NOT NULL,
  PRIMARY KEY (`r_logId`),
  KEY `r_userId` (`r_userId`),
  KEY `r_exerciseId` (`r_exerciseId`),
  CONSTRAINT `records_ibfk_1` FOREIGN KEY (`r_userId`) REFERENCES `users` (`u_userId`),
  CONSTRAINT `records_ibfk_2` FOREIGN KEY (`r_exerciseId`) REFERENCES `exercises` (`e_exerciseId`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `records`
--

LOCK TABLES `records` WRITE;
/*!40000 ALTER TABLE `records` DISABLE KEYS */;
INSERT INTO `records` VALUES (17,1000,20,'2025-11-30',1,150.00,10),(18,1000,20,'2025-11-30',2,170.50,8),(19,1000,20,'2025-11-30',3,190.00,5),(20,1000,20,'2025-11-30',4,150.00,12),(21,1000,30,'2025-11-30',1,25.00,12),(22,1000,30,'2025-11-30',2,30.00,10),(23,1000,30,'2025-11-30',3,30.00,8),(24,1000,30,'2025-11-30',4,25.00,10);
/*!40000 ALTER TABLE `records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `u_userId` int NOT NULL AUTO_INCREMENT,
  `u_userPin` char(4) NOT NULL,
  `u_username` varchar(50) NOT NULL,
  `u_email` varchar(100) NOT NULL,
  PRIMARY KEY (`u_userId`),
  UNIQUE KEY `u_username` (`u_username`),
  UNIQUE KEY `u_email` (`u_email`)
) ENGINE=InnoDB AUTO_INCREMENT=1002 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1000,'1234','test_user','user@example.com');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-02 10:00:58
