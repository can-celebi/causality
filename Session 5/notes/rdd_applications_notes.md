# RDD Applications Database — Notes

## Source
Extracted from two canonical survey papers:
- **Lee & Lemieux (2010)** "Regression Discontinuity Designs in Economics", *Journal of Economic Literature* 48(2): 281–355. [PDF: Session 5/lee_lemieux_2010.pdf]
- **Cattaneo & Titiunik (2022)** "Regression Discontinuity Designs", *Annual Review of Economics* 14: 821–851. [PDF: Session 5/cattaneo_titiunik_2022.pdf]

Plus the two Session 5 case study papers (Carpenter & Dobkin 2009, Klašnja & Titiunik 2017).

## File
`Session 5/rdd_applications_database.csv` — 91 rows, 13 columns.

## Column Descriptions
| Column | Description |
|--------|-------------|
| `id` | Unique row identifier |
| `authors` | Author names |
| `year` | Publication year |
| `field` | Economics subfield (Education, Labor, Health, Political Economy, Crime, Environment, etc.) |
| `running_variable` | The continuous variable that determines treatment |
| `cutoff` | The threshold value |
| `treatment` | What happens when crossing the cutoff |
| `outcome` | What's measured |
| `finding` | Key result in one sentence |
| `sharp_fuzzy` | Sharp, Fuzzy, or Kink |
| `country` | Country/context |
| `variant` | RDD variant (Standard, Geographic, Maimonides' Rule, Donut hole, etc.) |
| `source` | Which survey paper(s) mentioned it |

## Summary Statistics
- **91 unique applications** spanning 1960–2018
- **Fields**: Education (27), Labor (11+), Political Economy (10), Health (8), Crime (5), Environment (4), Development (6), others
- **Countries**: US dominates (53), then Austria (4), Israel (4), Mexico (4), plus 17 other countries
- **Design**: 52 Fuzzy, 38 Sharp, 1 Kink
- **Running variables**: Age/birthdate (30), test scores (19), geographic location (13), vote share (12), enrollment/population (7)

## Pedagogical Use
This database can serve as:
1. **"What's the RDD here?" exercises** — give students the context, ask them to identify running variable, cutoff, treatment, outcome
2. **Design critique exercises** — ask students to evaluate whether the RDD assumptions hold (manipulation? continuity?)
3. **Classification exercises** — sharp vs fuzzy? What's the running variable type?
4. **Cross-field comparison** — how does the same method look different across education, health, crime, politics?

## Common Running Variable Categories (from Lee & Lemieux 2010, Section 6.2)
1. **Necessary discretization**: enrollment → class size, age → grade cohort, votes → winner
2. **Compensatory/equalizing rules**: poverty → aid, test scores → remediation
3. **Intentional targeting**: pollution → regulation, crime risk → security level
