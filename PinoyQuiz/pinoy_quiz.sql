-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 17, 2025 at 12:11 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pinoy_quiz`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id`, `username`, `password`) VALUES
(1, 'admin', 'admin123');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`) VALUES
(1, 'History'),
(2, 'Culture'),
(3, 'Geography');

-- --------------------------------------------------------

--
-- Table structure for table `leaderboard`
--

CREATE TABLE `leaderboard` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `category_id` int(11) NOT NULL,
  `difficulty` varchar(20) NOT NULL,
  `score` int(11) NOT NULL,
  `total_questions` int(11) NOT NULL DEFAULT 10,
  `rate` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `difficulty` varchar(20) NOT NULL,
  `level` int(11) DEFAULT NULL,
  `question` text NOT NULL,
  `option_a` varchar(255) NOT NULL,
  `option_b` varchar(255) NOT NULL,
  `option_c` varchar(255) NOT NULL,
  `option_d` varchar(255) NOT NULL,
  `correct_option` char(1) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `questions`
--

INSERT INTO `questions` (`id`, `category_id`, `difficulty`, `level`, `question`, `option_a`, `option_b`, `option_c`, `option_d`, `correct_option`, `created_at`) VALUES
(27, 1, 'easy', 1, 'Who is known as the “Father of the Philippine Revolution”?', 'Emilio Aguinaldo', 'Apolinario Mabini', 'Andres Bonifacio', 'Jose Rizal', 'C', '2025-12-16 15:59:45'),
(28, 1, 'easy', 1, 'What is the capital city of the Philippines?', 'Cebu City', 'Manila', 'Baguio City', 'Davao City', 'B', '2025-12-16 15:59:45'),
(29, 1, 'easy', 1, 'Who is the national hero of the Philippines?', 'Emilio Aguinaldo', 'Jose Rizal', 'Lapu-Lapu', 'Andres Bonifacio', 'B', '2025-12-16 15:59:45'),
(30, 1, 'easy', 1, 'What year did the Philippines declare independence from Spain?', '1901', '1946', '1896', '1898', 'D', '2025-12-16 15:59:45'),
(31, 1, 'easy', 1, 'Which Filipino general is known as the “Brains of the Katipunan”?', 'Antonio Luna', 'Apolinario Mabini', 'Emilio Jacinto', 'Andres Bonifacio', 'C', '2025-12-16 15:59:45'),
(32, 1, 'easy', 1, 'What is the oldest city in the Philippines?', 'Iloilo', 'Manila', 'Cebu City', 'Vigan', 'C', '2025-12-16 15:59:45'),
(33, 1, 'easy', 1, 'Who was the first President of the Philippines?', 'Sergio Osmeña', 'Emilio Aguinaldo', 'Jose P. Laurel', 'Manuel L. Quezon', 'B', '2025-12-16 15:59:45'),
(34, 1, 'easy', 1, 'What is the name of the battle where Lapu-Lapu defeated Magellan?', 'Battle of Balangiga', 'Battle of Mactan', 'Battle of Tirad Pass', 'Battle of Manila Bay', 'B', '2025-12-16 15:59:45'),
(35, 1, 'easy', 1, 'Which U.S. President signed the Philippine Independence Act (Tydings-McDuffie Act)?', 'Harry S. Truman', 'Theodore Roosevelt', 'Franklin D. Roosevelt', 'Woodrow Wilson', 'C', '2025-12-16 15:59:45'),
(36, 1, 'easy', 1, 'What is the national language of the Philippines?', 'Tagalog', 'Spanish', 'Filipino', 'English', 'C', '2025-12-16 15:59:45'),
(37, 1, 'easy', 1, 'What was the name of the secret society that fought against Spanish rule?', 'Ilustrados', 'Katipunan', 'Guardia Civil', 'La Liga Filipina', 'B', '2025-12-16 15:59:45'),
(38, 1, 'easy', 1, 'Who was the first Filipino to circumnavigate the globe?', 'Ferdinand Magellan', 'Lapu-Lapu', 'Juan Sebastián Elcano', 'Enrique of Malacca', 'D', '2025-12-16 15:59:45'),
(39, 1, 'easy', 1, 'What is the name of the Philippine national anthem?', 'Bayan Ko', 'Lupang Hinirang', 'Awit ng Kalayaan', 'Pilipinas Kong Mahal', 'B', '2025-12-16 15:59:45'),
(40, 1, 'easy', 1, 'Who was the last Spanish Governor-General in the Philippines?', 'Ramón Blanco', 'Carlos María de la Torre', 'Diego de los Ríos', 'Miguel López de Legazpi', 'C', '2025-12-16 15:59:45'),
(41, 1, 'easy', 1, 'Which country colonized the Philippines after Spain?', 'Portugal', 'Japan', 'United States', 'United Kingdom', 'C', '2025-12-16 15:59:45'),
(42, 1, 'easy', 1, 'Who was the first woman president of the Philippines?', 'Miriam Defensor Santiago', 'Imelda Marcos', 'Corazon Aquino', 'Gloria Macapagal-Arroyo', 'C', '2025-12-16 15:59:45'),
(43, 1, 'easy', 1, 'What is the term for the forced labor system under Spanish rule?', 'Tributo', 'Polo y Servicio', 'Cedula', 'Encomienda', 'B', '2025-12-16 15:59:45'),
(44, 1, 'easy', 1, 'Which Filipino leader led the People Power Revolution in 1986?', 'Fidel V. Ramos', 'Benigno Aquino Jr.', 'Ferdinand Marcos', 'Corazon Aquino', 'D', '2025-12-16 15:59:45'),
(45, 1, 'easy', 1, 'What is the largest island in the Philippines?', 'Palawan', 'Samar', 'Luzon', 'Mindanao', 'C', '2025-12-16 15:59:45'),
(46, 1, 'easy', 1, 'Who is the “Mother of Balagtasan”?', 'Gabriela Silang', 'Melchora Aquino', 'Francisca Reyes Aquino', 'Trinidad Tecson', 'C', '2025-12-16 15:59:45'),
(47, 1, 'easy', 2, 'What is the Filipino word for “family”?', 'Kapamilya', 'Pamilya', 'Bahay', 'Tahanan', 'B', '2025-12-16 16:17:15'),
(48, 1, 'easy', 2, 'What is the famous Filipino dessert made with shaved ice and mixed fruits?', 'Halo-halo', 'Leche flan', 'Bibingka', 'Kutsinta', 'A', '2025-12-16 16:17:15'),
(49, 1, 'easy', 2, 'What is the oldest city in the Philippines?', 'Manila', 'Vigan', 'Cebu City', 'Iloilo', 'C', '2025-12-16 16:17:15'),
(50, 1, 'easy', 2, 'What is the traditional Filipino martial art?', 'Arnis', 'Taekwondo', 'Karate', 'Judo', 'A', '2025-12-16 16:17:15'),
(51, 1, 'easy', 2, 'Which Filipino festival features giant lanterns?', 'Sinulog', 'Giant Lantern Festival (Ligligan Parul)', 'Panagbenga', 'Kadayawan', 'B', '2025-12-16 16:17:15'),
(52, 1, 'easy', 2, 'What is the famous rice terrace complex in Ifugao called?', 'Banaue Rice Terraces', 'Batad Rice Terraces', 'Mayoyao Rice Terraces', 'Sagada Rice Terraces', 'A', '2025-12-16 16:17:15'),
(53, 1, 'easy', 2, 'What is the Filipino term for a communal spirit or helping each other?', 'Bayanihan', 'Kapwa', 'Pakikipagkapwa', 'Utang na loob', 'A', '2025-12-16 16:17:15'),
(54, 1, 'easy', 2, 'What is the largest island in the Philippines?', 'Mindanao', 'Palawan', 'Luzon', 'Samar', 'C', '2025-12-16 16:17:15'),
(55, 1, 'easy', 2, 'What is the name of the Filipino Christmas star-shaped lantern?', 'Parol', 'Belen', 'Ligligan', 'Christmas Star', 'A', '2025-12-16 16:17:15'),
(56, 1, 'easy', 2, 'What is the Filipino term for a wake or vigil for the dead?', 'Lamay', 'Libing', 'Pista', 'Salubong', 'A', '2025-12-16 16:17:15'),
(57, 1, 'easy', 2, 'What is the name of the Philippine national anthem?', 'Lupang Hinirang', 'Bayan Ko', 'Pilipinas Kong Mahal', 'Awit ng Kabataan', 'A', '2025-12-16 16:17:15'),
(58, 1, 'easy', 2, 'What is the Filipino term for the event of moving into a new house?', 'Lipat Bahay', 'Pabahay', 'Bahay Kubo', 'Paglipat', 'A', '2025-12-16 16:17:15'),
(59, 1, 'easy', 2, 'Which Filipino artist is known as the “Father of Philippine Painting”?', 'Juan Luna', 'Fernando Amorsolo', 'Benedicto Cabrera', 'Carlos “Botong” Francisco', 'B', '2025-12-16 16:17:15'),
(60, 1, 'easy', 2, 'What is the name of the largest festival in Davao City?', 'Kadayawan Festival', 'Sinulog', 'Panagbenga', 'Pahiyas', 'A', '2025-12-16 16:17:15'),
(61, 1, 'easy', 2, 'Which Philippine province is famous for the MassKara Festival?', 'Cebu', 'Negros Occidental (Bacolod City)', 'Iloilo', 'Pampanga', 'B', '2025-12-16 16:17:15'),
(62, 1, 'easy', 2, 'What indigenous group is known for tattooing in Kalinga?', 'Ifugao', 'Igorot', 'Butbut or the Kalinga people', 'Mangyan', 'C', '2025-12-16 16:17:15'),
(63, 1, 'easy', 2, 'What is the Filipino value of modesty, or not drawing attention to oneself, called?', 'Kagandahang-loob', 'Hiya', 'Pakikisama', 'Utang na loob', 'B', '2025-12-16 16:17:15'),
(64, 1, 'easy', 2, 'What is the Filipino term for a godparent?', 'Ninong/Ninang', 'Ninong/Ninang', 'Kumare/Kumpare', 'Tiyo/Tiya', 'A', '2025-12-16 16:17:15'),
(65, 1, 'easy', 2, 'What is the Filipino tradition of serenading called?', 'Harana', 'Kundiman', 'Balagtasan', 'Rondalla', 'A', '2025-12-16 16:17:15'),
(66, 1, 'easy', 2, 'Which Filipino value emphasizes helping family and friends even at personal cost?', 'Bayanihan', 'Pakikipagkapwa', 'Utang na loob', 'Hiya', 'B', '2025-12-16 16:17:15'),
(67, 2, 'easy', 1, 'What is the Filipino word for “family”?', 'Kapamilya', 'Pamilya', 'Bahay', 'Tahanan', 'B', '2025-12-16 16:24:59'),
(68, 2, 'easy', 1, 'What is the famous Filipino dessert made with shaved ice and mixed fruits?', 'Leche flan', 'Halo-halo', 'Bibingka', 'Kutsinta', 'B', '2025-12-16 16:24:59'),
(69, 2, 'easy', 1, 'What is the capital city of the Philippines?', 'Cebu', 'Davao', 'Manila', 'Quezon City', 'C', '2025-12-16 16:24:59'),
(70, 2, 'easy', 1, 'What is the national language of the Philippines?', 'English', 'Cebuano', 'Filipino', 'Spanish', 'C', '2025-12-16 16:24:59'),
(71, 2, 'easy', 1, 'What is the most widely practiced religion in the Philippines?', 'Islam', 'Roman Catholicism', 'Buddhism', 'Protestantism', 'B', '2025-12-16 16:24:59'),
(72, 2, 'easy', 1, 'What is the famous traditional Filipino boat called?', 'Galleon', 'Bangka', 'Sampan', 'Yacht', 'B', '2025-12-16 16:24:59'),
(73, 2, 'easy', 1, 'What is the most popular Filipino festival celebrated in January in Cebu?', 'Panagbenga', 'Sinulog Festival', 'Ati-Atihan', 'Pahiyas', 'B', '2025-12-16 16:24:59'),
(74, 2, 'easy', 1, 'What is the Filipino term for “thank you”?', 'Salamat', 'Paalam', 'Kamusta', 'Oo', 'A', '2025-12-16 16:24:59'),
(75, 2, 'easy', 1, 'What is the Filipino term for “hello” or “hi”?', 'Kamusta', 'Mabuti', 'Salamat', 'Paumanhin', 'A', '2025-12-16 16:24:59'),
(76, 2, 'easy', 1, 'What is the name of the traditional Filipino house on stilts?', 'Bahay na Bato', 'Nipa Hut', 'Bahay Kubo', 'Longhouse', 'C', '2025-12-16 16:24:59'),
(77, 2, 'easy', 1, 'Which Philippine island is famous for its Chocolate Hills?', 'Palawan', 'Cebu', 'Siargao', 'Bohol', 'D', '2025-12-16 16:24:59'),
(78, 2, 'easy', 1, 'Who is the Philippine national hero?', 'Andres Bonifacio', 'Emilio Aguinaldo', 'Lapu-Lapu', 'Dr. Jose Rizal', 'D', '2025-12-16 16:24:59'),
(79, 2, 'easy', 1, 'What is the traditional Filipino dress for women?', 'Kimono', 'Cheongsam', 'Baro’t Saya', 'Hanbok', 'C', '2025-12-16 16:24:59'),
(80, 2, 'easy', 1, 'What is the traditional Filipino dress for men?', 'Tuxedo', 'Suit', 'Kimono', 'Barong Tagalog', 'D', '2025-12-16 16:24:59'),
(81, 2, 'easy', 1, 'What is the Filipino tradition of visiting relatives and friends during Christmas called?', 'Bayanihan', 'Fiesta', 'Harana', 'Pamamasko', 'D', '2025-12-16 16:24:59'),
(82, 2, 'easy', 1, 'What is the Filipino term for “rice cake”?', 'Tinapay', 'Kanin', 'Pansit', 'Kakanin', 'D', '2025-12-16 16:24:59'),
(83, 2, 'easy', 1, 'Which fruit is considered the “King of Fruits” in the Philippines?', 'Banana', 'Durian', 'Pineapple', 'Mango', 'D', '2025-12-16 16:24:59'),
(84, 2, 'easy', 1, 'What is the Filipino term for respect shown by bringing an elder’s hand to one’s forehead?', 'Pagmamano', 'Pagbati', 'Paggalang', 'Mano Po', 'D', '2025-12-16 16:24:59'),
(85, 2, 'easy', 1, 'Which Philippine city is known as the “Summer Capital”?', 'Tagaytay', 'Manila', 'Vigan', 'Baguio', 'D', '2025-12-16 16:24:59'),
(86, 2, 'easy', 1, 'Which island group is Luzon part of?', 'Visayas', 'Mindanao', 'Palawan', 'Luzon', 'D', '2025-12-16 16:24:59'),
(87, 2, 'easy', 2, 'What is the Filipino word for “family”?', 'Tahanan', 'Bahay', 'Pamilya', 'Kapamilya', 'C', '2025-12-16 16:30:53'),
(88, 2, 'easy', 2, 'What is the famous Filipino dessert made with shaved ice and mixed fruits?', 'Kutsinta', 'Bibingka', 'Leche flan', 'Halo-halo', 'D', '2025-12-16 16:30:53'),
(89, 2, 'easy', 2, 'What is the oldest city in the Philippines?', 'Cebu City', 'Iloilo', 'Vigan', 'Manila', 'C', '2025-12-16 16:30:53'),
(90, 2, 'easy', 2, 'What is the traditional Filipino martial art?', 'Taekwondo', 'Judo', 'Arnis', 'Karate', 'C', '2025-12-16 16:30:53'),
(91, 2, 'easy', 2, 'Which Filipino festival features giant lanterns?', 'Kadayawan', 'Panagbenga', 'Giant Lantern Festival (Ligligan Parul)', 'Sinulog', 'C', '2025-12-16 16:30:53'),
(92, 2, 'easy', 2, 'What is the famous rice terrace complex in Ifugao called?', 'Batad Rice Terraces', 'Banaue Rice Terraces', 'Sagada Rice Terraces', 'Mayoyao Rice Terraces', 'B', '2025-12-16 16:30:53'),
(93, 2, 'easy', 2, 'What is the Filipino term for a communal spirit or helping each other?', 'Kapwa', 'Utang na loob', 'Bayanihan', 'Pakikipagkapwa', 'C', '2025-12-16 16:30:53'),
(94, 2, 'easy', 2, 'What is the largest island in the Philippines?', 'Luzon', 'Palawan', 'Mindanao', 'Samar', 'A', '2025-12-16 16:30:53'),
(95, 2, 'easy', 2, 'What is the name of the Filipino Christmas star-shaped lantern?', 'Parol', 'Belen', 'Christmas Star', 'Ligligan', 'A', '2025-12-16 16:30:53'),
(96, 2, 'easy', 2, 'What is the Filipino term for a wake or vigil for the dead?', 'Libing', 'Lamay', 'Salubong', 'Pista', 'B', '2025-12-16 16:30:53'),
(97, 2, 'easy', 2, 'What is the name of the Philippine national anthem?', 'Lupang Hinirang', 'Awit ng Kabataan', 'Pilipinas Kong Mahal', 'Bayan Ko', 'A', '2025-12-16 16:30:53'),
(98, 2, 'easy', 2, 'What is the Filipino term for the event of moving into a new house?', 'Lipat Bahay', 'Paglipat', 'Bahay Kubo', 'Pabahay', 'A', '2025-12-16 16:30:53'),
(99, 2, 'easy', 2, 'Which Filipino artist is known as the “Father of Philippine Painting”?', 'Carlos “Botong” Francisco', 'Benedicto Cabrera', 'Fernando Amorsolo', 'Juan Luna', 'C', '2025-12-16 16:30:53'),
(100, 2, 'easy', 2, 'What is the name of the largest festival in Davao City?', 'Kadayawan Festival', 'Sinulog', 'Panagbenga', 'Pahiyas', 'A', '2025-12-16 16:30:53'),
(101, 2, 'easy', 2, 'Which Philippine province is famous for the MassKara Festival?', 'Iloilo', 'Negros Occidental (Bacolod City)', 'Pampanga', 'Cebu', 'B', '2025-12-16 16:30:53'),
(102, 2, 'easy', 2, 'What indigenous group is known for tattooing in Kalinga?', 'Igorot', 'Mangyan', 'Ifugao', 'Butbut or the Kalinga people', 'D', '2025-12-16 16:30:53'),
(103, 2, 'easy', 2, 'What is the Filipino value of modesty, or not drawing attention to oneself, called?', 'Hiya', 'Pakikisama', 'Kagandahang-loob', 'Utang na loob', 'A', '2025-12-16 16:30:53'),
(104, 2, 'easy', 2, 'What is the Filipino term for a godparent?', 'Kumare/Kumpare', 'Tiyo/Tiya', 'Ninong/Ninang', 'Ginoo/Ginang', 'C', '2025-12-16 16:30:53'),
(105, 2, 'easy', 2, 'What is the Filipino tradition of serenading called?', 'Harana', 'Kundiman', 'Balagtasan', 'Rondalla', 'A', '2025-12-16 16:30:53'),
(106, 2, 'easy', 2, 'Which Filipino festival is celebrated with colorful masks and street dancing?', 'Pahiyas', 'MassKara Festival', 'Sinulog', 'Ati-Atihan', 'B', '2025-12-16 16:30:53'),
(107, 3, 'easy', 1, 'What is the largest island in the Philippines?', 'Mindanao', 'Palawan', 'Samar', 'Luzon', 'D', '2025-12-16 16:35:47'),
(108, 3, 'easy', 1, 'What is the capital city of the Philippines?', 'Davao', 'Manila', 'Cebu', 'Quezon City', 'B', '2025-12-16 16:35:47'),
(109, 3, 'easy', 1, 'Which region is famous for the Banaue Rice Terraces?', 'Ilocos', 'Cordillera Administrative Region (CAR)', 'Bicol', 'Cagayan Valley', 'B', '2025-12-16 16:35:47'),
(110, 3, 'easy', 1, 'Which Philippine island is known as the “Chocolate Hills” home?', 'Bohol', 'Cebu', 'Leyte', 'Negros', 'A', '2025-12-16 16:35:47'),
(111, 3, 'easy', 1, 'What is the longest river in the Philippines?', 'Pampanga River', 'Cagayan River', 'Agusan River', 'Pasig River', 'B', '2025-12-16 16:35:47'),
(112, 3, 'easy', 1, 'Which Philippine city is called the “Summer Capital”?', 'Baguio', 'Tagaytay', 'Vigan', 'Davao', 'A', '2025-12-16 16:35:47'),
(113, 3, 'easy', 1, 'Which island group is Visayas part of?', 'Visayas', 'Luzon', 'Mindanao', 'Palawan', 'A', '2025-12-16 16:35:47'),
(114, 3, 'easy', 1, 'Which body of water lies to the west of the Philippines?', 'Pacific Ocean', 'South China Sea', 'Celebes Sea', 'Sulu Sea', 'B', '2025-12-16 16:35:47'),
(115, 3, 'easy', 1, 'What is the name of the famous underground river in Palawan?', 'Hinatuan River', 'Cagayan River', 'Puerto Princesa Underground River', 'Loboc River', 'C', '2025-12-16 16:35:47'),
(116, 3, 'easy', 1, 'Which Philippine volcano erupted famously in 1991?', 'Mayon', 'Taal', 'Pinatubo', 'Apo', 'C', '2025-12-16 16:35:47'),
(117, 3, 'easy', 1, 'Which is the smallest province in the Philippines by land area?', 'Batanes', 'Siquijor', 'Camiguin', 'Guimaras', 'A', '2025-12-16 16:35:47'),
(118, 3, 'easy', 1, 'Which is the largest province in the Philippines by land area?', 'Palawan', 'Mindoro', 'Zambales', 'Davao del Sur', 'A', '2025-12-16 16:35:47'),
(119, 3, 'easy', 1, 'Which Philippine city is known as the “Queen City of the South”?', 'Davao', 'Cebu City', 'Iloilo', 'Bacolod', 'B', '2025-12-16 16:35:47'),
(120, 3, 'easy', 1, 'Which Philippine island is home to the famous Mayon Volcano?', 'Luzon', 'Mindoro', 'Mindanao', 'Palawan', 'A', '2025-12-16 16:35:47'),
(121, 3, 'easy', 1, 'What is the capital of the Cordillera Administrative Region (CAR)?', 'Baguio', 'Bontoc', 'Sagada', 'Tabuk', 'B', '2025-12-16 16:35:47'),
(122, 3, 'easy', 1, 'Which Philippine province is known for the Chocolate Hills?', 'Bohol', 'Bohol', 'Negros Occidental', 'Cebu', 'B', '2025-12-16 16:35:47'),
(123, 3, 'easy', 1, 'Which sea lies to the east of the Philippines?', 'Sulu Sea', 'Philippine Sea', 'Celebes Sea', 'South China Sea', 'B', '2025-12-16 16:35:47'),
(124, 3, 'easy', 1, 'Which is the southernmost major island in the Philippines?', 'Luzon', 'Mindanao', 'Palawan', 'Samar', 'B', '2025-12-16 16:35:47'),
(125, 3, 'easy', 1, 'Which island group is the smallest in terms of land area?', 'Luzon', 'Mindanao', 'Visayas', 'Palawan', 'C', '2025-12-16 16:35:47'),
(126, 3, 'easy', 1, 'Which Philippine city is known as the “City of Pines”?', 'Tagaytay', 'Baguio', 'Vigan', 'Davao', 'B', '2025-12-16 16:35:47'),
(127, 3, 'easy', 2, 'What is the largest island in the Philippines?', 'Mindanao', 'Luzon', 'Palawan', 'Samar', 'B', '2025-12-16 16:40:38'),
(128, 3, 'easy', 2, 'Which Philippine city is known as the “Summer Capital”?', 'Manila', 'Tagaytay', 'Baguio', 'Vigan', 'C', '2025-12-16 16:40:38'),
(129, 3, 'easy', 2, 'What is the longest river in the Philippines?', 'Cagayan River', 'Pasig River', 'Agusan River', 'Pampanga River', 'A', '2025-12-16 16:40:38'),
(130, 3, 'easy', 2, 'Which volcano erupted in 1991 causing massive destruction in Luzon?', 'Mayon', 'Pinatubo', 'Taal', 'Bulusan', 'B', '2025-12-16 16:40:38'),
(131, 3, 'easy', 2, 'What is the smallest province in the Philippines by area?', 'Batanes', 'Camiguin', 'Siquijor', 'Dinagat Islands', 'B', '2025-12-16 16:40:38'),
(132, 3, 'easy', 2, 'Which island is famous for the Chocolate Hills?', 'Cebu', 'Palawan', 'Bohol', 'Negros', 'C', '2025-12-16 16:40:38'),
(133, 3, 'easy', 2, 'What body of water separates Luzon from Mindoro?', 'Visayan Sea', 'Sibuyan Sea', 'Mindoro Strait', 'San Juanico Strait', 'C', '2025-12-16 16:40:38'),
(134, 3, 'easy', 2, 'Which Philippine province is known as the “Queen City of the South”?', 'Davao', 'Cebu', 'Iloilo', 'Zamboanga', 'B', '2025-12-16 16:40:38'),
(135, 3, 'easy', 2, 'What is the highest mountain in the Philippines?', 'Mount Apo', 'Mount Pulag', 'Mount Dulang-dulang', 'Mount Kitanglad', 'C', '2025-12-16 16:40:38'),
(136, 3, 'easy', 2, 'Which region is composed of the islands of Leyte, Samar, and Biliran?', 'Eastern Visayas', 'Central Visayas', 'Western Visayas', 'Mimaropa', 'A', '2025-12-16 16:40:38'),
(137, 3, 'easy', 2, 'What is the main river of Mindanao?', 'Pampanga River', 'Agusan River', 'Mindanao River (Rio Grande de Mindanao)', 'Cagayan River', 'C', '2025-12-16 16:40:38'),
(138, 3, 'easy', 2, 'Which strait separates the islands of Panay and Negros?', 'Surigao Strait', 'Guimaras Strait', 'San Juanico Strait', 'Mindoro Strait', 'B', '2025-12-16 16:40:38'),
(139, 3, 'easy', 2, 'Which Philippine island is known for its underground river, a UNESCO World Heritage site?', 'Palawan', 'Cebu', 'Puerto Princesa', 'Mindoro', 'C', '2025-12-16 16:40:38'),
(140, 3, 'easy', 2, 'Which province is famous for Mayon Volcano?', 'Albay', 'Camarines Sur', 'Sorsogon', 'Quezon', 'A', '2025-12-16 16:40:38'),
(141, 3, 'easy', 2, 'What is the largest lake in the Philippines?', 'Laguna de Bay', 'Taal Lake', 'Lake Lanao', 'Lake Sebu', 'C', '2025-12-16 16:40:38'),
(142, 3, 'easy', 2, 'Which Philippine city is known as the “City of Smiles”?', 'Iloilo', 'Bacolod', 'Cebu', 'Davao', 'B', '2025-12-16 16:40:38'),
(143, 3, 'easy', 2, 'Which sea lies to the west of the Philippines?', 'Philippine Sea', 'South China Sea (West Philippine Sea)', 'Celebes Sea', 'Sulu Sea', 'B', '2025-12-16 16:40:38'),
(144, 3, 'easy', 2, 'Which is the northernmost province of the Philippines?', 'Cagayan', 'Batanes', 'Ilocos Norte', 'Apayao', 'B', '2025-12-16 16:40:38'),
(145, 3, 'easy', 2, 'What is the main mountain range in Luzon?', 'Caraballo Mountains', 'Cordillera Central', 'Sierra Madre', 'Zambales Mountains', 'B', '2025-12-16 16:40:38'),
(146, 3, 'easy', 2, 'Which city is the capital of Palawan?', 'Coron', 'Puerto Princesa', 'El Nido', 'Taytay', 'B', '2025-12-16 16:40:38');

-- --------------------------------------------------------

--
-- Table structure for table `quiz_completions`
--

CREATE TABLE `quiz_completions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_email` varchar(255) DEFAULT NULL,
  `category_id` int(11) NOT NULL,
  `difficulty` varchar(20) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `score` int(11) NOT NULL,
  `total_questions` int(11) NOT NULL,
  `percentage` decimal(5,2) NOT NULL,
  `completed_at` datetime DEFAULT current_timestamp(),
  `level_completed` tinyint(1) DEFAULT 0,
  `level_version` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `quiz_completions`
--

INSERT INTO `quiz_completions` (`id`, `user_id`, `user_email`, `category_id`, `difficulty`, `level`, `score`, `total_questions`, `percentage`, `completed_at`, `level_completed`, `level_version`) VALUES
(106, 26, 'andreidolor61@gmail.com', 1, 'hard', NULL, 10, 10, 100.00, '2025-12-13 22:56:35', 0, 1),
(107, 26, 'andreidolor61@gmail.com', 2, 'hard', NULL, 1, 10, 10.00, '2025-12-13 22:57:52', 0, 1),
(108, 26, 'andreidolor61@gmail.com', 1, 'easy', 1, 2, 10, 20.00, '2025-12-13 23:01:41', 0, 1),
(109, 26, 'andreidolor61@gmail.com', 1, 'easy', 2, 2, 3, 66.67, '2025-12-13 23:56:13', 0, 1),
(110, 28, NULL, 1, 'easy', 1, 9, 9, 100.00, '2025-12-15 11:52:29', 1, 1),
(111, 28, NULL, 1, 'hard', NULL, 1, 10, 10.00, '2025-12-15 12:40:20', 0, 1),
(112, 29, NULL, 1, 'easy', 1, 2, 10, 20.00, '2025-12-17 02:29:25', 0, 1),
(113, 30, NULL, 1, 'easy', 1, 1, 10, 10.00, '2025-12-17 01:08:26', 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `quiz_levels`
--

CREATE TABLE `quiz_levels` (
  `id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `difficulty` enum('easy','medium','hard') NOT NULL,
  `level` int(11) DEFAULT NULL,
  `question_limit` int(11) NOT NULL,
  `is_active` tinyint(4) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `quiz_levels`
--

INSERT INTO `quiz_levels` (`id`, `category_id`, `difficulty`, `level`, `question_limit`, `is_active`) VALUES
(1, 1, 'easy', 1, 0, 1),
(2, 1, 'easy', 2, 0, 1),
(3, 1, 'medium', 1, 0, 1),
(4, 1, 'medium', 2, 0, 1),
(5, 1, 'medium', 3, 0, 1),
(6, 2, 'easy', 1, 0, 1),
(7, 2, 'easy', 2, 0, 1),
(8, 2, 'medium', 1, 0, 1),
(9, 2, 'medium', 2, 0, 1),
(10, 2, 'medium', 3, 0, 1),
(11, 3, 'easy', 1, 0, 1),
(12, 3, 'easy', 2, 0, 1),
(13, 3, 'medium', 1, 0, 1),
(14, 3, 'medium', 2, 0, 1),
(15, 3, 'medium', 3, 0, 1),
(16, 1, 'easy', 3, 0, 1),
(17, 1, 'easy', 5, 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `google_id` varchar(255) DEFAULT NULL,
  `picture` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`, `google_id`, `picture`) VALUES
(23, 'ricky', '12345678', NULL, NULL, NULL),
(24, 'elmar', '44444444', NULL, NULL, NULL),
(25, 'vanzy', 'vanzy999', NULL, NULL, NULL),
(26, 'Ross Andrei Dolor', '', 'andreidolor61@gmail.com', '110251024937469890892', 'https://lh3.googleusercontent.com/a/ACg8ocJk-hFy3PIXfRJB3wPmK_xzSIoJRBmQCyVLxkKP8xcoPg_tOOmU=s96-c'),
(27, 'kenzauce', '12345678', NULL, NULL, NULL),
(28, 'jexus', '12345678', NULL, NULL, NULL),
(29, 'elmara', 'elmara123', NULL, NULL, NULL),
(30, 'ddd', 'dddddddd', NULL, NULL, NULL),
(31, 'riki', 'scrypt:32768:8:1$dIc3YsMBGsyDgEnC$d5865099605ddea1d2739c3fc8667db660a5e8438705175a7ec43e59b9f58c6dfaf9be94c738df81dc3df6e814e623d7d7190c5625e840dd9c3fa4fd606ebf35', NULL, NULL, NULL),
(32, 'gilmar', 'scrypt:32768:8:1$aL3RFiaVSbSi3Qr6$b93537c0feab8ec7854aad21d221996439d23de4aa3f35cbe05804b055cfdc79f01ce2bf05e1f02a36f4d70054f0c29c92996eb7409755d3054ea4953db1684e', NULL, NULL, NULL),
(33, 'elmar robles', '', 'elmarrobles76@gmail.com', '111846211714013086961', 'https://lh3.googleusercontent.com/a/ACg8ocIXQJX5uWUBBoSLO6k94_ITpHFBvgNSssrfYw2wghDV7e3ix1c=s96-c');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `leaderboard`
--
ALTER TABLE `leaderboard`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `quiz_completions`
--
ALTER TABLE `quiz_completions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `user_email` (`user_email`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `quiz_levels`
--
ALTER TABLE `quiz_levels`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_level` (`category_id`,`difficulty`,`level`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `google_id` (`google_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `leaderboard`
--
ALTER TABLE `leaderboard`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=148;

--
-- AUTO_INCREMENT for table `quiz_completions`
--
ALTER TABLE `quiz_completions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- AUTO_INCREMENT for table `quiz_levels`
--
ALTER TABLE `quiz_levels`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `questions_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `quiz_completions`
--
ALTER TABLE `quiz_completions`
  ADD CONSTRAINT `quiz_completions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `quiz_completions_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
