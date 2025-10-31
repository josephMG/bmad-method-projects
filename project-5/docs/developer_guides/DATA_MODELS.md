# Data Model Documentation

This document provides clear definitions of the core data models used in the Family Expense Tracker application: `ExpenseRecord` and `Category`. It also explains their mapping to Google Sheets row data.

## 1. ExpenseRecord Data Model

The `ExpenseRecord` class represents a single expense entry in the application. It contains details such as the amount, description, category, and timestamps.

**File:** `family_expense_tracker/lib/data/models/expense_record.dart`

### 1.1 Fields

| Field Name     | Type       | Description                                         |
| :------------- | :--------- | :-------------------------------------------------- |
| `id`           | `String`   | Unique identifier for the expense record (UUID).    |
| `date`         | `DateTime` | The date when the expense occurred.                 |
| `description`  | `String`   | A brief description of the expense.                 |
| `amount`       | `double`   | The monetary amount of the expense.                 |
| `categoryId`   | `String`   | Reference to the ID of the associated category.     |
| `paymentMethod`| `String`   | The method used for payment (e.g., "Cash", "Card"). |
| `recordedBy`   | `String`   | The user who recorded the expense.                  |
| `createdAt`    | `DateTime` | Timestamp when the record was first created.        |
| `lastModified` | `DateTime` | Timestamp when the record was last modified.        |
| `notes`        | `String?`  | Optional additional notes for the expense.          |

### 1.2 Google Sheets Mapping (`toGoogleSheetRow()`)

When an `ExpenseRecord` is saved to Google Sheets, its fields are mapped to columns in a specific order. The `toGoogleSheetRow()` method in `ExpenseRecord` defines this mapping.

| Google Sheet Column | ExpenseRecord Field |
| :------------------ | :------------------ |
| `ID`                | `id`                |
| `Date`              | `date` (formatted as `yyyy-MM-dd`) |
| `Description`       | `description`       |
| `Amount`            | `amount`            |
| `CategoryId`        | `categoryId`        |
| `PaymentMethod`     | `paymentMethod`     |
| `RecordedBy`        | `recordedBy`        |
| `CreatedAt`         | `createdAt` (ISO 8601 string) |
| `LastModified`      | `lastModified` (ISO 8601 string) |
| `Notes`             | `notes`             |

**Note:** `RecordID`, `RecordedBy`, `CreatedAt`, and `LastModified` are typically stored as hidden columns in the Google Sheet tabs to maintain data integrity and provide auditing information.

## 2. Category Data Model

The `Category` class represents a classification for expenses, such as "Food", "Transport", etc.

**File:** `family_expense_tracker/lib/data/models/category.dart`

### 2.1 Fields

| Field Name     | Type      | Description                                         |
| :------------- | :-------- | :-------------------------------------------------- |
| `id`           | `String`  | Unique identifier for the category.                 |
| `categoryName` | `String`  | The name of the category (e.g., "Groceries").       |
| `colorCode`    | `Color`   | The color associated with the category for UI representation. |
| `isActive`     | `bool`    | Indicates if the category is currently active.      |

### 2.2 Google Sheets Mapping (`toGoogleSheetRow()`)

When a `Category` is saved to Google Sheets, its fields are mapped to columns. The `toGoogleSheetRow()` method in `Category` defines this mapping.

| Google Sheet Column | Category Field                                      |
| :------------------ | :-------------------------------------------------- |
| `CategoryName`      | `categoryName`                                      |
| `ColorCode`         | `colorCode` (hex string, e.g., `#FF0000` for red)   |
| `IsActive`          | `isActive` (string, e.g., "true" or "false")      |

**Note:** The `id` for a category is often implicitly handled by its row index or a separate lookup mechanism in the Google Sheet, or stored as a hidden column if explicit ID management is required at the sheet level. The `fromGoogleSheet` factory constructor expects the `id` to be passed separately, implying it might be derived or managed externally to the direct row content for categories. This document assumes the `id` is managed by the application logic and not directly present in the `toGoogleSheetRow()` output for categories. However, the `categoryId` in `ExpenseRecord` explicitly links to this `id`.
