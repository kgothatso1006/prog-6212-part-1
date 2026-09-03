# prog-6212-part-1
Programming 6212 – Part 1 assignment project.
# RaceDay – Part 1 Planning Documents

## Folder Contents

This folder contains the planning and database documents for Part 1 of the RaceDay System:

- **RaceDay_ERD.pdf** – Entity Relationship Diagram (ERD).
- **RaceDay_ERD.png** – PNG version of the ERD.
- **RaceDay_API_Endpoint_Plan.md** – REST API endpoint plan.
- **RaceDay_Database.sql** – SQL Server database schema, constraints and sample seed data.

## ERD and SQL Consistency

The ERD contains seven entities:

- Users
- Organisers
- Participants
- Events
- Categories
- Enrolments
- Results

The SQL script implements the same seven entities and the corresponding primary-key and foreign-key relationships shown in the ERD.

## Main Relationships

- **Users** 1-to-1 **Organisers**
- **Users** 1-to-1 **Participants**
- **Organisers** 1-to-many **Events**
- **Events** 1-to-many **Categories**
- **Participants** 1-to-many **Enrolments**
- **Categories** 1-to-many **Enrolments**
- **Enrolments** 1-to-0..1 **Results**

The many-to-many business relationship between **Participants** and **Categories** is resolved through the **Enrolments** entity.

## Testing

To test the database:

1. Open **RaceDay_Database.sql** in SQL Server Management Studio (SSMS).
2. Execute the script on a clean SQL Server instance.
3. The script creates the **RaceDayDB** database.
4. It creates all seven tables and their constraints.
5. It inserts sample seed data.
6. It runs verification `SELECT` statements to confirm that the data was created successfully.

## Database Technologies

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL
