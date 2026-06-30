
CREATE DATABASE BookStoreDB;
GO
USE BookStoreDB;
GO

-- 1. Tables
CREATE TABLE Categories(
 CategoryID INT IDENTITY PRIMARY KEY,
 CategoryName NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Authors(
 AuthorID INT IDENTITY PRIMARY KEY,
 FullName NVARCHAR(150) NOT NULL
);

CREATE TABLE Customers(
 CustomerID INT IDENTITY PRIMARY KEY,
 FullName NVARCHAR(150),
 Email NVARCHAR(150) UNIQUE NOT NULL,
 City NVARCHAR(100)
);

CREATE TABLE Books(
 BookID INT IDENTITY PRIMARY KEY,
 Title NVARCHAR(200) NOT NULL,
 AuthorID INT NOT NULL,
 CategoryID INT NOT NULL,
 Price DECIMAL(10,2) CHECK(Price>0),
 Stock INT CHECK(Stock>=0),
 IsActive BIT DEFAULT 1,
 FOREIGN KEY(AuthorID) REFERENCES Authors(AuthorID),
 FOREIGN KEY(CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Orders(
 OrderID INT IDENTITY PRIMARY KEY,
 CustomerID INT NOT NULL,
 OrderDate DATE DEFAULT GETDATE(),
 FOREIGN KEY(CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails(
 OrderDetailID INT IDENTITY PRIMARY KEY,
 OrderID INT NOT NULL,
 BookID INT NULL,
 Quantity INT CHECK(Quantity>0),
 UnitPrice DECIMAL(10,2) CHECK(UnitPrice>0),
 FOREIGN KEY(OrderID) REFERENCES Orders(OrderID),
 FOREIGN KEY(BookID) REFERENCES Books(BookID)
);

-- 2. Sample Data
INSERT INTO Categories VALUES
('Programming'),('Database'),('Science'),('History'),('Fiction'),('Business');

INSERT INTO Authors VALUES
('Robert Martin'),('Martin Fowler'),('Elmasri'),('Isaac Asimov'),
('Yuval Noah Harari'),('James Clear'),('Andrew Hunt');

INSERT INTO Customers VALUES
('Mostafa','mostafa@mail.com','Port Said'),
('Ali','ali@mail.com','Cairo'),
('Sara','sara@mail.com','Alex'),
('Mona','mona@mail.com','Cairo'),
('Omar','omar@mail.com','Giza'),
('Laila','laila@mail.com','Port Said');

INSERT INTO Books(Title,AuthorID,CategoryID,Price,Stock) VALUES
('Clean Code',1,1,50,10),
('Refactoring',2,1,60,5),
('Database Systems',3,2,70,3),
('Foundation',4,5,40,15),
('Sapiens',5,4,45,8),
('Atomic Habits',6,6,55,20),
('Pragmatic Programmer',7,1,65,7);

INSERT INTO Orders(CustomerID,OrderDate) VALUES
(1,'2026-01-10'),
(2,'2026-01-15'),
(1,'2026-02-01'),
(3,'2026-02-12'),
(5,'2026-03-10');

INSERT INTO OrderDetails(OrderID,BookID,Quantity,UnitPrice) VALUES
(1,1,1,50),
(1,4,2,40),
(2,2,1,60),
(2,3,1,70),
(3,6,2,55),
(4,5,1,45),
(5,1,3,50),
(5,7,1,65);

--3
SELECT * FROM Books ORDER BY Price DESC;

--4
SELECT UPPER(B.Title) AS BookTitle,
LOWER(A.FullName) AS AuthorName
FROM Books B JOIN Authors A ON B.AuthorID=A.AuthorID;

--5
SELECT B.Title,C.CategoryName,A.FullName
FROM Books B
JOIN Categories C ON B.CategoryID=C.CategoryID
JOIN Authors A ON B.AuthorID=A.AuthorID;

--6
SELECT C.FullName,COUNT(O.OrderID) Purchases
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID=O.CustomerID
GROUP BY C.FullName;

--7
SELECT TOP 5 B.Title,SUM(OD.Quantity) Sold
FROM OrderDetails OD
JOIN Books B ON OD.BookID=B.BookID
GROUP BY B.Title
ORDER BY Sold DESC;

--8
SELECT TOP 1 City,COUNT(*) Customers
FROM Customers
GROUP BY City
ORDER BY Customers DESC;

--9
SELECT C.CategoryName
FROM Categories C
JOIN Books B ON C.CategoryID=B.CategoryID
GROUP BY C.CategoryName
HAVING COUNT(*)>5;

--10
SELECT * FROM Books
WHERE Price>(SELECT AVG(Price) FROM Books);

--11
SELECT C.*
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID=O.CustomerID
WHERE O.OrderID IS NULL;

--12
SELECT YEAR(OrderDate) Y,MONTH(OrderDate) M,
SUM(OD.Quantity*OD.UnitPrice) Revenue
FROM Orders O
JOIN OrderDetails OD ON O.OrderID=OD.OrderID
GROUP BY YEAR(OrderDate),MONTH(OrderDate);

--13
CREATE VIEW vw_BookInfo AS
SELECT B.Title,C.CategoryName,A.FullName AS Author,B.Price
FROM Books B
JOIN Categories C ON B.CategoryID=C.CategoryID
JOIN Authors A ON B.AuthorID=A.AuthorID;

--14
GO
CREATE PROCEDURE GetCustomerPurchases
@CustomerID INT
AS
BEGIN
SELECT O.OrderID,O.OrderDate,
B.Title,OD.Quantity,OD.UnitPrice,
OD.Quantity*OD.UnitPrice AS Total
FROM Orders O
JOIN OrderDetails OD ON O.OrderID=OD.OrderID
JOIN Books B ON OD.BookID=B.BookID
WHERE O.CustomerID=@CustomerID;
END;
GO

EXEC GetCustomerPurchases 1;
