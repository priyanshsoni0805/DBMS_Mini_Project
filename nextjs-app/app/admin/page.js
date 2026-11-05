"use client";
import { useState } from "react";
import { Shell, Card, Table, useApi, btn } from "@/components/ui";

export default function AdminDashboard() {
  const kpis = useApi("/api/admin/kpis");
  const members = useApi("/api/admin/members");
  const plans = useApi("/api/plans");
  const [form, setForm] = useState({ full_name: "", email: "", phone: "", dob: "2000-01-01", emergency_name: "", emergency_phone: "", plan_id: 1 });
  const [msg, setMsg] = useState("");
  const set = (k) => (e) => setForm({ ...form, [k]: e.target.value });

  async function enrol(e) {
    e.preventDefault();
    const r = await fetch("/api/admin/members", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ ...form, plan_id: Number(form.plan_id) }) });
    const j = await r.json();
    setMsg(j.message + (j.invoice_no ? ` (invoice ${j.invoice_no})` : ""));
    members.reload(); kpis.reload();
  }
  const f = { padding: 8, margin: "0 8px 8px 0", border: "1px solid #c9d2df", borderRadius: 6 };
  return (
    <Shell title="Admin dashboard" subtitle="Full access: revenue KPIs, member management, enrolment (stored procedure sp_EnrollNewMember).">
      <Card title="Executive KPIs (CALL sp_GetGymExecutiveKPIs)">
        {kpis.err ? <p>{kpis.err}</p> : <Table rows={kpis.data ? [kpis.data] : null} />}
      </Card>
      <Card title="Enrol new member">
        <form onSubmit={enrol}>
          <input style={f} placeholder="Full name" value={form.full_name} onChange={set("full_name")} required />
          <input style={f} placeholder="Email" type="email" value={form.email} onChange={set("email")} required />
          <input style={f} placeholder="Phone" value={form.phone} onChange={set("phone")} required />
          <input style={f} type="date" value={form.dob} onChange={set("dob")} required />
          <input style={f} placeholder="Emergency contact" value={form.emergency_name} onChange={set("emergency_name")} required />
          <input style={f} placeholder="Emergency phone" value={form.emergency_phone} onChange={set("emergency_phone")} required />
          <select style={f} value={form.plan_id} onChange={set("plan_id")}>
            {(plans.data || []).map((p) => <option key={p.plan_id} value={p.plan_id}>{p.plan_name} - Rs {p.total_price}</option>)}
          </select>
          <button style={btn()} type="submit">Enrol</button>
        </form>
        {msg && <p>{msg}</p>}
      </Card>
      <Card title="All members"><Table rows={members.data} /></Card>
    </Shell>
  );
}
