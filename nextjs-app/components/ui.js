"use client";
import { useEffect, useState } from "react";

export function Shell({ title, subtitle, children }) {
  async function logout() {
    await fetch("/api/auth/logout", { method: "POST" });
    window.location.href = "/login";
  }
  return (
    <div>
      <header style={{ background: "#1F3A5F", color: "white", padding: "14px 28px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <div><strong style={{ fontSize: 20 }}>FitPulse</strong> <span style={{ opacity: 0.8 }}>| {title}</span></div>
        <button onClick={logout} style={btn("#fff", "#1F3A5F")}>Log out</button>
      </header>
      <main style={{ maxWidth: 1100, margin: "24px auto", padding: "0 20px" }}>
        {subtitle && <p style={{ color: "#5b6b7b" }}>{subtitle}</p>}
        {children}
      </main>
    </div>
  );
}

export const btn = (bg = "#2f6fed", color = "#fff") => ({ background: bg, color, border: "none", borderRadius: 6, padding: "8px 14px", cursor: "pointer", fontSize: 14 });

export function Card({ title, children }) {
  return (
    <section style={{ background: "white", borderRadius: 10, padding: 20, marginBottom: 20, boxShadow: "0 1px 4px rgba(0,0,0,.08)" }}>
      <h2 style={{ marginTop: 0, fontSize: 18 }}>{title}</h2>
      {children}
    </section>
  );
}

export function Table({ rows, actions }) {
  if (!rows) return <p>Loading...</p>;
  if (!rows.length) return <p>No records.</p>;
  const cols = Object.keys(rows[0]);
  return (
    <div style={{ overflowX: "auto" }}>
      <table style={{ borderCollapse: "collapse", width: "100%", fontSize: 14 }}>
        <thead><tr>{cols.map((c) => <th key={c} style={th}>{c}</th>)}{actions && <th style={th}>actions</th>}</tr></thead>
        <tbody>
          {rows.map((r, i) => (
            <tr key={i}>
              {cols.map((c) => <td key={c} style={td}>{String(r[c] ?? "")}</td>)}
              {actions && <td style={td}>{actions(r)}</td>}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
const th = { textAlign: "left", padding: "8px 10px", borderBottom: "2px solid #dde3ec", background: "#f0f3f8", whiteSpace: "nowrap" };
const td = { padding: "8px 10px", borderBottom: "1px solid #eef1f6", whiteSpace: "nowrap" };

export function useApi(url) {
  const [data, setData] = useState(null);
  const [err, setErr] = useState(null);
  const load = () => !url ? null : fetch(url).then(async (r) => (r.ok ? setData(await r.json()) : setErr((await r.json()).error))).catch((e) => setErr(e.message));
  useEffect(() => { load(); }, [url]);
  return { data, err, reload: load };
}
