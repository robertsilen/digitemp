-- MySQL dump 9.11
--
-- Host: localhost    Database: digitemp
-- ------------------------------------------------------
-- Server version	4.0.24_Debian-10sarge1-log

--
-- Table structure for table `Location`
--

CREATE TABLE `Location` (
  `LocationID` int(11) NOT NULL default '0',
  `SensorID` int(11) NOT NULL default '0',
  `Description` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`LocationID`),
  KEY `sensor_key` (`SensorID`)
) TYPE=MyISAM;

--
-- Dumping data for table `Location`
--

INSERT INTO `Location` VALUES (1,1,'Tyhuone');

--
-- Table structure for table `Sensor`
--

CREATE TABLE `Sensor` (
  `SensorID` int(11) NOT NULL auto_increment,
  `SensorTypeID` varchar(15) NOT NULL default '',
  `SerialNumber` varchar(17) NOT NULL default '',
  `Description` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`SensorID`),
  KEY `type_key` (`SensorTypeID`),
  KEY `serial_key` (`SerialNumber`)
) TYPE=MyISAM;

--
-- Dumping data for table `Sensor`
--

INSERT INTO `Sensor` VALUES (1,'DS18S20','10A6879F00080082','Bought in 2003 or 2004.');

--
-- Table structure for table `SensorType`
--

CREATE TABLE `SensorType` (
  `SensorTypeID` varchar(15) NOT NULL default '',
  `Description` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`SensorTypeID`)
) TYPE=MyISAM;

--
-- Dumping data for table `SensorType`
--

INSERT INTO `SensorType` VALUES ('DS18S20','Unique 1-Wire interface requires only one port pin for communication. Each device has a unique 64-bit serial code stored in an onboard ROM. Multidrop capability simplifies distributed temperature sensing applications. Requires no external components. Can');

--
-- Table structure for table `Temperature`
--

CREATE TABLE `Temperature` (
  `TemperatureID` int(11) NOT NULL auto_increment,
  `Time` timestamp(14) NOT NULL,
  `SensorID` int(11) NOT NULL default '0',
  `LocationID` int(11) NOT NULL default '0',
  `Temperature` decimal(6,2) NOT NULL default '0.00',
  PRIMARY KEY  (`TemperatureID`),
  KEY `serial_key` (`SensorID`),
  KEY `location_key` (`LocationID`),
  KEY `time_key` (`Time`)
) TYPE=MyISAM;

--
-- Dumping data for table `Temperature`
--

INSERT INTO `Temperature` VALUES (1,20051103152322,1,1,'24.38');
INSERT INTO `Temperature` VALUES (2,20051103152348,1,1,'24.38');
INSERT INTO `Temperature` VALUES (3,20051103152429,1,1,'24.44');
INSERT INTO `Temperature` VALUES (4,20051103152433,1,1,'24.44');
INSERT INTO `Temperature` VALUES (5,20051103152436,1,1,'24.38');
INSERT INTO `Temperature` VALUES (6,20051103153002,1,1,'24.38');
INSERT INTO `Temperature` VALUES (7,20051103153503,1,1,'24.31');
INSERT INTO `Temperature` VALUES (8,20051103154003,1,1,'24.31');
INSERT INTO `Temperature` VALUES (9,20051103154503,1,1,'24.25');
INSERT INTO `Temperature` VALUES (10,20051103155003,1,1,'24.25');
INSERT INTO `Temperature` VALUES (11,20051103155502,1,1,'24.19');
INSERT INTO `Temperature` VALUES (12,20051103160003,1,1,'24.19');
INSERT INTO `Temperature` VALUES (13,20051103160503,1,1,'24.19');
INSERT INTO `Temperature` VALUES (14,20051103161003,1,1,'24.12');
INSERT INTO `Temperature` VALUES (15,20051103161503,1,1,'24.12');
INSERT INTO `Temperature` VALUES (16,20051103162003,1,1,'24.06');
INSERT INTO `Temperature` VALUES (17,20051103162502,1,1,'24.12');
INSERT INTO `Temperature` VALUES (18,20051103163003,1,1,'24.19');
INSERT INTO `Temperature` VALUES (19,20051103163503,1,1,'24.19');
INSERT INTO `Temperature` VALUES (20,20051103164003,1,1,'24.25');
INSERT INTO `Temperature` VALUES (21,20051103164503,1,1,'24.31');
INSERT INTO `Temperature` VALUES (22,20051103165002,1,1,'24.31');
INSERT INTO `Temperature` VALUES (23,20051103165502,1,1,'24.31');

