# 🎬 PVR Theater Ticket Booking and Cancelling System

## 📌 Project Overview

This project is a MySQL-based Theater Ticket Booking and Cancelling System designed to manage ticket bookings, cancellations, ticket availability, and transaction records.

It uses Stored Procedures, Transactions, and Error Handling to manage booking and cancellation operations.

## 🛠️ Technologies Used

- MySQL
- MySQL Workbench
- SQL

## 🗄️ Database Structure

**Database Name:** `PVR_theater`

### Tables

| Table Name | Description |
|---|---|
| Theater | Stores theater details, ticket types, rates and ticket capacity |
| Bookings | Stores ticket booking transactions |
| cancelledBookings | Stores ticket cancellation records |

## ⚙️ Stored Procedures

### 1. book_ticket

Used to book theater tickets.

**Operations:**
- Accepts Theater ID, Ticket Type and Quantity.
- Checks ticket type and available capacity.
- Calculates the total ticket amount.
- Inserts booking records.
- Updates available ticket capacity.
- Uses transactions and error handling.

### 2. cancel_ticket

Used to cancel previously booked tickets.

**Operations:**
- Accepts Booking ID and cancellation quantity.
- Validates the booking and cancellation quantity.
- Calculates the cancellation amount.
- Inserts cancellation records.
- Restores available ticket capacity.
- Updates the original booking quantity and amount.
- Uses transactions and error handling.

## 🧠 SQL Concepts Used

- Database and Table Creation
- Primary Keys and Foreign Keys
- INSERT, UPDATE and SELECT
- Stored Procedures
- IN, OUT Parameters
- Local Variables
- Transactions (START TRANSACTION, COMMIT, ROLLBACK)
- Error Handling
- SIGNAL and RESIGNAL
- EXIT HANDLER
- ROW_COUNT()
- LAST_INSERT_ID()

## ▶️ How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Open the SQL script in MySQL Workbench.
3. Execute the database and table creation statements.
4. Insert the theater records.
5. Create the stored procedures.
6. Call `book_ticket` to book tickets.
7. Call `cancel_ticket` to cancel tickets.
8. Use SELECT statements to verify the results.

## 👨‍💻 Author

**Suleman Gani**

BBA Graduate | Data Analyst

- GitHub: [suleman-gani](https://github.com/suleman-gani)
- LinkedIn: [Suleman Gani](https://linkedin.com/in/suleman-gani-3a9a62392)
- Email: sragani069@gmail.com

---

⭐ If you find this project useful, feel free to explore the SQL script!
