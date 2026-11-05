import { poolFor } from "@/lib/db";
import { requireRole } from "@/lib/auth";

export async function GET() {
  const { session, error } = await requireRole();
  if (error) return error;
  const [rows] = await poolFor(session.role).query(
    "SELECT class_id, class_name, trainer_id, room_number, capacity, schedule_day, start_time, duration_minutes FROM gym_classes ORDER BY FIELD(schedule_day,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'), start_time");
  return Response.json(rows);
}
