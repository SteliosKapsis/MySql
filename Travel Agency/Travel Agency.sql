-- Part A: Database Setup and Creation

-- Drop and Create Database
DROP DATABASE IF EXISTS TravelAgencyDB;
CREATE DATABASE TravelAgencyDB;
USE TravelAgencyDB;

-- Table: Employees
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FullName VARCHAR(100),
    Role ENUM('Guide', 'Admin', 'Analyst'),
    Department ENUM('SALES', 'ACCOUNTING')
);

-- Table: GuidesLanguages
CREATE TABLE GuidesLanguages (
    GuideID INT,
    Language VARCHAR(50),
    PRIMARY KEY (GuideID, Language),
    FOREIGN KEY (GuideID) REFERENCES Employees(EmployeeID)
);

-- Table: Packages
CREATE TABLE Packages (
    PackageID INT PRIMARY KEY,
    StartDate DATE,
    EndDate DATE,
    MaxSeats INT,
    CostPerPerson DECIMAL(10,2),
    TransportMethod ENUM('Bus', 'Plane', 'Ship'),
    GuideID INT,
    Status ENUM('Πλήρες', 'Ανοικτό', 'Κλειστό', 'Ακυρωμένο'),
    Realized BOOLEAN,
    FOREIGN KEY (GuideID) REFERENCES Employees(EmployeeID)
);

-- Table: Destinations
CREATE TABLE Destinations (
    DestinationID INT PRIMARY KEY,
    Name VARCHAR(100),
    Description TEXT,
    Language VARCHAR(50)
);

-- Table: PackageDestinations (Many-to-Many)
CREATE TABLE PackageDestinations (
    PackageID INT,
    DestinationID INT,
    PRIMARY KEY (PackageID, DestinationID),
    FOREIGN KEY (PackageID) REFERENCES Packages(PackageID),
    FOREIGN KEY (DestinationID) REFERENCES Destinations(DestinationID)
);

-- Table: Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(100),
    Address TEXT,
    Phone VARCHAR(20),
    Email VARCHAR(100)
);

-- Table: Bookings
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY,
    PackageID INT,
    CustomerID INT,
    SeatNumber INT,
    FOREIGN KEY (PackageID) REFERENCES Packages(PackageID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Table: PackageCategories (Many-to-Many)
CREATE TABLE PackageCategories (
    PackageID INT,
    Category ENUM('Romantic', 'Winter', 'Summer'),
    PRIMARY KEY (PackageID, Category),
    FOREIGN KEY (PackageID) REFERENCES Packages(PackageID)
);

-- Table: SalesTracking
CREATE TABLE SalesTracking (
    PackageID INT PRIMARY KEY,
    BookingCount INT,
    TotalCost DECIMAL(10,2),
    AvailableSeats INT,
    FOREIGN KEY (PackageID) REFERENCES Packages(PackageID)
);

-- Table: PackageReviews
CREATE TABLE PackageReviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    BookingID INT,
    PackageID INT,
    Rating INT,
    Comment TEXT,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID),
    FOREIGN KEY (PackageID) REFERENCES Packages(PackageID),
    UNIQUE (BookingID, PackageID) -- Ensure one review per booking
);

-- Part A: Sample Data Inserts

-- Employees
INSERT INTO Employees (EmployeeID, FullName, Role, Department) VALUES 
(1, 'John Doe', 'Guide', 'SALES'),
(2, 'Jane Smith', 'Admin', 'ACCOUNTING'),
(3, 'Alex Brown', 'Analyst', NULL);

-- Guides Languages
INSERT INTO GuidesLanguages (GuideID, Language) VALUES 
(1, 'English'),
(1, 'Greek');

-- Packages
INSERT INTO Packages (PackageID, StartDate, EndDate, MaxSeats, CostPerPerson, TransportMethod, GuideID, Status, Realized) VALUES 
(101, '2025-06-01', '2025-06-10', 50, 800.00, 'Bus', 1, 'Ανοικτό', TRUE),
(102, '2025-07-01', '2025-07-15', 40, 1200.00, 'Plane', 1, 'Ανοικτό', FALSE),
(103, '2025-08-01', '2025-08-10', 60, 700.00, 'Ship', 1, 'Κλειστό', TRUE);

-- Destinations
INSERT INTO Destinations (DestinationID, Name, Description, Language) VALUES 
(201, 'Santorini', 'Beautiful Greek island with blue domes', 'Greek'),
(202, 'Athens', 'Capital of Greece with rich history', 'Greek'),
(203, 'Crete', 'Largest Greek island known for its beaches', 'Greek');

-- Package Destinations
INSERT INTO PackageDestinations (PackageID, DestinationID) VALUES 
(101, 201),
(102, 202),
(103, 203);

-- Customers
INSERT INTO Customers (CustomerID, FullName, Address, Phone, Email) VALUES 
(301, 'Alice Wonderland', '123 Fantasy Lane', '1234567890', 'alice@example.com'),
(302, 'Bob Builder', '456 Construction Ave', '0987654321', 'bob@example.com'),
(303, 'Charlie Brown', '789 Peanuts St', '1122334455', 'charlie@example.com');

-- Bookings
INSERT INTO Bookings (BookingID, PackageID, CustomerID, SeatNumber) VALUES 
(401, 101, 301, 1),
(402, 102, 302, 2),
(403, 103, 303, 3);

-- Package Categories
INSERT INTO PackageCategories (PackageID, Category) VALUES 
(101, 'Romantic'),
(102, 'Summer'),
(103, 'Winter');

-- Package Reviews
INSERT INTO PackageReviews (BookingID, PackageID, Rating, Comment) VALUES 
(401, 101, 5, 'Amazing experience!'),
(402, 102, 4, 'Very enjoyable but a bit pricey.'),
(403, 103, 3, 'Good trip but could be improved.');

-- Part B: Queries

-- Most Popular Destination
SELECT D.DestinationID, D.Name, COUNT(*) AS BookingCount
FROM Bookings B
JOIN PackageDestinations PD ON B.PackageID = PD.PackageID
JOIN Destinations D ON PD.DestinationID = D.DestinationID
GROUP BY D.DestinationID, D.Name
ORDER BY BookingCount DESC
LIMIT 1;

-- Detailed Package Description
SELECT P.PackageID, 
       GROUP_CONCAT(D.Name SEPARATOR ', ') AS Destinations,
       GROUP_CONCAT(D.Description SEPARATOR ', ') AS Descriptions,
       GROUP_CONCAT(D.Language SEPARATOR ', ') AS Languages,
       P.TransportMethod, P.CostPerPerson, P.StartDate, P.EndDate, 
       E.FullName AS Guide, P.MaxSeats, GROUP_CONCAT(PC.Category SEPARATOR ', ') AS Categories
FROM Packages P
JOIN PackageDestinations PD ON P.PackageID = PD.PackageID
JOIN Destinations D ON PD.DestinationID = D.DestinationID
JOIN Employees E ON P.GuideID = E.EmployeeID
JOIN PackageCategories PC ON P.PackageID = PC.PackageID
GROUP BY P.PackageID;

-- Total Revenue per Package
SELECT P.PackageID, IFNULL(P.CostPerPerson * COUNT(B.BookingID), 0) AS TotalRevenue
FROM Packages P
LEFT JOIN Bookings B ON P.PackageID = B.PackageID
GROUP BY P.PackageID;

-- Packages Managed by Each Employee
SELECT E.FullName, P.PackageID, P.Status
FROM Employees E
JOIN Packages P ON E.EmployeeID = P.GuideID
WHERE E.Role = 'Guide';

-- Customer with Most Bookings
SELECT C.FullName, COUNT(*) AS BookingCount
FROM Customers C
JOIN Bookings B ON C.CustomerID = B.CustomerID
GROUP BY C.FullName
ORDER BY BookingCount DESC
LIMIT 1;

-- Part C: Procedures

-- Procedure: Add a Package Review
DELIMITER //
CREATE PROCEDURE AddPackageReview(IN BookingID INT, IN Rating INT, IN Comment TEXT)
BEGIN
    DECLARE PackageID INT;
    SELECT PackageID INTO PackageID FROM Bookings WHERE BookingID = BookingID;
    IF PackageID IS NOT NULL THEN
        INSERT INTO PackageReviews (BookingID, PackageID, Rating, Comment)
        VALUES (BookingID, PackageID, Rating, Comment);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid BookingID';
    END IF;
END //
DELIMITER ;

-- Example: Add a Review
CALL AddPackageReview(401, 4, 'Wonderful guide and locations!');

-- Procedure: Generate Passenger List
DELIMITER //
CREATE PROCEDURE GeneratePassengerList(IN PackageID INT)
BEGIN
    SELECT C.FullName, P.StartDate, E.FullName AS Guide
    FROM Bookings B
    JOIN Customers C ON B.CustomerID = C.CustomerID
    JOIN Packages P ON B.PackageID = P.PackageID
    JOIN Employees E ON P.GuideID = E.EmployeeID
    WHERE P.PackageID = PackageID;
END //
DELIMITER ;

-- Example: Generate Passenger List
CALL GeneratePassengerList(101);

-- Part D: Triggers for Sales Tracking

-- Trigger: After Insert on Bookings
DELIMITER //
CREATE TRIGGER UpdateSalesTrackingAfterInsert
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    DECLARE TotalBookings INT DEFAULT 0;
    DECLARE TotalRevenue DECIMAL(10,2) DEFAULT 0.00;
    DECLARE SeatsAvailable INT DEFAULT 0;

    SELECT COUNT(B.BookingID), 
           SUM(P.CostPerPerson), 
           P.MaxSeats - COUNT(B.BookingID)
    INTO TotalBookings, TotalRevenue, SeatsAvailable
    FROM Packages P
    LEFT JOIN Bookings B ON P.PackageID = B.PackageID
    WHERE P.PackageID = NEW.PackageID
    GROUP BY P.PackageID;

    INSERT INTO SalesTracking (PackageID, BookingCount, TotalCost, AvailableSeats)
    VALUES (NEW.PackageID, TotalBookings, TotalRevenue, SeatsAvailable)
    ON DUPLICATE KEY UPDATE
        BookingCount = TotalBookings,
        TotalCost = TotalRevenue,
        AvailableSeats = SeatsAvailable;
END //
DELIMITER ;

-- Trigger: After Update on Bookings
DELIMITER //
CREATE TRIGGER UpdateSalesTrackingAfterUpdate
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    DECLARE TotalBookings INT DEFAULT 0;
    DECLARE TotalRevenue DECIMAL(10,2) DEFAULT 0.00;
    DECLARE SeatsAvailable INT DEFAULT 0;

    SELECT COUNT(B.BookingID), 
           SUM(P.CostPerPerson), 
           P.MaxSeats - COUNT(B.BookingID)
    INTO TotalBookings, TotalRevenue, SeatsAvailable
    FROM Packages P
    LEFT JOIN Bookings B ON P.PackageID = B.PackageID
    WHERE P.PackageID = NEW.PackageID
    GROUP BY P.PackageID;

    INSERT INTO SalesTracking (PackageID, BookingCount, TotalCost, AvailableSeats)
    VALUES (NEW.PackageID, TotalBookings, TotalRevenue, SeatsAvailable)
    ON DUPLICATE KEY UPDATE
        BookingCount = TotalBookings,
        TotalCost = TotalRevenue,
        AvailableSeats = SeatsAvailable;
END //
DELIMITER ;

-- Trigger: After Delete on Bookings
DELIMITER //
CREATE TRIGGER UpdateSalesTrackingAfterDelete
AFTER DELETE ON Bookings
FOR EACH ROW
BEGIN
    DECLARE TotalBookings INT DEFAULT 0;
    DECLARE TotalRevenue DECIMAL(10,2) DEFAULT 0.00;
    DECLARE SeatsAvailable INT DEFAULT 0;

    SELECT COUNT(B.BookingID), 
           SUM(P.CostPerPerson), 
           P.MaxSeats - COUNT(B.BookingID)
    INTO TotalBookings, TotalRevenue, SeatsAvailable
    FROM Packages P
    LEFT JOIN Bookings B ON P.PackageID = B.PackageID
    WHERE P.PackageID = OLD.PackageID
    GROUP BY P.PackageID;

    INSERT INTO SalesTracking (PackageID, BookingCount, TotalCost, AvailableSeats)
    VALUES (OLD.PackageID, TotalBookings, TotalRevenue, SeatsAvailable)
    ON DUPLICATE KEY UPDATE
        BookingCount = TotalBookings,
        TotalCost = TotalRevenue,
        AvailableSeats = SeatsAvailable;
END //
DELIMITER ;

-- Test Trigger
INSERT INTO Bookings (BookingID, PackageID, CustomerID, SeatNumber) 
VALUES (404, 101, 302, 2);

-- View SalesTracking Table
SELECT * FROM SalesTracking;