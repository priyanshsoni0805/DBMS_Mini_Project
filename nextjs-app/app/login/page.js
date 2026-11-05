"use client";
import { useState } from "react";
import { btn } from "@/components/ui";

const HOME = { ADMIN: "/admin", TRAINER: "/trainer", MEMBER: "/member" };

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  async function submit(e) {
    e.preventDefault();
    setError("");
    const r = await fetch("/api/auth/login", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ email, password }) });
    const j = await r.json();
    if (!r.ok) return setError(j.error);
    window.location.href = HOME[j.role];          // role decides the landing page
  }

  const input = { display: "block", width: "100%", padding: 10, margin: "6px 0 14px", border: "1px solid #c9d2df", borderRadius: 6, boxSizing: "border-box" };
  return (
    <div style={{ minHeight: "100vh", display: "grid", placeItems: "center" }}>
      <form onSubmit={submit} style={{ background: "white", padding: 32, borderRadius: 12, width: 340, boxShadow: "0 4px 18px rgba(0,0,0,.1)" }}>
        <h1 style={{ marginTop: 0 }}>FitPulse</h1>
        <p style={{ color: "#5b6b7b", marginTop: -8 }}>Gym Membership Manager</p>
        <label>Email<input style={input} value={email} onChange={(e) => setEmail(e.target.value)} type="email" required /></label>
        <label>Password<input style={input} value={password} onChange={(e) => setPassword(e.target.value)} type="password" required /></label>
        {error && <p style={{ color: "#c0392b" }}>{error}</p>}
        <button style={{ ...btn(), width: "100%" }} type="submit">Sign in</button>
      </form>
    </div>
  );
}
