# PlatinumRx Data Analyst Assignment  
Completed by: Shaik Mohammed Sameer

---

## 📁 Project Structure

The assignment is organized into three main sections: SQL, Excel, and Python.

# 🧩 1. SQL Section

All SQL query solutions for both **Hotel (A1–A5)** and **Clinic (B1–B5)** are combined into a single file:

### ✔ `SQL/All_Queries.sql`

This file includes:

## 🔹 Hotel Management (Part A)
- **A1:** Last booked room per user  
- **A2:** Booking-wise billing for November 2021  
- **A3:** Bills raised in October 2021 with amount > 1000  
  - *Note:* Sample data has no October bill > 1000 → returns **0 rows (expected)**  
- **A4:** Most & least ordered item per month (2021)  
- **A5:** Customers with the 2nd highest bill per month  

## 🔹 Clinic Management (Part B)
- **B1:** Revenue by sales channel (2021)  
- **B2:** Top 10 most valuable customers  
- **B3:** Monthly revenue, expense, profit & status  
- **B4:** Most profitable clinic per city  
- **B5:** 2nd least profitable clinic per state  

### ✔ Schema Files Available:
- `01_Hotel_Schema_Setup.sql`
- `03_Clinic_Schema_Setup.sql`

These create all necessary tables & sample data.

---

# 📊 2. Excel Section  
File: **`Spreadsheets/Ticket_Analysis.xlsx`**

Contains 2 sheets: `ticket` and `feedbacks`

---

## 🟦 Sheet 1: `ticket`

### Columns:
- ticket_id  
- created_at  
- closed_at  
- outlet_id  
- cms_id  

## 🟦 Sheet 1: `ticket`

### Helper Columns Added:

#### **same_day**
```excel

=IF(INT(B2)=INT(C2),"Yes","No")


```
### **same_hour**
```excel

=IF(AND(INT(B2)=INT(C2), HOUR(B2)=HOUR(C2)), "Yes", "No")

```
These determine:

- whether created_at and closed_at fall on the same day

- whether both fall in the same hour of the same day

## 🟩 Sheet: `feedbacks`
### Column Filled:

### ticket_created_at

### **Formula used:**
```excel
=INDEX(ticket!$B:$B, MATCH(A2, ticket!$E:$E, 0))

```
This pulls the ticket creation timestamp via cms_id.


### 🟧 Summary (Outlet-Wise Counts)

### Computed using:

### **✔ Same Day Count: **
```excel
=COUNTIFS(ticket!$D:$D, $A2, ticket!$F:$F, "Yes")
```

### **✔ Same Hour Count: **
```excel
=COUNTIFS(ticket!$D:$D, $A2, ticket!$G:$G, "Yes")
```

### This fulfills:

- Q2(a): Tickets created & closed on the same day
- Q2(b): Tickets created & closed in the same hour

### 🐍 3. Python Section
### ✔ File: 01_Time_Converter.py

Converts minutes into human-readable form (hrs + minutes).
Accepts user input.

### **Example: **
```excel
Input: 130
Output: 2 hrs 10 minutes
```

### ✔ File: 02_Remove_Duplicates.py

Removes duplicate characters using a loop.
Preserves order of first occurrence.

### **Example: **
```excel
Input: banana
Output: ban
```

Both Python programs executed successfully.
