import { poolFor } from "@/lib/db";
import { requireRole } from "@/lib/auth";

export async function GET() {
  const { error } = await requireRole("ADMIN");
  if (error) return error;
  const [rows] = await poolFor("ADMIN").query(
    `SELECT m.member_id, u.full_name, u.email, m.fitness_goal, m.loyalty_points, m.joined_date,
            ru.full_name AS referred_by
       FROM members m
       JOIN users u ON u.user_id = m.user_id
       LEFT JOIN members rm ON rm.member_id = m.referred_by_member_id
       LEFT JOIN users ru ON ru.user_id = rm.user_id
      ORDER BY m.member_id`);
  return Response.json(rows);
}

// Enrol a new member through the transactional stored procedure (users + members + subscription + payment).
export async function POST(req) {
  const { error } = await requireRole("ADMIN");
  if (error) return error;
  const b = await req.json();
  const conn = await poolFor("ADMIN").getConnection();     // OUT params need one connection
  try {
    await conn.query(
      "CALL sp_EnrollNewMember(?,?,?,?,?,?,?,?,?,?,?,@mid,@inv,@msg)",
      [b.full_name, b.email, b.phone, b.dob, b.gender || "Prefer Not to Say", b.emergency_name, b.emergency_phone,
       b.fitness_goal || "General Health & Fitness", b.plan_id, b.payment_method || "UPI", b.referred_by || null]);
    const [[out]] = await conn.query("SELECT @mid AS member_id, @inv AS invoice_no, @msg AS message");
    return Response.json(out, { status: out.member_id > 0 ? 201 : 400 });
  } finally { conn.release(); }
}
