# Routing

### Route Configuration

```plaintext
src/app/
├── layout.tsx          # Root layout
├── page.tsx            # Home page
├── login/
│   ├── page.tsx        # Login page
├── register/
│   ├── page.tsx        # Registration page
├── dashboard/
│   ├── layout.tsx      # Dashboard layout
│   ├── page.tsx        # Dashboard home
│   ├── settings/
│   │   ├── page.tsx    # Dashboard settings page
│   │   └── profile/
│   │       ├── page.tsx # User profile page
│   │       └── change-password/
│   │           ├── page.tsx # Change password page
│   └── delete-account/
│       ├── page.tsx    # Delete account page
├── api/                # API Routes (Next.js API handlers)
│   ├── users/
│   │   ├── route.ts    # Example: /api/users
│   └── auth/
│       ├── route.ts    # Example: /api/auth/login
```