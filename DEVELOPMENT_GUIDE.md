# Practice Causality Exercises - Development Guide

**Quick Reference for Developers & Future Sessions**

---

## 📍 Start Here

This repository contains an **interactive causal inference teaching tool** with 5 complete scenarios, R data generation, DAG visualizations, and a web interface.

### Key Documents (Read in Order)

1. **SESSION_LOG.md** ← **START HERE** - Complete technical documentation of current state
2. **PRACTICE_README.md** - How the exercises are pedagogically designed
3. **README.md** (if exists) - General repository overview

---

## 🚀 Quick Status

| Aspect | Status | Location |
|--------|--------|----------|
| **5 Scenarios** | ✅ Working | `js/practice-causality-data.js` |
| **Data Files** | ✅ Generated | `practice-causality/data/` |
| **DAG Visualizations** | ✅ Generated | `practice-causality/images/` |
| **Web Interface** | ✅ Working | `practice.html` |
| **JavaScript** | ✅ Tested | `js/practice-causality.js` |
| **Documentation** | ✅ Complete | `SESSION_LOG.md`, `PRACTICE_README.md` |

---

## 📋 Common Tasks

### Task 1: Add a New Scenario (Scenario 6+)

**Time:** ~2-3 hours

**Steps:**
```
1. Open js/practice-causality-data.js
   └─ Add new scenario object with 3 questions (1 short answer, 2 MC)

2. Create R code in practice-causality/build_scenarios.R
   └─ Add data generation function with true causal structure

3. Run practice-causality/generate_dag_visualizations.R
   └─ This generates CSV data and DAG PNG automatically

4. Open js/practice-causality-answers.js
   └─ Add complete answer explanations with regression analysis

5. Update practice.html
   └─ Change scenario counter from 5 to 6

6. Test all 3 questions in browser
   ✓ Click each button
   ✓ Verify answer text shows
   ✓ Check images load
   ✓ Verify CSV download works

7. git add . && git commit -m "Add Scenario 6: [Your Scenario]"
```

**Template for new scenario:**
```javascript
{
  id: 6,
  title: "Scenario Title",
  subtitle: "Catchy subtitle",
  story: "3-4 sentences of engaging narrative mentioning all variables...",
  variables: ["Var1", "Var2", "Var3"],
  causalStructure: {
    description: "STRUCTURE TYPE (e.g., FORK / CONFOUNDER)",
    arrows: ["Var1 → Var2", "Var1 → Var3"],
    explanation: "..."
  },
  questions: [
    {
      id: 1,
      type: "short",
      prompt: "Draw the causal graph...",
      hint: "...",
      answer: "...",
      dagImage: "practice-causality/images/scenario6_dag.png"
    },
    { id: 2, type: "multiple-choice", ... },
    { id: 3, type: "multiple-choice", ... }
  ]
}
```

---

### Task 2: Fix a Button/Click Issue

**Symptom:** Buttons don't respond or answer text doesn't update

**Root Cause Checklist:**
- [ ] Using `onchange` on radio instead of `onclick` on container? → WRONG
- [ ] Handler not in global `questionData` object? → Check
- [ ] Missing `answerBox.classList.add('show')`? → Add it
- [ ] HTML special characters breaking attributes? → Use global object instead

**Solution:**
1. Check `js/practice-causality.js` lines 243-312 for how `handleMultipleChoice()` works
2. Ensure event handler is on `.option` div, not `<input>` element
3. Verify question data stored in global `questionData` object
4. Test in browser console: `questionData[2]` should show question data

**See:** SESSION_LOG.md "Major Issues Fixed This Session"

---

### Task 3: Update Scenario Content (Fix Explanations, etc.)

**Steps:**
```
1. For question changes:
   └─ Edit js/practice-causality-data.js
   └─ Modify question.prompt, question.explanation, question.options

2. For answer explanations:
   └─ Edit js/practice-causality-answers.js
   └─ Update trueModel, causalStructureDescription, regressionAnalysis, keyTakeaway

3. NO changes needed in JavaScript handlers (unless changing question type)

4. Test in browser and commit:
   git add . && git commit -m "Update Scenario X: [What changed]"
```

**Important:** Keep variable names consistent between story and questions!

---

### Task 4: Update CSS Styling

**Files:**
- `css/practice-causality.css` - All styling for practice page

**Key Classes:**
- `.option` - Multiple choice button styling
- `.answer-box` - Answer display box
- `.answer-correct` - Green background (correct answer)
- `.answer-incorrect` - Red background (wrong answer)
- `.download-btn-small` - Download button styling

---

### Task 5: Deploy/Host Online

**Current Setup:** Static files, works locally or on GitHub Pages

**To Deploy:**
```bash
# Option A: GitHub Pages
1. Push to GitHub branch `gh-pages`
2. Set repository settings to use gh-pages branch
3. Access at: https://username.github.io/repo-name/practice.html

# Option B: Any Static Hosting
1. Upload files to: index.html, practice.html, css/, js/, practice-causality/
2. No server-side processing needed
3. Works immediately
```

---

## 🔍 File Reference

### JavaScript (Interactivity)

| File | Purpose | Key Functions |
|------|---------|----------------|
| `js/practice-causality.js` | Main interactivity | `loadScenario()`, `handleMultipleChoice()`, `toggleShortAnswer()` |
| `js/practice-causality-data.js` | Scenario definitions | `scenarios` array with all content |
| `js/practice-causality-answers.js` | Answer explanations | `scenarioAnswers` array with full analysis |

### Data & Media

| Path | Contains | Count |
|------|----------|-------|
| `practice-causality/data/` | CSV datasets for practice | 5 files, 18-27 KB each |
| `practice-causality/images/` | DAG visualizations | 5 PNG files, 13-28 KB each |

### R Scripts

| File | Purpose |
|------|---------|
| `practice-causality/build_scenarios.R` | Define causal structures and data generation |
| `practice-causality/generate_dag_visualizations.R` | Run simulations, create DAGs, save CSVs |

### Documentation

| File | Purpose |
|------|---------|
| `SESSION_LOG.md` | **Technical documentation** - Read this first! |
| `PRACTICE_README.md` | Pedagogical documentation - How exercises teach |
| `DEVELOPMENT_GUIDE.md` | This file - Quick reference |

### HTML & CSS

| File | Purpose |
|------|---------|
| `practice.html` | Main practice interface |
| `index.html` | Landing page with all 3 content sections |
| `css/practice-causality.css` | All styling for practice page |

---

## 🧪 Testing Checklist

Before committing changes:

- [ ] Open `practice.html` in browser
- [ ] Navigate through all scenarios (previous/next buttons work)
- [ ] **Scenario 1:** Click each of 3 questions, answer text displays
- [ ] **Scenario 2:** Click each multiple choice option
- [ ] **Scenario 3:** Click "Show Answer" for short answer
- [ ] **Scenario 4:** Click CSV download - file should download
- [ ] **Scenario 5:** Click true model toggle - should expand/collapse
- [ ] Browser console shows no JavaScript errors
- [ ] All images load (check Images tab in DevTools)
- [ ] "Show Full Answer" button works at bottom

---

## 📞 Quick Debugging

### Problem: "Answer text doesn't appear after clicking"

**Check:**
```javascript
// In js/practice-causality.js handleMultipleChoice():
answerBox.classList.add('show');  // Must have this
```

### Problem: "Only first click works, second doesn't"

**Check:**
```html
<!-- WRONG (radio onchange):-->
<input type="radio" onchange="handler()">

<!-- RIGHT (div onclick):-->
<div class="option" onclick="handler()">
  <input type="radio">
</div>
```

### Problem: "Question doesn't load"

**Check:**
1. Browser console for errors
2. Check `scenarios` array is defined in practice-causality-data.js
3. Verify scenario index matches in scenarioAnswers array
4. Check variable names match between questions and answers

### Problem: "Image not loading"

**Check:**
```javascript
// In js/practice-causality-answers.js:
dagImage: "practice-causality/images/scenario5_dag.png"  // Correct path?
```

**Verify:** File exists at that location

---

## 🎯 Architecture Overview

```
User Interface (practice.html)
         ↓
   JavaScript Logic (practice-causality.js)
    ├─ Load Scenario Data
    │  └─ js/practice-causality-data.js (questions)
    ├─ Display Answers
    │  └─ js/practice-causality-answers.js (explanations)
    ├─ Render CSVs
    │  └─ practice-causality/data/*.csv
    └─ Display DAGs
       └─ practice-causality/images/*.png

Data Generation (R scripts)
    └─ generate_dag_visualizations.R
       ├─ Runs causal simulations
       ├─ Creates CSVs in practice-causality/data/
       ├─ Creates DAGs in practice-causality/images/
       └─ Documents true models
```

---

## 💡 Pro Tips

1. **Always read SESSION_LOG.md first** - It has all the context
2. **Keep story variable names EXACT** - If story says "BaselineSeverity", don't change to "Severity"
3. **Store complex data in JavaScript objects** - Never in HTML attributes
4. **Test button clicks manually** - Don't assume they work after changes
5. **Use browser DevTools** - Network tab for missing images, Console for JS errors
6. **Comment out code gradually** - To find which line breaks things
7. **Git commit frequently** - With descriptive messages

---

## 📚 Learning Resources

To understand the pedagogy:
- Read `PRACTICE_README.md` - Complete explanation of how exercises are designed
- See `SESSION_LOG.md` "Causal Structures" section - All 5 scenarios explained

To understand the technical implementation:
- Read `SESSION_LOG.md` "Major Issues Fixed" - Technical decisions and solutions
- Check `js/practice-causality.js` - Well-commented code with event handlers

---

## 🔄 Session Workflow

**When Starting New Work:**

1. **Read:** `SESSION_LOG.md` (current state overview)
2. **Clone:** Latest code from git
3. **Test:** Run through all 5 scenarios manually
4. **Edit:** Make your changes
5. **Test:** Re-run manual tests
6. **Commit:** With descriptive message
7. **Update:** SESSION_LOG.md if changes are significant

---

## ✅ Current Status

**Last Updated:** January 16, 2026
**Status:** ✅ FULLY FUNCTIONAL
**All 5 Scenarios:** ✅ Working
**All Buttons:** ✅ Responsive
**All Data:** ✅ Generated
**All Documentation:** ✅ Complete

**Ready for:**
- Student use
- Classroom teaching
- Further development
- Bug fixes or enhancements

---

## 🆘 Need Help?

1. **Technical issue?** → Check SESSION_LOG.md "Debugging Checklist"
2. **Want to add scenario?** → Follow "Task 1: Add a New Scenario" above
3. **Questions about pedagogy?** → Read PRACTICE_README.md
4. **Can't find something?** → Check "File Reference" section
5. **Still stuck?** → Look at working code examples in practice-causality-data.js

---

**This guide is your quick reference. SESSION_LOG.md is the complete documentation.**

**Good luck! 🚀**
