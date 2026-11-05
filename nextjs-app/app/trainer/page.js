"use client";
import { Shell, Card, Table, useApi, btn } from "@/components/ui";

export default function TrainerDashboard() {
  const classes = useApi("/api/classes");
  const bookings = useApi("/api/trainer/bookings");

  async function mark(id, status) {
    await fetch("/api/trainer/bookings", { method: "PATCH", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ booking_id: id, booking_status: status }) });
    bookings.reload();
  }
  return (
    <Shell title="Trainer dashboard" subtitle="Limited access: class schedule and bookings. No access to payments or user credentials (enforced by MySQL grants).">
      <Card title="Class schedule"><Table rows={classes.data} /></Card>
      <Card title="Class bookings">
        <Table rows={bookings.data} actions={(r) => (
          <>
            <button style={btn("#1f9d55")} onClick={() => mark(r.booking_id, "Attended")}>Attended</button>{" "}
            <button style={btn("#c0392b")} onClick={() => mark(r.booking_id, "Cancelled")}>Cancel</button>
          </>
        )} />
      </Card>
    </Shell>
  );
}
