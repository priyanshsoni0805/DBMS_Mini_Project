# Next.js - Project Tree Structure

## Complete Application Architecture

```
gym-membership-manager/
├── src/
│   ├── app/
│   │   ├── layout.tsx    # Root layout with navigation & auth context
│   │   ├── page.tsx      # Home page - member dashboard (protected)
│   │   ├── favicon.ico   # Project favicon
│   │   └── global.css    # Global CSS imports
│   │
│   ├── auth/
│   │   ├── login.tsx     # Authentication page with role selection
│   │   └── logout.tsx    # Logout handler
│   │
│   ├── members/
│   │   ├── page.tsx      # Member list with search & pagination
│   │   ├── [id]/page.tsx # Member profile page
│   │   ├── add.tsx       # Add new member form
│   │   └── edit/[id]/page.tsx # Member edit form
│   │
│   ├── trainers/
│   │   ├── page.tsx      # Trainer directory listing
│   │   └── [id]/page.tsx # Trainer profile page
│   │
│   ├── classes/
│   │   ├── page.tsx      # Class schedule with bookings
│   │   ├── add.tsx       # Add new class form
│   │   └── book/[id]/page.tsx # Class booking page
│   │
│   ├── subscriptions/
│   │   ├── page.tsx      # Plan management & subscription details
│   │   └── renew/[id]/page.tsx # Subscription renewal form
│   │
│   ├── api/
│   │   ├── auth/route.tsx    # POST /api/auth/login
│   │   ├── members/route.tsx # GET/POST /api/members
│   │   ├── classes/route.tsx # GET/POST /api/classes
│   │   ├── subscriptions/route.tsx
│   │   └── analytics/route.tsx
│   │
│   └── components/
│       ├── ui/           # Shadcn UI primitives
│       │   ├── navbar.tsx      # Top navigation with role switch
│       │   ├── sidebar.tsx     # Left sidebar navigation
│       │   ├── button.tsx      # Styled button component
│       │   ├── input.tsx       # Form input component
│       │   ├── card.tsx        # Card display component
│       │   ├── dropdown.tsx    # Role dropdown menu
│       │   └── avatar.tsx      # User avatar with initials
│       │
│       ├── dashboard/        # Dashboard-specific components
│       │   ├── kpi-cards.tsx   # Revenue, members, trainers stats
│       │   ├── member-grid.tsx # Member listing grid
│       │   ├── class-schedule.tsx # Weekly class calendar
│       │   └── trainer-workload.tsx # Trainer assignment summary
│       │
│       ├── auth/           # Authentication components
│       │   └── role-switcher.tsx
│       │
│       ├── common/         # Reusable across roles
│       │   ├── alert.tsx       # Toast notifications
│       │   ├── spinner.tsx     # Loading spinner
│       │   └── table.tsx       # Generic data table
│       │
│       └── layout/         # Page layout wrappers
│           ├── with-auth.tsx   # Protect pages requiring login
│           └── with-role.tsx   # Protect based on user role
│
├── lib/
│   ├── db.sql.ts           # SQL database client (MySQL/PostgreSQL)
│   │   - query() for SELECT operations
│   │   - execute() for INSERT/UPDATE/DELETE
│   │   - transaction() for multi-statement transactions
│   │   - Session management with connection pooling
│   │
│   ├── db.mongo.ts         # MongoDB client
│   │   - connectToMongoDB()
│   │   - getMemberBiometricsCollection()
│   │   - getWorkoutTelemetryCollection()
│   │   - Aggregation helpers
│   │
│   ├── vector.db.py        # Python vector similarity engine wrapper
│   │   - generateEmbedding(text) - calls Python function
│   │   - searchSimilar(query, top_k) - cosine similarity search
│   │   - insertVector(doc) - ingest workout plan
│   │   - updateVector(doc_id, new_data) - update and re-index
│   │   - deleteVector(doc_id) - evict from storage
│   │
│   ├── auth.ts             # JWT authentication & role verification
│   │   - JWT token generation
│   │   - jwtVerify() middleware
│   │   - protect(allowedRoles) - role-based access control
│   │   - getCurrentUser() - extract user from session
│   │
│   ├── utils.ts            # Utility functions (formatCurrency, etc.)
│   │   - formatDate(date)
│   │   - truncateText(text, limit)
│   │   - capitalizeFirst(text)
│   │
│   └── storage.ts          # LocalStorage/SessionStorage helpers
│
├── types/
│   ├── types.ts            # Global TypeScript interfaces
│   │   - UserRole: 'ADMIN' | 'TRAINER' | 'MEMBER'
│   │   - Member interface with all fields
│   │   - Subscription interface
│   │   - Class interface
│   │
│   ├── api.ts              # API route response types
│   │   - LoginResponse
│   │   - MemberResponse
│   │   - ClassBookingResponse
│   │
│   ├── database.ts         # Database connection types
│   │   - SQLConnectionConfig
│   │   - MongoDBConnectionConfig
│   │   - VectorDBConfig
│   │
│   └── enums.ts            # Project enums
│       - PaymentMethod: 'Credit_Card' | 'UPI' | 'Net_Banking' | 'Cash'
│       - BookingStatus: 'Confirmed' | 'Waitlisted' | 'Cancelled' | 'Attended'
│       - FacilityZone: 'Main Gym Floor' | 'Cardio Deck' | etc.
│
├── styles/
│   ├── globals.css         # Global styles with Tailwind directives
│   │   - @tailwind base;
│   │   - @tailwind components;
│   │   - @tailwind utilities;
│   │   - Custom CSS variables
│   │
│   └── components.css      # Component-specific styles
│
├── middleware.ts           # Next.js 13+ route middleware
│   - Auth middleware: protects routes based on user role
│   - Redirects unauthenticated users to /login
│   - Extracts JWT from cookies, verifies payload
│   - Attaches user to request context
│
├── next.config.js          # Next.js configuration
│ - output: 'standalone'
│ - experimental: { appDirectory: true }
│ -env variables for DB connections
│
├── tailwind.config.js      # Tailwind CSS v3 configuration
│ - darkMode: 'class'
│ - content: ["./src/**/*.{js,ts,jsx,tsx}"]
│ - theme: { extend: { colors, fonts } }
│
├── package.json            # Dependencies and scripts
│ - Dependencies:
│   - next: 14.2.4 or latest
│   - react: 18.3.0 or latest
│   - react-dom: 18.3.0 or latest
│   - @types/react, @types/react-dom
│   - shadcn-ui components
│   - tailwindcss
│   - mongodb driver
│   - jwt-decode
│   - clsx, class-variance-authority
│
├── tsconfig.json           # TypeScript configuration
│ - target: ES2020
│ - compilerOptions: {}
│ - includes: ["src/**/*"]
│
└── README.md               # Project documentation
    - Setup instructions
    - API endpoints reference
    - Database connection configuration
    - Role-based access guide
```

## API Route Examples

### 1. Authentication Endpoint

```typescript
// src/app/api/auth/route.tsx
import { NextResponse } from 'next/server';
import { jwtVerify } from 'jose';
import { db } from '@/lib/db.sql';

export async function POST(request: Request) {
  try {
    const { email, password, role } = await request.json();
    
    // Validate credentials against database
    const user = await db.query(
      'SELECT * FROM users WHERE email = ? AND status = ?',
      [email, 'Active']
    );
    
    if (user.length === 0) {
      return NextResponse.json(
        { error: 'Invalid credentials' },
        { status: 401 }
      );
    }
    
    // Generate JWT token
    const secret = process.env.JWT_SECRET;
    const token = await jwtVerify(
      // token creation logic
    );
    
    const response = NextResponse.json({
      success: true,
      user: { id: user[0].user_id, role: user[0].role_id }
    });
    
    // Set auth cookie
    response.cookies.set('auth_token', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 60 * 60 * 24 * 7 // 1 week
    });
    
    return response;
    
  } catch (error) {
    return NextResponse.json(
      { error: 'Authentication failed' },
      { status: 500 }
    );
  }
}
```

### 2. Members Listing with Role Protection

```typescript
// src/app/api/members/route.tsx
import { NextResponse } from 'next/server';
import { auth } from '@/lib/auth';
import { db } from '@/lib/db.sql';

export async function GET(request: Request) {
  await auth.protect(['ADMIN', 'TRAINER']); // Two roles allowed
  
  const members = await db.query(`
    SELECT m.member_id, u.full_name, u.email, r.role_name,
           mp.plan_name, s.status AS subscription_status,
           fp.full_name AS referrer_name,
           COUNT(DISTINCT ta.trainer_id) AS assigned_trainers
    FROM members m
    JOIN users u ON m.user_id = u.user_id
    JOIN roles r ON m.role_id = r.role_id
    LEFT JOIN subscriptions s ON m.member_id = s.member_id
    LEFT JOIN membership_plans mp ON s.plan_id = mp.plan_id
    LEFT JOIN members fp ON m.referred_by_member_id = fp.member_id
    LEFT JOIN trainer_assignments ta ON m.member_id = ta.member_id AND ta.status = 'Active'
    GROUP BY m.member_id, u.full_name, u.email, r.role_name,
             mp.plan_name, s.status, fp.full_name
    ORDER BY m.member_id DESC
  `);
  
  return new Response(JSON.stringify(members), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
}
```

### 3. Class Booking with Capacity Check

```typescript
// src/app/api/classes/book/route.tsx
export async function POST(request: Request) {
  await auth.protect(['MEMBER', 'TRAINER']);
  const { classId, memberId, bookingDate } = await request.json();
  
  // Check capacity via API or database trigger
  const capacityCheck = await db.query(
    'SELECT capacity FROM gym_classes WHERE class_id = ?',
    [classId]
  );
  
  const bookedCount = await db.query(
    'SELECT COUNT(*) as count FROM class_bookings WHERE class_id = ? AND booking_date = ? AND status IN (?, ?)',
    [classId, bookingDate, 'Confirmed', 'Attended']
  );
  
  if (bookedCount[0].count >= capacityCheck[0].capacity) {
    return new Response(
      JSON.stringify({ error: 'CapacityExceededError: Class room is fully booked!' }),
      { status: 403, headers: { 'Content-Type': 'application/json' } }
    );
  }
  
  // Insert booking
  await db.query(
    'INSERT INTO class_bookings (class_id, member_id, booking_date, booking_status) VALUES (?, ?, ?, ?)',
    [classId, memberId, bookingDate, 'Confirmed']
  );
  
  // Update attendance or send confirmation
  return new Response(
    JSON.stringify({ success: true, bookingId: 'NEW-XXX' }),
    { status: 201, headers: { 'Content-Type': 'application/json' } }
  );
}
```

### 4. KPI Dashboard Endpoint

```typescript
// src/app/api/analytics/kpis/route.tsx
export async function GET(request: Request) {
  await auth.protect(['ADMIN']); // Admin-only endpoint
  
  const kpis = await db.query(`
    SELECT 
      (SELECT COUNT(*) FROM members) AS total_registered_members,
      (SELECT COUNT(*) FROM subscriptions WHERE status = 'Active') AS active_subscriptions,
      (SELECT COUNT(*) FROM trainers) AS active_trainers,
      (SELECT COALESCE(SUM(amount), 0.00) FROM payments WHERE payment_status = 'Completed') AS total_gross_revenue,
      (SELECT ROUND(AVG(amount), 2) FROM payments WHERE payment_status = 'Completed') AS avg_revenue_per_member,
      (SELECT COUNT(*) FROM class_bookings WHERE booking_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)) AS recent_bookings
  `);
  
  return new Response(JSON.stringify(kpis[0]), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
}
```

## Role-Based Access Control Implementation

### Frontend Role Switcher

```tsx
// src/components/auth/role-switcher.tsx
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

const RoleSwitcher = () => {
  const [role, setRole] = useState<string>('MEMBER');
  const router = useRouter();
  
  useEffect(() => {
    // Check auth token and set role
    const token = localStorage.getItem('auth_token');
    if (token) {
      // Decode JWT to get role
      const payload: any = jwt_decode(token);
      setRole(payload.role);
    } else {
      router.push('/login');
    }
  }, [router]);
  
  // Route based on role
  useEffect(() => {
    const protectedRoutes = {
      ADMIN: '/admin',
      TRAINER: '/trainer', 
      MEMBER: '/member'
    };
    
    router.push(protectedRoutes[role as keyof typeof protectedRoutes]);
  }, [role, router]);
  
  return null; // No UI rendered, just redirects
};

export default RoleSwitcher;
```

### Middleware Protection

```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const protectedRoutes = ['/member', '/trainer', '/admin'];
const roleRoutes = {
  '/admin': ['ADMIN'],
  '/trainer': ['TRAINER', 'ADMIN'],
  '/member': ['MEMBER', 'TRAINER', 'ADMIN']
};

export async function middleware(request: NextRequest) {
  const token = request.cookies.get('auth_token')?.value;
  
  if (!token) {
    if (protectedRoutes.includes(request.nextUrl.pathname)) {
      return NextResponse.redirect(new URL('/login', request.url));
    }
    return NextResponse.next();
  }
  
  try {
    // Verify JWT token
    const payload: any = jwt.verify(
      token, 
      process.env.JWT_SECRET!
    );
    
    const userRole = payload.role;
    const allowedRoutes = roleRoutes[request.nextUrl.pathname];
    
    if (allowedRoutes && !allowedRoutes.includes(userRole)) {
      return NextResponse.redirect(new URL('/unauthorized', request.url));
    }
    
    // Attach user to request for downstream use
    const requestHeaders = new Headers(request.headers);
    requestHeaders.set('x-user-role', userRole);
    requestHeaders.set('x-user-id', payload.id);
    
    return NextResponse.next({
      request: {
        headers: requestHeaders
      }
    });
    
  } catch (error) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}

export const config = {
  matcher: [
    '/member/:path',
    '/trainer/:path', 
    '/admin/:path',
    '/api/auth/:path'
  ]
};
```

## Database Integration Summary

| Feature | SQL Implementation | MongoDB Implementation | Vector DB Implementation |
|---------|-------------------|----------------------|------------------------|
| **Connection** | mysql2/promise pool | mongodb npm package | Python subprocess calls |
| **Authentication** | Session-based via users table | Document-level security | Not applicable |
| **CRUD Operations** | Standard SQL queries | find, insertMany, updateOne, deleteOne | custom embedding-based ops |
| **Role-Based Access** | FK to roles table, CHECK constraints | role field in documents | Not applicable |
| **Query Performance** | Indexes on PK/FK/unique fields | Compound indexes on biometrics | Cosine similarity computation |
| **Data Model** | Normalized 12-table schema | Flexible JSON documents | Text descriptions → dense vectors |
| **Transaction Support** | Full ACID with InnoDB | Document-level transactions | Not applicable |
| **Real-world Use** | Member profiles, subscriptions, bookings | Biometrics, wearable data, health flags | Intelligent workout recommendations |