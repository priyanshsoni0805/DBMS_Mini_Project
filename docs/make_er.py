import graphviz

T = {
 "roles": ["role_id|PK","role_name|UK","description","created_at"],
 "users": ["user_id|PK","role_id|FK","full_name","email|UK","password_hash","phone|UK","status","created_at"],
 "membership_plans": ["plan_id|PK","plan_name|UK","tier","duration_months","monthly_fee","total_price","max_classes_per_week","includes_personal_trainer","is_active"],
 "trainers": ["trainer_id|PK","user_id|FK,UK","specialization","experience_years","hourly_rate","rating","bio"],
 "members": ["member_id|PK","user_id|FK,UK","referred_by_member_id|FK","date_of_birth","gender","emergency_contact_name","emergency_contact_phone","fitness_goal","loyalty_points","joined_date"],
 "subscriptions": ["subscription_id|PK","member_id|FK","plan_id|FK","start_date","end_date","status","auto_renew","created_at"],
 "trainer_assignments": ["assignment_id|PK","member_id|FK","trainer_id|FK","assigned_date","session_count","status"],
 "payments": ["payment_id|PK","subscription_id|FK","member_id|FK","amount","payment_date","payment_method","payment_status","invoice_no|UK"],
 "gym_classes": ["class_id|PK","trainer_id|FK","class_name","room_number","capacity","schedule_day","start_time","duration_minutes"],
 "class_bookings": ["booking_id|PK","class_id|FK","member_id|FK","booking_date","booking_status","booked_at"],
 "attendance_logs": ["attendance_id|PK","member_id|FK","check_in_time","check_out_time","facility_zone"],
 "audit_logs": ["log_id|PK","action_type","table_name","record_id","old_value","new_value","performed_by","log_timestamp"],
}
COL = {"roles":"#E8EEF9","users":"#E8EEF9","members":"#E3F4E8","trainers":"#E3F4E8",
       "membership_plans":"#FFF1D6","subscriptions":"#FFF1D6","payments":"#FFF1D6",
       "trainer_assignments":"#F3E6F8","gym_classes":"#F3E6F8","class_bookings":"#F3E6F8",
       "attendance_logs":"#F3E6F8","audit_logs":"#EEEEEE"}

def node(name, cols):
    rows = f'<TR><TD COLSPAN="2" BGCOLOR="#1F3A5F"><FONT COLOR="white"><B>{name}</B></FONT></TD></TR>'
    for c in cols:
        n, k = (c.split("|")+[""])[:2]
        label = f"<U>{n}</U>" if "PK" in k else n
        kf = f'<FONT POINT-SIZE="9" COLOR="#555555">{k}</FONT>' if k else " "
        rows += f'<TR><TD ALIGN="LEFT" PORT="{n}">{label}</TD><TD ALIGN="LEFT">{kf}</TD></TR>'
    return f'<<TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" CELLPADDING="3" BGCOLOR="{COL[name]}">{rows}</TABLE>>'

g = graphviz.Digraph("ERD", format="png")
g.attr(rankdir="LR", splines="true", nodesep="0.5", ranksep="1.3", dpi="170", fontname="Helvetica",
       label="Gym Membership Manager - Entity Relationship Diagram (crow's foot notation)\nPK underlined | FK = foreign key | UK = unique", labelloc="t", fontsize="20")
g.attr("node", shape="plain", fontname="Helvetica", fontsize="11")
g.attr("edge", fontname="Helvetica", fontsize="10", color="#333333")
for n, c in T.items(): g.node(n, node(n, c))

# (parent, child, label)  parent 1 -> child N : tail=parent(one), head=child(crow)
E = [("roles","users","has"),("users","trainers","is a (1:1)"),("users","members","is a (1:1)"),
     ("members","members","refers"),("members","subscriptions","holds"),
     ("membership_plans","subscriptions","defines"),("subscriptions","payments","settled by"),
     ("members","payments","pays"),("members","trainer_assignments","assigned"),
     ("trainers","trainer_assignments","trains"),("trainers","gym_classes","teaches"),
     ("gym_classes","class_bookings","booked in"),("members","class_bookings","books"),
     ("members","attendance_logs","checks in")]
for p,c,l in E:
    one_to_one = "1:1" in l
    g.edge(p, c, label=l, arrowtail="tee", arrowhead="tee" if one_to_one else "crow", dir="both")
g.render("er_diagram", cleanup=True)
print("ok")
