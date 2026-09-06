-- =========================================
-- MINI LIBRARY MANAGEMENT SYSTEM
-- =========================================

-- Create Database
CREATE DATABASE LibraryDB;
GO

-- Select Database
USE LibraryDB;
GO


-- =========================================
-- 1. CREATE TABLES
-- =========================================

-- Author table stores author information
CREATE TABLE Author
(
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    AuthorName VARCHAR(100) NOT NULL UNIQUE
);

-- Category table stores book categories
CREATE TABLE Category
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE
);

-- Book table stores book information
CREATE TABLE Book
(
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    Title VARCHAR(150) NOT NULL,
    ISBN VARCHAR(20) NOT NULL UNIQUE,
    Availability BIT NOT NULL DEFAULT 1,
    AuthorID INT NOT NULL,
    CategoryID INT NOT NULL,

    -- Foreign keys maintain relationships between tables
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

-- Member table stores library member information
CREATE TABLE Member
(
    MemberID INT IDENTITY(1,1) PRIMARY KEY,
    MemberName VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Contact VARCHAR(20) NOT NULL UNIQUE
);

-- Book_Issue table stores issue and return records
CREATE TABLE Book_Issue
(
    IssueID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    IssueDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE NULL,
    Fine DECIMAL(10,2) DEFAULT 0,

    FOREIGN KEY (BookID) REFERENCES Book(BookID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),

    -- Due date cannot be before issue date
    CHECK (DueDate >= IssueDate),

    -- Fine cannot be negative
    CHECK (Fine >= 0)
);
GO


-- =========================================
-- 2. INSERT SAMPLE DATA
-- =========================================

-- Insert authors
INSERT INTO Author (AuthorName)
VALUES
('Umera Ahmed'),
('Nemrah Ahmed'),
('Bano Qudsia'),
('Qudrat Ullah Shahab'),
('Mustansar Hussain Tarar'),
('Hashim Nadeem'),
('Ashfaq Ahmed');

-- Insert book categories
INSERT INTO Category (CategoryName)
VALUES
('Urdu Novel'),
('Autobiography'),
('Urdu Literature'),
('Essays'),
('Spiritual Fiction');

-- Insert books
INSERT INTO Book
(Title, ISBN, Availability, AuthorID, CategoryID)
VALUES
('Aab-e-Hayat','ISBN001',1,1,1),
('Amar Bail','ISBN002',1,1,1),
('Man-o-Salwa','ISBN003',1,1,1),
('Jannat Kay Pattay','ISBN004',1,2,1),
('Raja Gidh','ISBN005',1,3,1),
('Shahab Nama','ISBN006',1,4,2),
('Bahao','ISBN007',1,5,1),
('Raakh','ISBN008',1,6,1),
('Khuda Aur Mohabbat','ISBN009',1,6,5),
('Zaviya','ISBN010',1,7,4);

-- Insert library members
INSERT INTO Member
(MemberName, Address, Contact)
VALUES
('Anam Nazir','Karachi, Pakistan','03001234567'),
('Akash Aslam','Karachi, Pakistan','03011234567'),
('Ayesha Malik','Islamabad, Pakistan','03121234567'),
('Ahmed Raza','Rawalpindi, Pakistan','03221234567'),
('Hamza Ali','Karachi, Pakistan','03331234567');
GO


-- =========================================
-- 3. SEARCH, FILTER, UPDATE & DELETE
-- =========================================

-- Display all books
SELECT * FROM Book;

-- Display all members
SELECT * FROM Member;

-- Search books by title
SELECT * FROM Book
WHERE Title LIKE '%Hayat%';

-- Display only available books
SELECT * FROM Book
WHERE Availability = 1
ORDER BY Title ASC;

-- Update member address
UPDATE Member
SET Address = 'Karachi, Pakistan'
WHERE MemberID = 1;

-- Insert a temporary member for DELETE operation
INSERT INTO Member
(MemberName, Address, Contact)
VALUES
('Test Member','Karachi','03441234567');

-- Delete temporary member
DELETE FROM Member
WHERE MemberName = 'Test Member';

-- Count total books
SELECT COUNT(*) AS TotalBooks
FROM Book;

-- Count books according to category
SELECT CategoryID, COUNT(*) AS TotalBooks
FROM Book
GROUP BY CategoryID;
GO


-- =========================================
-- 4. ISSUE, RETURN & REPORTS
-- =========================================

-- Issue books to members
INSERT INTO Book_Issue
(BookID, MemberID, IssueDate, DueDate)
VALUES
(1,1,'2026-09-01','2026-09-15'),
(2,2,'2026-08-20','2026-09-03'),
(3,4,'2026-08-25','2026-09-05'),
(4,3,'2026-08-01','2026-08-15');

-- Mark issued books as unavailable
UPDATE Book
SET Availability = 0
WHERE BookID IN (1,2,3,4);

-- Return a book and record its fine
UPDATE Book_Issue
SET ReturnDate = '2026-09-06',
    Fine = 50
WHERE IssueID = 4;

-- Make the returned book available again
UPDATE Book
SET Availability = 1
WHERE BookID = 4;

-- Report: currently issued books
SELECT
    B.Title,
    M.MemberName,
    I.IssueDate,
    I.DueDate
FROM Book_Issue I
JOIN Book B ON I.BookID = B.BookID
JOIN Member M ON I.MemberID = M.MemberID
WHERE I.ReturnDate IS NULL;

-- Report: overdue books
SELECT
    B.Title,
    M.MemberName,
    I.DueDate
FROM Book_Issue I
JOIN Book B ON I.BookID = B.BookID
JOIN Member M ON I.MemberID = M.MemberID
WHERE I.ReturnDate IS NULL
AND I.DueDate < GETDATE();

-- Report: member-wise issue history
SELECT
    M.MemberName,
    B.Title,
    I.IssueDate,
    I.DueDate,
    I.ReturnDate,
    I.Fine
FROM Book_Issue I
JOIN Member M ON I.MemberID = M.MemberID
JOIN Book B ON I.BookID = B.BookID
ORDER BY M.MemberName;
GO


-- =========================================
-- 5. REQUIRED VIEWS
-- =========================================

-- View for available books
CREATE VIEW AvailableBooks AS
SELECT
    B.BookID,
    B.Title,
    A.AuthorName,
    C.CategoryName
FROM Book B
JOIN Author A ON B.AuthorID = A.AuthorID
JOIN Category C ON B.CategoryID = C.CategoryID
WHERE B.Availability = 1;
GO

-- View for overdue books
CREATE VIEW OverdueBooks AS
SELECT
    B.Title,
    M.MemberName,
    I.DueDate
FROM Book_Issue I
JOIN Book B ON I.BookID = B.BookID
JOIN Member M ON I.MemberID = M.MemberID
WHERE I.ReturnDate IS NULL
AND I.DueDate < GETDATE();
GO

-- Display view results
SELECT * FROM AvailableBooks;
SELECT * FROM OverdueBooks;
GO
