import mysql from "mysql2/promise";

// One pool per application role -> the DATABASE itself enforces what each role may do
// (see database/07_rbac_security.sql).
const cfg = {
  ADMIN:   { user: process.env.MYSQL_ADMIN_USER,   password: process.env.MYSQL_ADMIN_PASS },
  TRAINER: { user: process.env.MYSQL_TRAINER_USER, password: process.env.MYSQL_TRAINER_PASS },
  MEMBER:  { user: process.env.MYSQL_MEMBER_USER,  password: process.env.MYSQL_MEMBER_PASS },
};

const pools = globalThis.__gymPools || (globalThis.__gymPools = {});

export function poolFor(role) {
  if (!cfg[role]) throw new Error("Unknown role: " + role);
  if (!pools[role]) {
    pools[role] = mysql.createPool({
      host: process.env.MYSQL_HOST || "localhost",
      database: process.env.MYSQL_DB || "gym_management_db",
      ...cfg[role],
      waitForConnections: true,
      connectionLimit: 5,
    });
  }
  return pools[role];
}

// Login must read users.password_hash, which only the admin-level account can see.
export const authPool = () => poolFor("ADMIN");
