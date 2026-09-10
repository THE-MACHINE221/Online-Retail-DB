# Original university project (2024)

**Contributors: Mohammad Alseadoon and Khalid Alsaab.**

This folder preserves the original ten-table schema, five views, and two diagrams for comparison with the portfolio revision. SQL was extracted from the final RTF documents; the typographic dash before the table-creation heading was changed to a SQL comment and trailing whitespace was removed. No student IDs are included.

These historical SQL files are Oracle-style and are not executed by the SQLite demo or CI. They are not a second supported implementation. The five views retain `WITH CHECK OPTION` as written for the assignment. The original single-product order model, category-based sizing, and returns without a purchase reference are preserved here as historical limitations.

## Files

- [Original schema](schema.sql)
- [Original five views](views.sql)
- [Relational schema diagram](schema-diagram.png)
- [Conceptual ER diagram](er-diagram.png)

## Source coverage

All ten source files were reviewed before this publication:

| Source file | How it informed this repository |
|---|---|
| `DML AND DDL/Tables Creation.rtf` | Source of the historical schema |
| `DML AND DDL/Views Creation.rtf` | Source of the five historical views |
| `DML AND DDL/Data Insertion.rtf` | Reviewed entity coverage and sample relationships; replaced by a new synthetic fixture |
| `Schema AND ER/Screenshot 2024-11-18 at 2.26.40 AM.png` | Preserved as the relational schema diagram |
| `Schema AND ER/Screenshot 2024-11-23 at 8.11.45 AM.png` | Preserved as the conceptual ER diagram |
| `IT_Project_Doc.docx` | Reviewed requirements, DDL, views, DML, query examples, and normalization discussion |
| `IT_Project_Doc_pdf.pdf` | Reviewed the 23-page report and diagrams |
| `IT_Project_Presentation.pptx` | Reviewed slide text and embedded SQL/result images |
| `IT_Project_Presentation_pdf.pdf` | Reviewed the 16-page presentation export |
| `Database_Design_Requirement_Template.docx` | Confirmed the original assignment scope: at least ten tables, five views, DML, ER modeling, and normalization |

Some presentation screenshots use alternative names such as `Address_Key` and `Neighborhood`, while the final RTF schema uses `Add_Key` and `N_B`. The final RTF files are the source of record for this archive. The report also contains query identifier inconsistencies discussed in the revision's design notes.

Original reports and presentations are not republished because their covers and embedded examples include personal identifiers or contact-like values. The assignment template is described rather than redistributed. The revised demo uses new, clearly fictional customers and records.
