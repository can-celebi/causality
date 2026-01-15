# Causal Graphs and Structural Causal Models

## Introduction: Why Simulate Data?

In causal inference, we often face a fundamental challenge: **we don't know the true causal structure**. One of the most powerful learning tools is **simulation**—artificially generating data where we *know* the ground truth.

### Three Reasons to Simulate:

1. **Know the Truth**: When we generate data from a known causal structure, we can verify whether our methods (like regression) correctly recover the causal effects.

2. **Test Methods**: We can see which regression specifications give us biased vs. unbiased estimates, and understand why.

3. **Build Intuition**: Before seeing real data, simulation helps us understand the mechanics of confounding, mediation, and collider bias.

### Basic Simulation Techniques:

- **Continuous variables**: Use `rnorm()` to generate normally distributed data
- **Binary/Categorical variables**: Use `sample()` or `ifelse()` to generate discrete outcomes
- **Causal relationships**: Generate each variable deterministically (or mostly deterministically) from its causes, then add noise

Example:
```r
set.seed(12345)
A <- rnorm(n = 1000, mean = 100, sd = 15)  # A is exogenous
B <- 50 + 0.75 * A + rnorm(n = 1000, mean = 0, sd = 10)  # B depends on A
```

---

## Structural Causal Models (SCMs)

A **Structural Causal Model** formally specifies causal relationships. It has three components:

### 1. Exogenous Variables (U)
These are the "starting points"—variables with no causes in our model. They have randomness (noise) but no parents.

Example: `U_education` = educational genes, parental encouragement, etc. (things we don't model)

### 2. Endogenous Variables (V)
These are the variables we study. Each endogenous variable is caused by other variables (exogenous or endogenous).

Example: `V_income`, `V_health`, `V_satisfaction`

### 3. Structural Functions (f)
These are the causal mechanisms. For each endogenous variable, we specify: **how it depends on its causes**.

**Formal notation:**

For an endogenous variable V_i:

$$V_i := f_i(PA_i, U_i)$$

Where:
- $V_i$ = the variable
- $:=$ = "is determined by" (not just correlated)
- $PA_i$ = the parents (causes) of V_i
- $U_i$ = exogenous noise
- $f_i$ = the structural function

**In R, we implement this literally:**

```r
# For example: health_score depends on education and exogenous noise
health_score := f(education_years, U_health)
health_score <- 50 + 2 * education_years + rnorm(n, mean = 0, sd = 5)
```

---

## Four Types of Causal Graphs

In impact evaluation, we encounter four fundamental causal graph structures. Understanding each one helps us know whether to control for a variable or not.

---

### 1. Simple Causal Relationship (A → B)

**Structure**: A directly causes B. No confounding.

**Diagram**:
```
    A ───→ B
```

**Structural Equations**:
- $U_A \to A$
- $A, U_B \to B$
- $B := f(A, U_B) = \beta_0 + \beta_1 \cdot A + U_B$

**Plain Language**:
Variable A has a direct causal effect on B. There are no other causes they share, and no other complicating factors.

**Intuition & Incentive**:
This is the "clean" case. When you want to measure the effect of A on B, just regress B on A. Simple regression works perfectly.

**Example**: Does additional classroom instruction (A) improve test scores (B)? Yes, directly.

**When to Control**:
- ✓ **Do NOT control** for other variables (unless they're caused by A and affect B through other paths)
- ✓ **Regression specification**: `lm(B ~ A)`

---

### 2. Fork / Common Cause / Confounder (A → B and A → C)

**Structure**: A causes both B and C. A is a "common cause" or **confounder**.

**Diagram**:
```
        A
       / \
      ↓   ↓
      B   C
```

**Structural Equations**:
- $U_A \to A$
- $A, U_B \to B$: $B := \beta_1 \cdot A + U_B$
- $A, U_C \to C$: $C := \gamma_1 \cdot A + U_C$

**Plain Language**:
A affects both B and C. If you don't account for A, B and C will appear correlated—not because B causes C (or vice versa), but because they share a common cause.

**Intuition & Incentive**:
Think of education as the common cause:
- Education (A) → Income (B): More education → higher income
- Education (A) → Health (C): More education → better health

If you regress Health on Income without controlling for Education, you'll see a positive correlation. You might think income improves health. But actually, **education** is the real driver of both. Income and health aren't directly related; they just share a cause.

**Key Insight**:
Without controlling for A, the regression of C on B will show a **spurious relationship**—biased upward (or downward) because of the confounder.

**When to Control**:
- ✓ **MUST control** for A when estimating the effect of B on C
- ✓ **Regression specification**: `lm(C ~ B + A)` ← include A as a covariate

**Example**:
```r
# Without education, income and health appear correlated
lm(health ~ income)  # ✗ WRONG—biased estimate

# With education, they're unrelated (the confounder is accounted for)
lm(health ~ income + education)  # ✓ CORRECT—unbiased estimate
```

---

### 3. Chain / Intermediate Variable / Mediator (A → B → C)

**Structure**: A causes B, and B causes C. B is the **mechanism** or **mediator**.

**Diagram**:
```
    A ───→ B ───→ C
```

**Structural Equations**:
- $U_A \to A$
- $A, U_B \to B$: $B := \beta_1 \cdot A + U_B$
- $B, U_C \to C$: $C := \gamma_1 \cdot B + U_C$

**Plain Language**:
A affects C, but the effect flows **through** B. The chain of causation is: A → (causes) B → (causes) C.

**Intuition & Incentive**:
Imagine exercise and life satisfaction:
- Exercise (A) → Fitness (B): More exercise → better fitness
- Fitness (B) → Satisfaction (C): Better fitness → more life satisfaction

The reason exercise improves life satisfaction is *because* it improves fitness. Fitness is the mechanism—the pathway through which exercise works.

**Key Insight**:
If you control for B (fitness), you **block the pathway**. You'll see no effect of A on C, even though A truly does affect C (through B).

**When to Control**:
- ✗ **Do NOT control** for B if your goal is to measure the total effect of A on C
- ✓ **Regression for total effect**: `lm(C ~ A)` ← gives you A → B → C
- ✓ **Regression for direct effect only**: `lm(C ~ A + B)` ← gives effect of A not through B

**Example**:
```r
# Total effect: exercise improves satisfaction
lm(satisfaction ~ exercise)  # ✓ CORRECT—shows total effect

# If we control for fitness, we block the mechanism
lm(satisfaction ~ exercise + fitness)  # ✗ WRONG—effect disappears!
```

**Caution**: Students often confuse "controlling for B" with "accounting for confounding." Here, B is not a confounder; it's the causal mechanism. Controlling for it is wrong for estimating total effects.

---

### 4. Collider (B → A ← C)

**Structure**: Both B and C cause A. A is the "collision point."

**Diagram**:
```
      B       C
       \     /
        ↓   ↓
         A
```

**Structural Equations**:
- $U_B \to B$
- $U_C \to C$
- $B, C, U_A \to A$: $A := \beta_1 \cdot B + \gamma_1 \cdot C + U_A$ (often: A is a binary outcome, e.g., got the job)

**Plain Language**:
Both B and C independently cause A. In the overall population, B and C are independent. But if you condition on A (look only at cases where A is true), B and C become **artificially correlated**.

**Intuition & Incentive**:
Programming skill (B) and communication skill (C) are independent—some people are great programmers but poor communicators, others are the opposite, and many are balanced.

Now, consider getting hired for a tech job (A). To get hired, you need to excel in at least one skill:
- Strong programmer + weak communicator? → Hired ✓
- Weak programmer + strong communicator? → Hired ✓
- Weak in both? → Not hired ✗

Among those who were hired, if someone has weak programming, they almost certainly had strong communication (to compensate). This creates a **negative correlation** inside the "hired" group, even though they're uncorrelated in the general population.

**Key Insight**:
If you condition on A (filter your data to only A=1), you create a spurious negative correlation between B and C.

**When to Control**:
- ✗ **Do NOT control** for A (don't condition on the collider)
- ✓ **Correct specification**: `lm(C ~ B)` using the full population
- ✗ **Wrong specification**: `lm(C ~ B, data = subset_where_A_is_1)` ← creates bias!

**Example**:
```r
# Full population: B and C uncorrelated
cor(programming, communication)  # ≈ 0 ✓ CORRECT

# Among the hired: B and C appear negatively correlated
hired_people <- subset(df, hired == 1)
cor(hired_people$programming, hired_people$communication)  # ≈ -0.4 ✗ WRONG!
```

**Real-world examples of collider bias**:
- **Attractiveness and intelligence**: Both help you become a celebrity, but they're independent in the general population. Among celebrities, they seem negatively correlated (because less attractive celebrities must be exceptionally intelligent to make it).
- **Selection bias in studies**: If you only study hospital patients, disease (A) is caused by both symptom severity (B) and treatment-seeking behavior (C). Even if they're independent in the population, they'll correlate in your hospital sample.

---

## Summary Table: When to Control

| Graph Type | When to Control for A? | Specification |
|---|---|---|
| **Simple** (A→B) | Don't control | `lm(B ~ A)` |
| **Fork** (A←→B,C) | **MUST control** | `lm(C ~ B + A)` |
| **Chain** (A→B→C) | Don't control (if you want total effect) | `lm(C ~ A)` |
| **Collider** (B→A←C) | **Do NOT control** | `lm(C ~ B)` on full data |

---

## Why This Matters for Your Problem Set

**Question 1** asks you to **draw causal graphs** and identify confounders, mediators, and colliders. Understanding these four structures is essential for that task.

**Question 2** uses real educational data (STAR experiment). You'll need to:
- Identify which variables are confounders (controls needed)
- Avoid controlling for mediators
- Be aware of collider bias in your sample selection

The simulation code in `00_causal_graph_simulations.R` demonstrates each structure. Run that code to see:
- How regression estimates change based on whether you control for A
- Why the choice matters
- How to interpret the bias

---

## Next Steps

1. **Run** `00_causal_graph_simulations.R` to see these structures in action
2. **Study** `01_data_generation.R` to see realistic examples with demographics
3. **Practice** with `02_practice_fundamentals.R` to apply R techniques to these datasets
4. **Formalize** with `03_dag_analysis.R` using the dagitty package
5. **Understand randomization** with `04_randomization_simulation.R`
