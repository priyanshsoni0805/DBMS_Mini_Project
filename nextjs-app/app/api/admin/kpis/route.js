import { poolFor } from "@/lib/db";
import { requireRole } from "@/lib/auth";

export async function GET() {
  const { error } = await requireRole("ADMIN");
  if (error) return error;
  const [res] = await poolFor("ADMIN").query("CALL sp_GetGymExecutiveKPIs()");
  return Response.json(res[0][0]);
}
