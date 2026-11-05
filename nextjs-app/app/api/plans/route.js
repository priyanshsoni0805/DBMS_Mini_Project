import { poolFor } from "@/lib/db";
import { requireRole } from "@/lib/auth";

export async function GET() {
  const { session, error } = await requireRole();           // any logged-in role
  if (error) return error;
  const [rows] = await poolFor(session.role).query(
    "SELECT plan_id, plan_name, tier, duration_months, monthly_fee, total_price, max_classes_per_week, includes_personal_trainer FROM membership_plans WHERE is_active = TRUE");
  return Response.json(rows);
}
