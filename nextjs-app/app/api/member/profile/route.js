import { poolFor } from "@/lib/db";
import { requireRole } from "@/lib/auth";

export async function GET() {
  const { session, error } = await requireRole("MEMBER");
  if (error) return error;
  const [res] = await poolFor("MEMBER").query("CALL sp_GetMyProfile(?)", [session.userId]);
  return Response.json(res[0][0] || null);
}
