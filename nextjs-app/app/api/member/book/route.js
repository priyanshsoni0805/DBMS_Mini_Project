import { poolFor } from "@/lib/db";
import { requireRole } from "@/lib/auth";

export async function POST(req) {
  const { session, error } = await requireRole("MEMBER");
  if (error) return error;
  const { class_id, booking_date } = await req.json();
  try {
    await poolFor("MEMBER").query("CALL sp_BookClass(?,?,?)", [session.userId, class_id, booking_date]);
    return Response.json({ ok: true }, { status: 201 });
  } catch (e) {
    // e.g. CapacityExceededError raised by trigger trg_check_class_capacity, or duplicate booking
    return Response.json({ error: e.sqlMessage || e.message }, { status: 409 });
  }
}
