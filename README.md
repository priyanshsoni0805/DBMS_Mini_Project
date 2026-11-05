# FitPulse - Gym Membership Manager (DBMS Mini Project)

PES University | Database Management Systems (UE23CS351A)
**Team Members:**
- Priyansh Soni (SRN: PES1UG24CS344)
- Pulkit Bhardwaj (SRN: PES1UG24CS346)

A gym management system using three database paradigms behind one Next.js web app:

| Layer | Technology | Files |
|---|---|---|
| Relational (12 tables, triggers, procedures, CTEs) | MySQL 8.0+ | `database/01-04*.sql` |
| Database-level RBAC (3 roles, 3 DB accounts) | MySQL roles + GRANT | `database/07_rbac_security.sql` |
| Document store (member biometrics) | MongoDB | `database/05_nosql_mongodb.js` |
| Vector search (workout recommendations) | Python (pure-Python embeddings + cosine search) | `database/06_vector_database.py` |
| Web app + REST API + JWT auth | Next.js 14 (App Router) | `nextjs-app/` |
| ER diagram | Graphviz (`docs/make_er.py`) | `docs/er_diagram.png` |

## Setup

```bash
# 1. MySQL
mysql -u root -p < database/01_ddl_schema.sql
mysql -u root -p < database/02_dml_seed.sql
mysql -u root -p < database/04_advanced_sql.sql      # procedures, functions, triggers, CTE demos
mysql -u root -p < database/07_rbac_security.sql     # roles + per-role DB accounts (edit passwords first)

# 2. MongoDB
mongosh < database/05_nosql_mongodb.js

# 3. Vector DB demo
python3 database/06_vector_database.py

# 4. Web app
cd nextjs-app
cp .env.example .env.local        # fill in passwords / JWT secret
npm install
npm run seed-passwords            # replaces placeholder hashes with real bcrypt hashes (password: Gym@12345)
npm run dev                       # http://localhost:3000
```

Demo logins (after `seed-passwords`, password `Gym@12345`):
`admin@fitpulse.com` (ADMIN), `marcus.v@fitpulse.com` (TRAINER), `aditya.rao@gmail.com` (MEMBER).

## Roles

| Role | Web access | Database access (enforced by MySQL) |
|---|---|---|
| ADMIN | `/admin` - KPIs, all members, enrol members | ALL on `gym_management_db` |
| TRAINER | `/trainer` - schedule, bookings, mark attendance | SELECT on classes/bookings/views, UPDATE only `booking_status`; no `users` or `payments` |
| MEMBER | `/member` - own profile, payments, book classes, own biometrics | catalogue SELECT + EXECUTE on `sp_GetMy*` / `sp_BookClass` only |

## Push to GitHub

```bash
git init
git add .
git commit -m "DBMS mini project: schema, queries, NoSQL, vector DB, Next.js app"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo>.git
git push -u origin main
```
