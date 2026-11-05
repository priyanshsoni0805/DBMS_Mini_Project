import { poolFor } from "@/lib/db";
import { requireRole } from "@/lib/auth";

export async function GET() {
  const { error } = await requireRole("TRAINER", "ADMIN");
  if (error) return error;
  const [rows] = await poolFor("TRAINER").query(
    `SELECT b.booking_id, c.class_name, c.schedule_day, b.booking_date, vm.full_name AS member_name, b.booking_status
       FROM class_bookings b
       JOIN gym_classes c ON c.class_id = b.class_id
       JOIN v_member_directory vm ON vm.member_id = b.member_id
      ORDER BY b.booking_date DESC, b.booking_id DESC`);
  return Response.json(rows);
}

// Trainer may update ONLY booking_status (column-level GRANT in 07_rbac_security.sql).
export async function PATCH(req) {
  const { error } = await requireRole("TRAINER");
  if (error) return error;
  const { booking_id, booking_status } = await req.json();
  if (!["Confirmed", "Waitlisted", "Cancelled", "Attended"].includes(booking_status))
    return Response.json({ error: "Invalid status" }, { status: 400 });
  const [r] = await poolFor("TRAINER").query("UPDATE class_bookings SET booking_status = ? WHERE booking_id = ?", [booking_status, booking_id]);
  return Response.json({ updated: r.affectedRows });
}
