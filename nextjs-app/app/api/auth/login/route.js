import bcrypt from "bcryptjs";
import { authPool } from "@/lib/db";
import { signSession, COOKIE } from "@/lib/auth";

export async function POST(req) {
  const { email, password } = await req.json();
  if (!email || !password) return Response.json({ error: "Email and password required" }, { status: 400 });

  const [rows] = await authPool().query(
    `SELECT u.user_id, u.full_name, u.password_hash, u.status, r.role_name
       FROM users u JOIN roles r ON r.role_id = u.role_id
      WHERE u.email = ?`, [email]);
  const user = rows[0];
  const ok = user && user.status === "Active" && (await bcrypt.compare(password, user.password_hash));
  if (!ok) return Response.json({ error: "Invalid credentials" }, { status: 401 });

  const token = await signSession({ userId: user.user_id, name: user.full_name, role: user.role_name });
  const res = Response.json({ role: user.role_name, name: user.full_name });
  res.headers.append("Set-Cookie", `${COOKIE}=${token}; Path=/; HttpOnly; SameSite=Lax; Max-Age=28800`);
  return res;
}
