# Data Models

## User Model

*   **Purpose:** Represents a registered user in the system. This model stores authentication credentials and basic profile information. It is the core entity for all user-centric operations.
*   **Key Attributes:**
    *   `id`: `UUID` - The unique identifier for the user (Primary Key).
    *   `email`: `String` - The user's unique email address, used for login and communication.
    *   `username`: `String` - The user's unique username, can also be used for login.
    *   `hashed_password`: `String` - The securely hashed password for the user. This field will never store plaintext passwords.
    *   `full_name`: `String` (Optional) - The user's full name.
    *   `is_active`: `Boolean` - A flag to activate or deactivate the user's account. Defaults to `true`.
    *   `created_at`: `DateTime` - Timestamp indicating when the account was created.
    *   `updated_at`: `DateTime` - Timestamp of the last profile information update.
*   **Relationships:**
    *   Initially, this model will be standalone. Future enhancements could link it to roles, permissions, or extended profile models.

---
