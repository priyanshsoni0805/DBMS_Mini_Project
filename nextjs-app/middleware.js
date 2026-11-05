import { NextResponse } from "next/server";
import { jwtVerify } from "jose";

// Front-end route protection: /admin, /trainer, /member require the matching role.
const ROLE_HOME = { ADMIN: "/admin", TRAINER: "/trainer", MEMBER: "/member" };

export async function middleware(req) {
  const { pathname } = req.nextUrl;
  const token = req.cookies.get("gym_session")?.value;
  let session = null;
  if (token) {
    try {
      session = (await jwtVerify(token, new TextEncoder().encode(process.env.JWT_SECRET || "dev-only-secret-change-me"))).payload;
    } catch {}
  }
  if (!session) return NextResponse.redirect(new URL("/login", req.url));
  const needed = pathname.startsWith("/admin") ? "ADMIN" : pathname.startsWith("/trainer") ? "TRAINER" : "MEMBER";
  if (session.role !== needed) return NextResponse.redirect(new URL(ROLE_HOME[session.role] || "/login", req.url));
  return NextResponse.next();
}

export const config = { matcher: ["/admin/:path*", "/trainer/:path*", "/member/:path*"] };
