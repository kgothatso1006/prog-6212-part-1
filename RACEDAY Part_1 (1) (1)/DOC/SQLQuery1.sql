/*
 RaceDay System - SQL Server Database Script
 Part 1, Section C
 Run this script on a clean SQL Server instance in SSMS.
*/

IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

-- Drop tables in dependency order so the script can be re-run during testing.
DROP TABLE IF EXISTS Results;
DROP TABLE IF EXISTS Enrolments;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Participants;
DROP TABLE IF EXISTS Organisers;
DROP TABLE IF EXISTS Users;
GO

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) CONSTRAINT PK_Users PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(150) NOT NULL CONSTRAINT UQ_Users_Email UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(30) NULL,
    Role NVARCHAR(20) NOT NULL CONSTRAINT CK_Users_Role CHECK (Role IN ('Organiser','Participant')),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT SYSDATETIME()
);
GO

CREATE TABLE Organisers (
    OrganiserID INT IDENTITY(1,1) CONSTRAINT PK_Organisers PRIMARY KEY,
    UserID INT NOT NULL CONSTRAINT UQ_Organisers_UserID UNIQUE,
    OrganisationName NVARCHAR(150) NOT NULL,
    CONSTRAINT FK_Organisers_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

CREATE TABLE Participants (
    ParticipantID INT IDENTITY(1,1) CONSTRAINT PK_Participants PRIMARY KEY,
    UserID INT NOT NULL CONSTRAINT UQ_Participants_UserID UNIQUE,
    DateOfBirth DATE NULL,
    EmergencyContact NVARCHAR(100) NULL,
    EmergencyPhone NVARCHAR(30) NULL,
    CONSTRAINT FK_Participants_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

CREATE TABLE Events (
    EventID INT IDENTITY(1,1) CONSTRAINT PK_Events PRIMARY KEY,
    OrganiserID INT NOT NULL,
    EventName NVARCHAR(150) NOT NULL,
    Description NVARCHAR(1000) NULL,
    EventDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    Venue NVARCHAR(200) NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Events_Status DEFAULT 'Upcoming',
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Events_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Events_Status CHECK (Status IN ('Upcoming','Open','Completed','Cancelled')),
    CONSTRAINT FK_Events_Organisers FOREIGN KEY (OrganiserID) REFERENCES Organisers(OrganiserID)
);
GO

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) CONSTRAINT PK_Categories PRIMARY KEY,
    EventID INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    DistanceKm DECIMAL(5,2) NOT NULL,
    MaxParticipants INT NOT NULL CONSTRAINT DF_Categories_MaxParticipants DEFAULT 100,
    EntryFee DECIMAL(10,2) NOT NULL CONSTRAINT DF_Categories_EntryFee DEFAULT 0.00,
    CONSTRAINT CK_Categories_Distance CHECK (DistanceKm > 0),
    CONSTRAINT CK_Categories_MaxParticipants CHECK (MaxParticipants > 0),
    CONSTRAINT CK_Categories_EntryFee CHECK (EntryFee >= 0),
    CONSTRAINT UQ_Categories_Event_Name UNIQUE (EventID, CategoryName),
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID) REFERENCES Events(EventID)
);
GO

CREATE TABLE Enrolments (
    EnrolmentID INT IDENTITY(1,1) CONSTRAINT PK_Enrolments PRIMARY KEY,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME2 NOT NULL CONSTRAINT DF_Enrolments_EnrolmentDate DEFAULT SYSDATETIME(),
    EnrolmentStatus NVARCHAR(20) NOT NULL CONSTRAINT DF_Enrolments_Status DEFAULT 'Registered',
    RaceNumber NVARCHAR(20) NULL,
    CONSTRAINT CK_Enrolments_Status CHECK (EnrolmentStatus IN ('Registered','Cancelled','Completed')),
    CONSTRAINT UQ_Enrolments_Participant_Category UNIQUE (ParticipantID, CategoryID),
    CONSTRAINT UQ_Enrolments_RaceNumber UNIQUE (RaceNumber),
    CONSTRAINT FK_Enrolments_Participants FOREIGN KEY (ParticipantID) REFERENCES Participants(ParticipantID),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) CONSTRAINT PK_Results PRIMARY KEY,
    EnrolmentID INT NOT NULL CONSTRAINT UQ_Results_Enrolment UNIQUE,
    FinishTime TIME NULL,
    Position INT NULL,
    ResultStatus NVARCHAR(20) NOT NULL CONSTRAINT DF_Results_Status DEFAULT 'Finished',
    RecordedAt DATETIME2 NOT NULL CONSTRAINT DF_Results_RecordedAt DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Results_Position CHECK (Position IS NULL OR Position > 0),
    CONSTRAINT CK_Results_Status CHECK (ResultStatus IN ('Finished','DidNotFinish','Disqualified')),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentID) REFERENCES Enrolments(EnrolmentID)
);
GO

-- Seed data: 2 organisers, 2 participants, 3 events, categories for each event,
-- and sample enrolments/results.
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, Phone, Role)
VALUES
('Thabo','Mokoena','thabo@raceday.co.za','HASHED_PASSWORD_1','0821112233','Organiser'),
('Lerato','Maseko','lerato@raceday.co.za','HASHED_PASSWORD_2','0832223344','Organiser'),
('Rich','Ringane','rich@example.com','HASHED_PASSWORD_3','0843334455','Participant'),
('Kabelo','Ndlovu','kabelo@example.com','HASHED_PASSWORD_4','0854445566','Participant');
GO

INSERT INTO Organisers (UserID, OrganisationName)
VALUES
(1,'Limpopo Race Events'),
(2,'Makhado Sports Management');
GO

INSERT INTO Participants (UserID, DateOfBirth, EmergencyContact, EmergencyPhone)
VALUES
(3,'2005-04-15','Mpho Ringane','0715556677'),
(4,'2004-09-22','Neo Ndlovu','0726667788');
GO

INSERT INTO Events
(OrganiserID, EventName, Description, EventDate, StartTime, Venue, Location, Status)
VALUES
(1,'Limpopo Spring Run','Community road running event with multiple race categories.','2026-09-20','07:00','Polokwane Sports Complex','Polokwane, Limpopo','Open'),
(1,'Makhado Heritage Marathon','Annual marathon celebrating sport and local heritage.','2026-10-18','06:30','Makhado Show Grounds','Makhado, Limpopo','Upcoming'),
(2,'Thohoyandou Charity Race','Charity race supporting youth development initiatives.','2026-11-08','07:30','Thohoyandou Stadium','Thohoyandou, Limpopo','Upcoming');
GO

INSERT INTO Categories (EventID, CategoryName, DistanceKm, MaxParticipants, EntryFee)
VALUES
(1,'5 km Fun Run',5.00,300,80.00),
(1,'10 km Challenge',10.00,250,120.00),
(2,'21 km Half Marathon',21.10,500,220.00),
(2,'42 km Marathon',42.20,600,350.00),
(3,'5 km Charity Run',5.00,400,60.00),
(3,'10 km Charity Challenge',10.00,300,100.00);
GO

INSERT INTO Enrolments
(ParticipantID, CategoryID, EnrolmentDate, EnrolmentStatus, RaceNumber)
VALUES
(1,1,'2026-08-01T09:00:00','Registered','LR001'),
(1,3,'2026-08-05T10:30:00','Registered','MH001'),
(2,2,'2026-08-03T11:15:00','Registered','LR002'),
(2,5,'2026-08-10T14:00:00','Registered','TC001');
GO

INSERT INTO Results (EnrolmentID, FinishTime, Position, ResultStatus)
VALUES
(1,'00:31:42',12,'Finished'),
(3,'00:55:18',8,'Finished');
GO

-- Verification queries
SELECT * FROM Users;
SELECT * FROM Organisers;
SELECT * FROM Participants;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM Enrolments;
SELECT * FROM Results;
GO
