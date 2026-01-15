# GitHub Pages Access Information

## Repository Details
- **Repository**: https://github.com/can-celebi/causality
- **Repository Type**: Project Repository
- **Main Branch**: `main`

## GitHub Pages Deployment

### Expected URLs:
Since the repository is configured as a project site (not a user/organization site), GitHub Pages will serve content from:

```
https://can-celebi.github.io/causality/
```

### Specific Page URLs:
- **Main Landing Page** (downloads + practice link):
  ```
  https://can-celebi.github.io/causality/
  ```

- **Practice Causality Page**:
  ```
  https://can-celebi.github.io/causality/practice.html
  ```

### How to Enable GitHub Pages (if not already enabled):

1. Go to: https://github.com/can-celebi/causality/settings/pages
2. Under "Build and deployment":
   - Source: Select "Deploy from a branch"
   - Branch: Select "main" + "/(root)"
3. Save

## What's Accessible via GitHub Pages:

✅ **index.html** - Main landing page with:
  - Session 1 download button
  - Session 1.5 download button (with live session script badge)
  - Practice Causality link

✅ **practice.html** - Interactive practice page with:
  - 4 causal inference scenarios
  - Story-based exercises
  - Multiple choice questions
  - Show/Hide answer buttons
  - Embedded causal DAG images
  - Regression analysis results
  - Full explanations

✅ **CSS Files**:
  - css/landing-page.css
  - css/practice-causality.css

✅ **JavaScript Files**:
  - js/practice-causality-data.js (scenario definitions)
  - js/practice-causality-answers.js (answer explanations + regression results)
  - js/practice-causality.js (interactive logic)

✅ **Images**:
  - practice-causality/images/scenario1_dag.png
  - practice-causality/images/scenario2_dag.png
  - practice-causality/images/scenario3_dag.png
  - practice-causality/images/scenario4_dag.png

## Directory Structure on GitHub:

```
causality/ (repo root on GitHub)
├── index.html                          (main landing page)
├── practice.html                       (practice exercises)
├── css/
│   ├── landing-page.css
│   └── practice-causality.css
├── js/
│   ├── practice-causality-data.js
│   ├── practice-causality-answers.js
│   └── practice-causality.js
├── practice-causality/
│   ├── images/
│   │   ├── scenario1_dag.png
│   │   ├── scenario2_dag.png
│   │   ├── scenario3_dag.png
│   │   └── scenario4_dag.png
│   ├── build_scenarios.R              (not accessible via web)
│   ├── generate_dag_visualizations.R  (not accessible via web)
│   └── scenarios.json                 (not accessible via web)
├── Session 1/
│   └── causality/R/session1/          (downloadable via GitHub)
└── Session 1.5 (optional session)/
    └── R/                             (downloadable via GitHub)
```

## Testing the Pages:

After enabling GitHub Pages, wait 1-2 minutes and then test:

1. **Main Page**: Visit https://can-celebi.github.io/causality/
   - Should see "R Sessions: Introduction & Causal Inference" title
   - Session 1, Session 1.5, and Practice sections visible

2. **Practice Page**: Click "Start Interactive Practice" or visit
   https://can-celebi.github.io/causality/practice.html
   - Should see "Practice Causal Inference" header
   - Story loads below
   - Questions display
   - "Show Full Answer" button reveals complete answers with DAG images

## Current Git Status:

✅ All files committed to main branch
✅ Pushed to GitHub (commit: e7f6f02)
✅ DAG images (PNG) included in repo
✅ Regression results embedded in JavaScript
✅ Ready for GitHub Pages deployment

## Notes:

- The CEU directory is now the **root of the GitHub repository**
- Local folder structure (Session 1, Session 1.5, Operational) is preserved
- Download buttons link to GitHub directories using download-directory.github.io service
- Practice exercises are fully self-contained (no external API calls)
- All answers and DAGs are embedded in the HTML/JavaScript (no separate API needed)
