#!/usr/bin/env python3
"""
Build Fresh DBMS Mini Project Report DOCX
Fixes all inconsistencies (Priyansh Soni PES1UG24CS344 & Pulkit Bhardwaj PES1UG24CS346).
Inserts all real terminal & verification screenshots (Figures 7.1, 7.5 - 7.13).
Removes all uncaptured placeholder boxes.
Updates rubrics and saves final report.
"""

import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

SRC_DOCX = "PES1UG24CS346_DBMS_Mini_Project_Report.docx"
OUT_DOCX_TEAM = "PES1UG24CS344_PES1UG24CS346_DBMS_Mini_Project_Report.docx"
OUT_DOCX_ORIG = "PES1UG24CS346_DBMS_Mini_Project_Report.docx"

doc = docx.Document(SRC_DOCX)

# -----------------------------------------------------------------------------
# 1. Update Table 0 (Title Page details)
# -----------------------------------------------------------------------------
t0 = doc.tables[0]
t0.rows[4].cells[0].text = "Student 1"
t0.rows[4].cells[1].text = "Priyansh Soni (SRN: PES1UG24CS344)"

t0.rows[5].cells[0].text = "Student 2"
t0.rows[5].cells[1].text = "Pulkit Bhardwaj (SRN: PES1UG24CS346)"

# Add Institution row before Submission
new_row = t0.add_row()
new_row.cells[0].text = t0.rows[6].cells[0].text
new_row.cells[1].text = t0.rows[6].cells[1].text
t0.rows[6].cells[0].text = "Institution"
t0.rows[6].cells[1].text = "PES University, Bengaluru"

# -----------------------------------------------------------------------------
# 2. Fix Text Inconsistencies across Paragraphs
# -----------------------------------------------------------------------------
for p in doc.paragraphs:
    if "-- Student: Pulkit Bhardwaj" in p.text:
        p.text = "-- Students: Priyansh Soni (SRN: PES1UG24CS344), Pulkit Bhardwaj (SRN: PES1UG24CS346)"
    elif "Sarah Jenkins" in p.text and "sjenkins@fitpulse.com" in p.text:
        p.text = p.text.replace("Sarah Jenkins", "Priyansh Soni").replace("sjenkins@fitpulse.com", "priyansh.admin@fitpulse.com")
    elif "Pulkit Bhardwaj" in p.text and "Student:" in p.text:
        p.text = p.text.replace("Student: Pulkit Bhardwaj (SRN: PES1UG24CS346)", "Students: Priyansh Soni (PES1UG24CS344), Pulkit Bhardwaj (PES1UG24CS346)")

# -----------------------------------------------------------------------------
# 3. Restructure Section 7 (Replace Placeholders with Real Screenshots)
# -----------------------------------------------------------------------------
body = doc._body._element

sec7_heading_idx = -1
sec8_heading_idx = -1

for idx, child in enumerate(body):
    tag = child.tag.split("}")[-1]
    if tag == "p":
        p = docx.text.paragraph.Paragraph(child, doc)
        if p.style.name == "Heading 1":
            if "7. Sample Screenshots" in p.text:
                sec7_heading_idx = idx
            elif "8. Evaluation Rubrics" in p.text:
                sec8_heading_idx = idx
                break

print(f"Found Section 7 Heading at child {sec7_heading_idx}, Section 8 Heading at child {sec8_heading_idx}")

# Update Section 7 introductory text (child right after heading)
intro_child = body[sec7_heading_idx + 1]
intro_p = docx.text.paragraph.Paragraph(intro_child, doc)
intro_p.text = (
    "This section presents live execution and verification screenshots captured directly "
    "from the database and terminal environment using macOS native tools (`screencapture`), "
    "demonstrating the 12-table relational schema, seed data, SQL analytical queries, stored "
    "procedures, functions, database triggers, database-level RBAC, MongoDB document store, "
    "Python vector similarity engine, and overall multi-model system integration. Uncaptured "
    "interactive web UI dashboards have been omitted from placeholders to maintain report integrity."
)

# Keep Figure 7.1 (paragraphs at sec7_heading_idx + 2 and + 3)
# Elements from sec7_heading_idx + 4 to sec8_heading_idx - 1 are the placeholder tables and text
to_remove = []
for idx in range(sec7_heading_idx + 4, sec8_heading_idx):
    to_remove.append(body[idx])

print(f"Removing {len(to_remove)} placeholder elements between Section 7 and Section 8...")
for elem in to_remove:
    body.remove(elem)

# Section 8 heading element
sec8_elem = body[sec8_heading_idx - len(to_remove)]

# Define new screenshots to insert: (image_path, figure_label, caption_text, width_inches)
figures = [
    (
        "screenshots/fig_7_sql_queries.png",
        "Figure 7.5",
        "SQL query results: active member financial profiles and multi-table subscription join",
        6.2
    ),
    (
        "screenshots/fig_7_mongodb_results.png",
        "Figure 7.6",
        "MongoDB: member health flags query and wearable biometric aggregation pipeline",
        6.2
    ),
    (
        "screenshots/fig_7_vector_db_results.png",
        "Figure 7.7",
        "Vector DB: 44-dim embeddings generation, top-k cosine similarity queries, update, and delete",
        6.2
    ),
    (
        "screenshots/fig_7_rbac_security.png",
        "Figure 7.8",
        "MySQL RBAC: roles, privileges, and SHOW GRANTS statements for admin, trainer, and member",
        6.2
    ),
    (
        "screenshots/fig_7_advanced_sql.png",
        "Figure 7.9",
        "Stored procedures (sp_GetGymExecutiveKPIs), functions (loyalty discounts), and trigger audit logs",
        6.2
    ),
    (
        "docs/er_diagram.png",
        "Figure 7.10",
        "Entity-Relationship (ER) Diagram: 12 normalized relational entities with PK, FK, and UK constraints",
        6.2
    ),
    (
        "screenshots/fig_7_cte_results.png",
        "Figure 7.11",
        "CTE results: plan tier spending benchmark analysis and recursive member referral tree hierarchy",
        6.2
    ),
    (
        "screenshots/fig_7_seed_data.png",
        "Figure 7.12",
        "Relational seed data verification: record counts across all 12 normalized database tables",
        6.0
    ),
    (
        "screenshots/fig_7_project_summary.png",
        "Figure 7.13",
        "Integration summary: multi-model system health check (MySQL + MongoDB + Python Vector Search)",
        6.2
    ),
]

# Insert figures before Section 8 heading
for img_path, fig_id, caption, width in figures:
    if not os.path.exists(img_path):
        print(f"WARNING: Image not found: {img_path}")
        continue
    
    # 1. Image paragraph
    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_img.paragraph_format.space_before = Pt(8)
    p_img.paragraph_format.space_after = Pt(4)
    run_img = p_img.add_run()
    run_img.add_picture(img_path, width=Inches(width))

    # 2. Caption paragraph
    p_cap = doc.add_paragraph()
    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cap.paragraph_format.space_before = Pt(2)
    p_cap.paragraph_format.space_after = Pt(14)
    run_label = p_cap.add_run(f"{fig_id} - ")
    run_label.bold = True
    run_label.font.size = Pt(9.5)
    run_label.font.color.rgb = RGBColor(0x33, 0x33, 0x33)
    
    run_desc = p_cap.add_run(caption)
    run_desc.italic = True
    run_desc.font.size = Pt(9.5)
    run_desc.font.color.rgb = RGBColor(0x55, 0x55, 0x55)

    # Move both before Section 8 heading element
    sec8_elem.addprevious(p_img._p)
    sec8_elem.addprevious(p_cap._p)

print("Inserted all figure screenshots and captions.")

# -----------------------------------------------------------------------------
# 4. Update Rubric Table (Section 8)
# -----------------------------------------------------------------------------
t_rubric = doc.tables[-1]

rubric_updates = {
    1: ("Complete", "Section 4.1 (Fig 4.1), Fig 7.10, docs/er_diagram.png"),
    2: ("Complete", "Section 4.2"),
    3: ("Complete", "database/01_ddl_schema.sql, Fig 7.12"),
    4: ("Complete", "database/05_nosql_mongodb.js, database/06_vector_database.py, Figs 7.6, 7.7"),
    5: ("Complete", "Section 3"),
    6: ("Complete", "database/02_dml_seed.sql, Fig 7.12"),
    7: ("Complete", "database/03_queries_joins_nested.sql, database/04_advanced_sql.sql, Figs 7.5, 7.11"),
    8: ("Complete", "database/04_advanced_sql.sql, Figs 7.9, 7.11"),
    9: ("Complete", "database/05_*.js, database/06_*.py, Figs 7.1, 7.6, 7.7, 7.13"),
    10: ("Built & verified", "nextjs-app/app/* (live viva demo)"),
    11: ("Complete", "nextjs-app/app/api/*, lib/*, Fig 7.13"),
    12: ("Complete", "middleware.js, lib/auth.js, database/07_rbac_security.sql, Fig 7.8"),
    13: ("Complete", "README.md, reports/, SUMMARY.md, Git repository"),
    14: ("Ready for viva", "Both team members (Priyansh & Pulkit) ready for examination"),
}

for row_idx, (status, where) in rubric_updates.items():
    if row_idx < len(t_rubric.rows):
        t_rubric.rows[row_idx].cells[3].text = status
        t_rubric.rows[row_idx].cells[4].text = where

# -----------------------------------------------------------------------------
# 5. Save Fresh Documents
# -----------------------------------------------------------------------------
doc.save(OUT_DOCX_TEAM)
print(f"Saved {OUT_DOCX_TEAM} ({os.path.getsize(OUT_DOCX_TEAM)} bytes)")

doc.save(OUT_DOCX_ORIG)
print(f"Updated {OUT_DOCX_ORIG} ({os.path.getsize(OUT_DOCX_ORIG)} bytes)")

print("Report generation completed successfully!")
