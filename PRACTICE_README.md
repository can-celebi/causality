# Practice Causal Inference Exercises

## Overview

This interactive practice tool teaches causal inference through story-based scenarios. Each scenario combines a real-world narrative, causal DAGs (Directed Acyclic Graphs), and empirical regression analysis to help students build intuition about when and how to control for variables.

## How These Exercises Are Created

### 1. **Conceptual Design: Define the Causal Structure**

Each scenario starts with a carefully designed causal relationship:

- **Scenario 1 (Coffee):** Chain/Mediator structure (A → B → C)
- **Scenario 2 (Education & Health):** Fork/Confounder structure (B ← A → C)
- **Scenario 3 (Talent & Success):** Collider structure (A → B ← C)
- **Scenario 4 (College Admission):** Complex (Fork + Chain)
- **Scenario 5 (Medical Treatment):** Complex (Confounder + Collider)

### 2. **R Simulation: Generate Synthetic Data**

Using R, we:
- Define the **true underlying model** with specific coefficients
- Generate **synthetic datasets** (500 observations per scenario) that follow these causal relationships
- Document the true parameter values for validation
- Save datasets as CSV files for student practice

**File:** `practice-causality/build_scenarios.R`

### 3. **Causal Graph Visualization: Create DAGs**

Using the `dagitty` R package:
- Define each causal structure as a DAG formula
- Generate visual graphs showing variable relationships
- Convert PDFs to PNG format for web display
- Place in `practice-causality/images/`

**File:** `practice-causality/generate_dag_visualizations.R`

### 4. **Regression Analysis: Run Estimations**

For each scenario, we:
- Run **correct** regression specifications (answer the research question properly)
- Run **incorrect** specifications (to show what goes wrong)
- Compare estimated coefficients to true underlying model
- Document the regression output and insights

**Example:** In Scenario 2 (Confounder):
- **Wrong:** `Health ~ Education` (ignores confounder SES) → biased estimate
- **Correct:** `Health ~ Education + SES` (controls for confounder) → unbiased estimate

### 5. **Question Design: Create Interactive Exercises**

For each scenario, we create 3 questions:

1. **Causal Graph Question (Short Answer)**
   - Students draw the causal graph
   - Answer includes the actual DAG image
   - Teaches visual representation of causality

2. **Regression Specification Question (Multiple Choice)**
   - Tests whether students know which variables to control for
   - Correct answer explains why the spec is right
   - Wrong answers show consequences of incorrect specification

3. **Causal Structure Identification (Multiple Choice)**
   - Tests understanding of mediators, confounders, or colliders
   - Reinforces key causal concepts

### 6. **Integration: Build Interactive Web Interface**

- Combine all elements into `practice.html`
- Load causal data from `js/practice-causality-data.js`
- Load regression results from `js/practice-causality-answers.js`
- Interactive handlers in `js/practice-causality.js`
- Styling from `css/practice-causality.css`

## Scenario Details

### Scenario 1: Coffee Shop Chronicles (Mediator/Chain)

**True Model:**
```
Caffeine = 15 + 25 × Coffee + ε
ExamScore = 45 + 3.5 × Caffeine + ε
```

**Key Insight:** Don't control for mediators! Coffee's effect flows THROUGH caffeine to exam scores. Controlling for caffeine blocks this pathway.

---

### Scenario 2: Climbing the Ladder (Confounder/Fork)

**True Model:**
```
Education = 10 + 0.4 × SES + ε
Health = 60 + 0.25 × SES + ε
```

**Key Insight:** MUST control for confounders. Without controlling for SES, the Education-Health relationship appears spuriously strong.

---

### Scenario 3: Hollywood Dreams (Collider)

**True Model:**
```
Talent ~ N(5, 2²) [independent]
HardWork ~ N(5, 2²) [independent]
Success = TRUE if Talent + HardWork > 8
```

**Key Insight:** In the full population, talent and hard work are independent. Among the successful, they become negatively correlated (collider bias). Never condition on colliders!

---

### Scenario 4: From Generation to Generation (Complex: Fork + Chain)

**True Model:**
```
StudentResources = 20 + 1.5 × ParentEducation + ε
StudentAptitude = 50 + 1.8 × ParentEducation + ε
GPA = 2.0 + 0.08 × StudentResources + 0.012 × StudentAptitude + ε
CollegeAdmission: Pr(Admission) = logistic(-3 + 1.5 × GPA)
```

**Key Insight:** Complex structures require careful thinking. Control for confounders, but NOT for mediators, depending on your research question.

---

### Scenario 5: Medical Treatment (Complex: Confounder + Collider)

**True Model:**
```
SeverityScore = rnorm(n, 50, 15)  [baseline disease severity]
TreatmentReceived = ifelse(SeverityScore > 55, 1, 0)  [treated if severe]
Recovery = 70 + (-0.5) × TreatmentReceived + 0.3 × SeverityScore + ε
Hospitalization = ifelse(Recovery < 60, 1, 0)  [collider on Treatment & Recovery]
```

**Key Insight:** Observational data often has BOTH confounding AND collider bias. SeverityScore confounds the Treatment-Recovery relationship. Hospitalization is a collider—conditioning on it creates spurious correlation. Careful causal reasoning required!

---

## File Structure

```
practice-causality/
├── images/
│   ├── scenario1_dag.png
│   ├── scenario2_dag.png
│   ├── scenario3_dag.png
│   ├── scenario4_dag.png
│   └── scenario5_dag.png
├── data/
│   ├── scenario1_data.csv      (500 rows)
│   ├── scenario2_data.csv      (500 rows)
│   ├── scenario3_data.csv      (500 rows)
│   ├── scenario4_data.csv      (500 rows)
│   └── scenario5_data.csv      (500 rows)
├── build_scenarios.R            (Define causal structures & generate data)
└── generate_dag_visualizations.R (Create DAGs & run regression analysis)

js/
├── practice-causality-data.js    (Scenario definitions & questions)
├── practice-causality-answers.js (True models & regression results)
└── practice-causality.js         (Interactive handlers)

css/
└── practice-causality.css        (Styling)

practice.html                      (Main interface)
```

## How to Use This in Teaching

### For Instructors:

1. **Pedagogical Approach:** Start with Scenarios 1-3 to teach basic causal concepts, then move to Scenarios 4-5 for complex cases
2. **Timing:** ~15-20 minutes per scenario
3. **Assessment:** Use the questions to gauge student understanding
4. **Data Practice:** Have students download CSVs and reproduce the regression results in R

### For Students:

1. **Read the Story** - Understand the real-world context
2. **Answer Q1** - Draw the causal graph and check your answer against the DAG image
3. **Try the CSV Data** - Download and run regressions yourself to verify the results
4. **Answer Q2 & Q3** - Test your understanding of which variables to control for
5. **Show Full Answer** - Review the complete regression analysis and key insights

## Feedback & Future Improvements

⚠️ **Under Construction:** These exercises are newly built and AI-generated. Please report:
- Factual errors in the scenarios or explanations
- Unclear questions or confusing answer language
- Suggestions for additional scenarios or improvements
- Your experience using this tool in teaching/learning

## References & Resources

- **Causal Inference Book:** Pearl, J. (2009). *Causality: Models, Reasoning, and Inference*
- **Dagitty:** Textbook & tool at [dagitty.net](https://www.dagitty.net)
- **Causal Inference with R:** Grayling, M. (2020). *Causal Inference with R*

---

**Created:** January 2026 | **Last Updated:** January 16, 2026
