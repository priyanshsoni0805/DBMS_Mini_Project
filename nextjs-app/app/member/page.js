"use client";
import { useState } from "react";
import { Shell, Card, Table, useApi, btn } from "@/components/ui";

function nextDateFor(day) {
  const names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  const d = new Date();
  d.setDate(d.getDate() + ((names.indexOf(day) - d.getDay() + 7) % 7 || 7));
  return d.toISOString().slice(0, 10);
}

export default function MemberDashboard() {
  const profile = useApi("/api/member/profile");
  const payments = useApi("/api/member/payments");
  const classes = useApi("/api/classes");
  const bio = useApi(profile.data ? `/api/biometrics/${profile.data.member_id}` : null); // MongoDB document
  const [msg, setMsg] = useState("");

  async function book(c) {
    const r = await fetch("/api/member/book", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ class_id: c.class_id, booking_date: nextDateFor(c.schedule_day) }) });
    const j = await r.json();
    setMsg(r.ok ? `Booked ${c.class_name}` : j.error);
  }
  return (
    <Shell title="Member dashboard" subtitle="You can only see your own profile, payments and biometrics.">
      <Card title="My profile (CALL sp_GetMyProfile)"><Table rows={profile.data ? [profile.data] : null} /></Card>
      <Card title="My payments (CALL sp_GetMyPayments)"><Table rows={payments.data} /></Card>
      <Card title="Book a class">
        {msg && <p><strong>{msg}</strong></p>}
        <Table rows={classes.data} actions={(c) => <button style={btn()} onClick={() => book(c)}>Book next</button>} />
      </Card>
      <Card title="My biometrics (MongoDB)">
        <pre style={{ background: "#f0f3f8", padding: 12, borderRadius: 6, overflowX: "auto" }}>{bio.err ? bio.err : JSON.stringify(bio.data, null, 2)}</pre>
      </Card>
    </Shell>
  );
}
