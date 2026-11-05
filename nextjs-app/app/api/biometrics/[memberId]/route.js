import { poolFor } from "@/lib/db";
import { biometrics } from "@/lib/mongo";
import { requireRole } from "@/lib/auth";

// MongoDB document read. Admin/trainer: any member. Member: only their own record.
export async function GET(_req, { params }) {
  const { session, error } = await requireRole();
  if (error) return error;
  const memberId = parseInt(params.memberId, 10);

  if (session.role === "MEMBER") {
    const [res] = await poolFor("MEMBER").query("CALL sp_GetMyProfile(?)", [session.userId]);
    if (!res[0][0] || res[0][0].member_id !== memberId) return Response.json({ error: "Forbidden" }, { status: 403 });
  }
  const doc = await (await biometrics()).findOne({ member_id: memberId }, { projection: { _id: 0 } });
  return doc ? Response.json(doc) : Response.json({ error: "No biometrics on file" }, { status: 404 });
}
