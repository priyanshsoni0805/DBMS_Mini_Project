// Sets a REAL bcrypt hash for every seeded user (the seed file ships placeholder hashes).
// Usage:  node scripts/set-passwords.js        (reads .env.local values from the environment)
//         default password for every seeded account: Gym@12345
const bcrypt = require("bcryptjs");
const mysql = require("mysql2/promise");

(async () => {
  const hash = await bcrypt.hash("Gym@12345", 10);
  const db = await mysql.createConnection({
    host: process.env.MYSQL_HOST || "localhost",
    user: process.env.MYSQL_ADMIN_USER || "root",
    password: process.env.MYSQL_ADMIN_PASS || "",
    database: process.env.MYSQL_DB || "gym_management_db",
  });
  const [r] = await db.query("UPDATE users SET password_hash = ?", [hash]);
  console.log("Updated", r.affectedRows, "users. Login with e.g. admin@fitpulse.com / Gym@12345");
  await db.end();
})();
