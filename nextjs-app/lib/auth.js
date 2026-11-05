import { SignJWT, jwtVerify } from "jose";
import { cookies } from "next/headers";

const secret = () => new TextEncoder().encode(process.env.JWT_SECRET || "dev-only-secret-change-me");
export const COOKIE = "gym_session";

export async function signSession(payload) {
  return new SignJWT(payload).setProtectedHeader({ alg: "HS256" }).setIssuedAt().setExpirationTime("8h").sign(secret());
}

export async function verifySession(token) {
  try { return (await jwtVerify(token, secret())).payload; } catch { return null; }
}

// Used by API routes. Returns the session, or a Response (401/403) the route must return.
export async function requireRole(...roles) {
  const token = cookies().get(COOKIE)?.value;
  const session = token ? await verifySession(token) : null;
  if (!session) return { error: Response.json({ error: "Not authenticated" }, { status: 401 }) };
  if (roles.length && !roles.includes(session.role))
    return { error: Response.json({ error: "Forbidden for role " + session.role }, { status: 403 }) };
  return { session };
}
