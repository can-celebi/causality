# ============================================================================
# Build Causal Scenarios for Interactive Practice
# ============================================================================
# This script creates causal scenarios with:
# - Causal DAGs using dagitty
# - Generated synthetic data
# - Regression analyses
# - Visualization of causal graphs
# ============================================================================

library(dagitty)
library(ggplot2)

set.seed(42)

# ============================================================================
# SCENARIO 1: CAUSAL CHAIN (Mediator)
# ============================================================================
# Story: Coffee consumption → caffeine level → exam performance
# Chain: Coffee → Caffeine → ExamScore

scenario_1 <- list(
  name = "Coffee Shop Chronicles",
  title = "Caffeine and Exam Success",
  dag_formula = "dag {
    Coffee -> Caffeine
    Caffeine -> ExamScore
  }",
  data_generation = function(n = 500) {
    # Exogenous: coffee consumption (cups per day)
    coffee <- rnorm(n, mean = 2.5, sd = 1.2)

    # Mediator: caffeine level in bloodstream (depends on coffee)
    caffeine <- 15 + 25 * coffee + rnorm(n, mean = 0, sd = 5)

    # Outcome: exam score (depends on caffeine, not directly on coffee)
    exam_score <- 45 + 3.5 * caffeine + rnorm(n, mean = 0, sd = 8)

    data.frame(
      Coffee = coffee,
      Caffeine = caffeine,
      ExamScore = exam_score
    )
  },
  story = "Meet Sarah, a graduate student who swears by her morning coffee ritual. Over the past semester, she's noticed something: the more coffee she drinks before her exams, the better she performs. But is it really the coffee itself that's helping? Or is there something about the caffeine that's the true ingredient for exam success? As she digs deeper into her data, she realizes the mechanism might be more nuanced than she thought. The coffee is just the vehicle—it's the caffeine coursing through her veins that's actually sharpening her focus and helping her ace those exams.",

  causal_explanation = "This is a CAUSAL CHAIN (Mediator structure). Coffee doesn't directly affect exam scores; the effect flows through caffeine. Coffee → (causes) Caffeine → (causes) Exam Score. If we control for caffeine, the effect of coffee on exam score disappears because we've blocked the pathway.",

  regression_analysis = list(
    # Total effect: Coffee on ExamScore (don't control for Caffeine)
    correct_1 = list(
      spec = "ExamScore ~ Coffee",
      interpretation = "Total effect of coffee on exam scores (including the pathway through caffeine)",
      correct = TRUE
    ),
    # Direct effect only: Coffee on ExamScore (controlling for Caffeine)
    wrong = list(
      spec = "ExamScore ~ Coffee + Caffeine",
      interpretation = "Only the direct effect of coffee (if any exists outside the caffeine pathway). This BLOCKS the main mechanism!",
      correct = FALSE,
      why_wrong = "If your goal is to measure total effect, controlling for the mediator (Caffeine) is wrong—it makes the real effect disappear."
    ),
    # Relationship between coffee and caffeine (should be strong)
    supporting = list(
      spec = "Caffeine ~ Coffee",
      interpretation = "Confirms that coffee actually causes caffeine levels (checking the pathway)",
      correct = TRUE
    )
  ),

  identifiable_elements = list(
    mediator = "Caffeine",
    confounder = "None",
    collider = "None"
  )
)

# ============================================================================
# SCENARIO 2: CAUSAL FORK (Confounder)
# ============================================================================
# Story: Socioeconomic status → both education and health
# Fork: Education ← SES → Health

scenario_2 <- list(
  name = "Climbing the Ladder",
  title = "Wealth, Education, and Health",
  dag_formula = "dag {
    SES -> Education
    SES -> Health
  }",
  data_generation = function(n = 500) {
    # Exogenous: Socioeconomic status (family background)
    ses <- rnorm(n, mean = 50, sd = 15)

    # Both education and health are caused by SES
    education <- 10 + 0.4 * ses + rnorm(n, mean = 0, sd = 3)
    health <- 60 + 0.25 * ses + rnorm(n, mean = 0, sd = 5)

    data.frame(
      SES = ses,
      Education = education,
      Health = health
    )
  },
  story = "David grew up in a wealthy suburb with excellent schools and top-tier healthcare facilities. His childhood friend Marcus, from the other side of town, had access to fewer educational resources and couldn't afford regular medical checkups. As they got older, David noticed something striking: people like him—well-educated and healthy—seemed to have a strong positive relationship between how many years they spent in school and how well they felt. But when David started studying this relationship scientifically, he realized he might be missing the bigger picture. What if the real reason educated people are healthier isn't because education itself makes you healthy, but because people with more money (and better family backgrounds) can afford both better education AND better healthcare?",

  causal_explanation = "This is a CAUSAL FORK (Confounder structure). SES is a common cause of both Education and Health. If we don't control for SES, we'll see a spurious positive correlation between Education and Health. It's not that education causes health—they're both caused by SES. We MUST control for SES to see the true relationship.",

  regression_analysis = list(
    # Naive: no control for SES (WRONG - spurious correlation)
    wrong = list(
      spec = "Health ~ Education",
      interpretation = "Appears to show education improves health",
      correct = FALSE,
      why_wrong = "Ignores the confounder (SES). This gives a biased, inflated estimate because SES causes both variables."
    ),
    # Correct: control for SES
    correct_1 = list(
      spec = "Health ~ Education + SES",
      interpretation = "True relationship between education and health, after removing the confounding effect of SES",
      correct = TRUE
    ),
    # Alternative framing: see if SES is really the confounder
    supporting = list(
      spec = "Health ~ SES",
      interpretation = "Confirms SES affects health (verifying the fork structure)",
      correct = TRUE
    )
  ),

  identifiable_elements = list(
    mediator = "None",
    confounder = "SES",
    collider = "None"
  )
)

# ============================================================================
# SCENARIO 3: COLLIDER
# ============================================================================
# Story: Talent + Hard Work → Hollywood Success
# Collider: Talent → Success ← HardWork

scenario_3 <- list(
  name = "Hollywood Dreams",
  title = "Talent, Hard Work, and Stardom",
  dag_formula = "dag {
    Talent -> Success
    HardWork -> Success
  }",
  data_generation = function(n = 500) {
    # Exogenous: talent and hard work are independent in the population
    talent <- rnorm(n, mean = 5, sd = 2)
    hard_work <- rnorm(n, mean = 5, sd = 2)

    # Success is determined by BOTH (you need at least one)
    success_score <- talent + hard_work + rnorm(n, mean = 0, sd = 1)
    success <- ifelse(success_score > 8, 1, 0)  # Top 30% succeed

    data.frame(
      Talent = talent,
      HardWork = hard_work,
      Success = success
    )
  },
  story = "Hollywood is full of aspiring actors, singers, and creators. Some are naturally gifted—they have that special something audiences can't look away from. Others are relentless grinders who work 16-hour days, perfect their craft obsessively, and never give up. Interestingly, in the general population of aspiring artists, talent and hard work are pretty independent—you can find lazy geniuses and determined folks with limited natural ability. But among those who actually make it big, something strange happens: successful people with less natural talent seem to be the hardest workers, while naturally gifted stars often coast on their abilities with less grind. This creates an apparent negative relationship between talent and hard work among the successful—but only because we're looking at the winners. Outside that select group, they're not related at all.",

  causal_explanation = "This is a COLLIDER structure. Both Talent and Hard Work cause Success (they both point INTO the same variable). In the general population, Talent and Hard Work are independent. But among the successful people (when we condition on Success = 1), they become negatively correlated. This is COLLIDER BIAS—a spurious negative relationship created by our selection process.",

  regression_analysis = list(
    # Correct: use full population
    correct_1 = list(
      spec = "HardWork ~ Talent (full population)",
      interpretation = "Shows no relationship between talent and hard work (as expected)",
      correct = TRUE
    ),
    # WRONG: subset to successful people only
    wrong = list(
      spec = "HardWork ~ Talent (subset: Success = 1 only)",
      interpretation = "Shows negative relationship: talented people seem to work less",
      correct = FALSE,
      why_wrong = "COLLIDER BIAS! By conditioning on the collider (Success), we create spurious negative correlation. This is selection bias."
    ),
    # Alternative: predict success from both
    supporting = list(
      spec = "Success ~ Talent + HardWork",
      interpretation = "Shows both talent and hard work increase chances of success (correct causal structure)",
      correct = TRUE
    )
  ),

  identifiable_elements = list(
    mediator = "None",
    confounder = "None",
    collider = "Success"
  )
)

# ============================================================================
# SCENARIO 4: COMPLEX (Fork + Chain)
# ============================================================================
# Story: Parental education → student resources + student aptitude → grades → college admission
# Complex: Multiple paths, confounding, and mediation

scenario_4 <- list(
  name = "From Generation to Generation",
  title = "Family Legacy and Academic Success",
  dag_formula = "dag {
    ParentEducation -> StudentResources
    ParentEducation -> StudentAptitude
    StudentResources -> GPA
    StudentAptitude -> GPA
    GPA -> CollegeAdmission
  }",
  data_generation = function(n = 500) {
    # Exogenous: parental education
    parent_ed <- rnorm(n, mean = 14, sd = 3)  # years of education

    # Fork: parental education causes both resources and aptitude
    student_resources <- 20 + 1.5 * parent_ed + rnorm(n, mean = 0, sd = 4)  # tutors, books, etc.
    student_aptitude <- 50 + 1.8 * parent_ed + rnorm(n, mean = 0, sd = 6)  # genes + early learning

    # Both affect GPA (scale 0-4)
    gpa <- 2.0 + 0.08 * student_resources + 0.012 * student_aptitude + rnorm(n, mean = 0, sd = 0.5)
    gpa <- pmax(0, pmin(4, gpa))  # Keep between 0 and 4

    # GPA affects college admission (chain) - probabilistic
    admission_prob <- plogis(-3 + 1.5 * gpa)  # logistic function
    college_admission <- rbinom(n, size = 1, prob = admission_prob)

    data.frame(
      ParentEducation = parent_ed,
      StudentResources = student_resources,
      StudentAptitude = student_aptitude,
      GPA = gpa,
      CollegeAdmission = college_admission
    )
  },
  story = "Emma comes from a family of academics. Her parents both have graduate degrees and have invested heavily in her education—tutoring programs, summer camps, and a home filled with books. Emma is also naturally bright, having inherited what seems like a genetic predisposition toward analytical thinking. By high school, Emma has an excellent GPA, which leads her to get accepted to a top university. Now researchers want to understand: is it the resources her parents provided that propelled Emma to success? Or is it her natural aptitude? Or her parents' education itself? The reality is messier: Emma's parents' education created a cascade effect, influencing both the resources available to her AND her innate abilities, both of which show up in her GPA, which then opens doors to college. Untangling this web of influence requires carefully thinking about what you measure and what you control for.",

  causal_explanation = "This is a COMPLEX structure combining a FORK and a CHAIN. ParentEducation is a confounder (fork) affecting both StudentResources and StudentAptitude. Both of those converge into GPA. Then GPA is a mediator (chain) through which effects flow to CollegeAdmission. This requires careful regression specification depending on your research question.",

  regression_analysis = list(
    # Question 1: What's the total effect of parent education on college admission?
    correct_for_total = list(
      spec = "CollegeAdmission ~ ParentEducation",
      interpretation = "Total effect (all pathways combined)",
      correct = TRUE,
      context = "If you want to know: does parental education affect college admission at all?"
    ),
    # Question 2: How much of the effect flows through GPA?
    correct_with_mediator = list(
      spec = "CollegeAdmission ~ ParentEducation + GPA",
      interpretation = "Effect of parental education not through GPA (direct effect)",
      correct = TRUE,
      context = "If you want to decompose: how much works through grades vs. other paths?"
    ),
    # Question 3: What's the effect of resources on college admission?
    dangerous = list(
      spec = "CollegeAdmission ~ StudentResources",
      interpretation = "Confounded! Looks like resources matter, but ignores aptitude.",
      correct = FALSE,
      why_wrong = "StudentAptitude is a confounder—both it and Resources affect GPA. Without controlling for aptitude, you get a biased estimate."
    ),
    # Better: control for confounders
    correct_for_resources = list(
      spec = "CollegeAdmission ~ StudentResources + StudentAptitude + GPA",
      interpretation = "True effect of resources on college admission (controlling for aptitude confounder and GPA mediator)",
      correct = TRUE
    )
  ),

  identifiable_elements = list(
    mediator = "GPA",
    confounder = "StudentAptitude (for StudentResources → GPA relationship)",
    collider = "None"
  )
)

# ============================================================================
# SAVE ALL SCENARIOS
# ============================================================================

scenarios <- list(
  scenario_1,
  scenario_2,
  scenario_3,
  scenario_4
)

# Save as JSON for later access
saveRDS(scenarios, "scenarios/all_scenarios.rds")

cat("✓ Scenarios created and saved!\n")
cat("  - Scenario 1: Causal Chain (Mediator)\n")
cat("  - Scenario 2: Causal Fork (Confounder)\n")
cat("  - Scenario 3: Collider\n")
cat("  - Scenario 4: Complex (Fork + Chain)\n")
