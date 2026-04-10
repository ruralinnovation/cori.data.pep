# Release Calendar — cori.data.pep

## Source Information

| Field | Detail |
|---|---|
| **Full name** | U.S. Census Bureau Population Estimates Program (PEP) |
| **Producer** | U.S. Census Bureau |
| **Program page** | https://www.census.gov/programs-surveys/popest.html |
| **Release schedule** | https://www.census.gov/programs-surveys/popest/about/schedule.html |
| **Methodology (2020-2025)** | https://www2.census.gov/programs-surveys/popest/technical-documentation/methodology/2020-2025/methods-statement-v2025.pdf |
| **Data sets** | https://www.census.gov/programs-surveys/popest/data/data-sets.html |
| **Coverage** | County · 2000–present · Annual |

---

## Release Schedule

| Release | Typical timing | Notes |
|---|---|---|
| Annual estimates | May–June of following year | e.g., 2024 estimates released ~May 2025 |
| Vintage revisions | With each new annual release | Prior years revised; use S3 vintage snapshots to track changes |

---

## Vintage Log

| Vintage | Data covers | Captured | By | S3 path |
|---|---|---|---|---|
| vintage_2025 | 2000–2025 | 2026-04-09 | Drew | `s3://cori.data.pep/data_processed/vintage_2025/` |

*Add a new row each time a vintage is captured. Most recent at top.*

---

## Next Capture

| Field | Detail |
|---|---|
| **Expected release** | May/June 2025 (2024 estimates) |
| **Responsible** | Drew |
| **Watch page** | https://www.census.gov/programs-surveys/popest/about/schedule.html |

---

## Notes

- **Vintage boundaries:** Census publishes estimates in overlapping vintages
  (2000-2009, 2010-2019, 2020-present). Each new vintage may revise prior years
  within that decade. The 2000-2009 intercensal estimates are final and will not
  be revised.
- **pop_16plus caveat:** For 2007-2009, age 16+ is approximated as 15+ using
  intercensal age group data (direct AGE16PLUS not available in that vintage).
- **County boundary changes:** Some counties are restructured between vintages
  (e.g., Connecticut planning regions replacing counties in 2022+). The county
  crosswalk uses both 2019 and 2023 tigris boundaries to maximize coverage.
