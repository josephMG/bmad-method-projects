```yaml
openapi: 3.0.0
info:
  title: User Management Service API
  version: 1.0.0
  description: API for user registration, authentication, and profile management.
servers:
  - url: /api/v1
    description: API Version 1

paths:
  /register:
    post:
      summary: Register a new user
      tags: [Authentication]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserCreate'
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserRead'
        '400':
          description: Bad Request (e.g., user already exists)

  /token:
    post:
      summary: Log in to get an access token
      tags: [Authentication]
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                username:
                  type: string
                password:
                  type: string
              required: [username, password]
      responses:
        '200':
          description: Successful login
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Token'
        '401':
          description: Unauthorized

  /users/me:
    get:
      summary: Get current user profile
      tags: [Users]
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Current user data
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserRead'
    put:
      summary: Update current user profile
      tags: [Users]
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserUpdate'
      responses:
        '200':
          description: User updated successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserRead'
    delete:
      summary: Delete current user account
      tags: [Users]
      security:
        - bearerAuth: []
      responses:
        '204':
          description: User account deleted successfully

  /users/me/password:
    put:
      summary: Change current user password
      tags: [Users]
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/PasswordUpdate'
      responses:
        '204':
          description: Password updated successfully

components:
  schemas:
    UserCreate:
      type: object
      properties:
        email:
          type: string
          format: email
        username:
          type: string
        password:
          type: string
      required: [email, username, password]
    UserUpdate:
      type: object
      properties:
        full_name:
          type: string
        email:
          type: string
          format: email
      required: [email] # Assuming email is required for update
    UserRead:
      type: object
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        username:
          type: string
        full_name:
          type: string
        is_active:
          type: boolean
      required: [id, email, username, is_active]
    PasswordUpdate:
      type: object
      properties:
        current_password:
          type: string
        new_password:
          type: string
      required: [current_password, new_password]
    Token:
      type: object
      properties:
        access_token:
          type: string
        token_type:
          type: string
          default: bearer

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

---
