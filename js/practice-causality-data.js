// ============================================================================
// Scenarios Data for Practice Causality Page
// ============================================================================

const scenarios = [
  {
    id: 1,
    title: "Coffee Shop Chronicles",
    subtitle: "Caffeine and Exam Success",
    story: "Meet Sarah, a graduate student who swears by her morning coffee ritual. Over the past semester, she's noticed something: the more coffee she drinks before her exams, the better she performs. But is it really the coffee itself that's helping? Or is there something about the caffeine that's the true ingredient for exam success? As she digs deeper into her data, she realizes the mechanism might be more nuanced than she thought. The coffee is just the vehicle—it's the caffeine coursing through her veins that's actually sharpening her focus and helping her ace those exams.",
    variables: ["Coffee", "Caffeine", "ExamScore"],
    causalStructure: {
      description: "CAUSAL CHAIN (Mediator structure)",
      arrows: [
        "Coffee → Caffeine",
        "Caffeine → ExamScore"
      ],
      explanation: "Coffee doesn't directly affect exam scores; the effect flows through caffeine. Coffee → (causes) Caffeine → (causes) Exam Score."
    },
    questions: [
      {
        id: 1,
        type: "short",
        prompt: "Draw the causal graph for this scenario. What variables affect what?",
        hint: "Think about whether coffee directly affects exam scores, or if there's an intermediate step.",
        answer: "Coffee → Caffeine → ExamScore (a chain/mediator structure)",
        dagImage: "practice-causality/images/scenario1_dag.png"
      },
      {
        id: 2,
        type: "multiple-choice",
        prompt: "If you want to measure the TOTAL effect of coffee on exam scores, which regression should you use?",
        options: [
          "ExamScore ~ Coffee",
          "ExamScore ~ Coffee + Caffeine",
          "Caffeine ~ Coffee"
        ],
        correctAnswer: 0,
        explanation: "Use ExamScore ~ Coffee. This gives you the total effect including the pathway through caffeine. Controlling for the mediator (Caffeine) blocks the main causal pathway and makes the effect disappear!"
      },
      {
        id: 3,
        type: "multiple-choice",
        prompt: "What type of causal structure is this? Identify the key element:",
        options: [
          "Confounder (fork)",
          "Mediator (chain)",
          "Collider",
          "Simple direct effect"
        ],
        correctAnswer: 1,
        explanation: "This is a CHAIN or MEDIATOR structure. Caffeine is the mechanism through which coffee affects exam scores. If you want the total effect, never control for mediators!"
      }
    ],
    identifiableElements: {
      mediator: "Caffeine",
      confounder: "None",
      collider: "None"
    },
    regressionAdvice: {
      correct: [
        {
          spec: "ExamScore ~ Coffee",
          interpretation: "Total effect of coffee on exam scores (including the pathway through caffeine)",
          uses: "When you want to know: Does coffee help with exam performance?"
        }
      ],
      incorrect: [
        {
          spec: "ExamScore ~ Coffee + Caffeine",
          interpretation: "WRONG: This controls for the mediator",
          problem: "Blocks the main causal pathway. The effect of coffee disappears because you've controlled for the mechanism!"
        }
      ]
    }
  },

  {
    id: 2,
    title: "Climbing the Ladder",
    subtitle: "Wealth, Education, and Health",
    story: "David grew up in a wealthy suburb with excellent schools and top-tier healthcare facilities. His childhood friend Marcus, from the other side of town, had lower family wealth (what we call SES—socioeconomic status), access to fewer educational resources, and couldn't afford regular medical checkups. As they got older, David noticed something striking: people like him—well-educated and healthy—seemed to have a strong positive relationship between Education (years of school) and Health (overall wellbeing score). But when David started studying this relationship scientifically, he realized he might be missing the bigger picture. What if the real reason educated people are healthier isn't because education itself makes you healthy, but because people with higher SES (family wealth and background) can afford both better education AND better healthcare? In other words, maybe SES is the common cause driving both Education and Health upward.",
    variables: ["SES", "Education", "Health"],
    causalStructure: {
      description: "CAUSAL FORK (Confounder structure)",
      arrows: [
        "SES → Education",
        "SES → Health"
      ],
      explanation: "SES is a common cause of both Education and Health. If we don't control for SES, we see a spurious positive correlation between Education and Health."
    },
    questions: [
      {
        id: 1,
        type: "short",
        prompt: "Draw the causal graph. What is the relationship between these variables?",
        hint: "Think about whether both variables could be caused by the same underlying factor.",
        answer: "SES causes both Education and Health (fork/common cause structure)",
        dagImage: "practice-causality/images/scenario2_dag.png"
      },
      {
        id: 2,
        type: "multiple-choice",
        prompt: "If you regress Health on Education WITHOUT controlling for SES, what will you find?",
        options: [
          "A strong positive relationship (education improves health)",
          "No relationship at all",
          "A negative relationship",
          "You can't tell without seeing the data"
        ],
        correctAnswer: 0,
        explanation: "You'll likely find a strong positive relationship. But this is SPURIOUS! It's not because education causes health. They both appear correlated because they share a common cause (SES). This is confounding."
      },
      {
        id: 3,
        type: "multiple-choice",
        prompt: "Which regression is correct if you want to measure the true relationship between education and health?",
        options: [
          "Health ~ Education",
          "Health ~ Education + SES",
          "Health ~ SES",
          "Education ~ Health"
        ],
        correctAnswer: 1,
        explanation: "You MUST control for SES. By including SES in the regression, you remove the confounding effect and see the true relationship (or lack thereof) between education and health."
      }
    ],
    identifiableElements: {
      mediator: "None",
      confounder: "SES",
      collider: "None"
    },
    regressionAdvice: {
      correct: [
        {
          spec: "Health ~ Education + SES",
          interpretation: "True relationship between education and health, controlling for the confounder",
          uses: "When you want to know: Does education itself improve health, independent of wealth?"
        }
      ],
      incorrect: [
        {
          spec: "Health ~ Education",
          interpretation: "WRONG: Ignores the confounder SES",
          problem: "This gives a biased, inflated estimate because SES affects both variables. The relationship appears stronger than it really is."
        }
      ]
    }
  },

  {
    id: 3,
    title: "Hollywood Dreams",
    subtitle: "Talent, Hard Work, and Stardom",
    story: "Hollywood is full of aspiring actors, singers, and creators. Some are naturally gifted—they have that special something audiences can't look away from. Others are relentless grinders who work 16-hour days, perfect their craft obsessively, and never give up. Interestingly, in the general population of aspiring artists, talent and hard work are pretty independent—you can find lazy geniuses and determined folks with limited natural ability. But among those who actually make it big, something strange happens: successful people with less natural talent seem to be the hardest workers, while naturally gifted stars often coast on their abilities with less grind. This creates an apparent negative relationship between talent and hard work among the successful—but only because we're looking at the winners. Outside that select group, they're not related at all.",
    variables: ["Talent", "HardWork", "Success"],
    causalStructure: {
      description: "COLLIDER structure",
      arrows: [
        "Talent → Success",
        "HardWork → Success"
      ],
      explanation: "Both Talent and Hard Work cause Success (they both point INTO the same variable). In the general population, they're independent. But among the successful, they become negatively correlated (collider bias)."
    },
    questions: [
      {
        id: 1,
        type: "short",
        prompt: "Draw the causal graph. How do these variables relate to each other?",
        hint: "What causes success? How many different paths lead to it?",
        answer: "Talent → Success ← HardWork (both point into Success - a collider)",
        dagImage: "practice-causality/images/scenario3_dag.png"
      },
      {
        id: 2,
        type: "multiple-choice",
        prompt: "In the general population of all aspiring artists (successful and unsuccessful), what's the relationship between talent and hard work?",
        options: [
          "Strong positive (talented people work harder)",
          "Strong negative (talented people are lazy)",
          "No relationship / Independent",
          "It depends on the genre"
        ],
        correctAnswer: 2,
        explanation: "In the full population, talent and hard work are independent. They're two separate paths to success. But this changes when you condition on success..."
      },
      {
        id: 3,
        type: "multiple-choice",
        prompt: "Among only the SUCCESSFUL artists, what happens to the relationship between talent and hard work?",
        options: [
          "They remain independent",
          "They become strongly positively correlated",
          "They become negatively correlated (talented stars work less)",
          "The relationship becomes random"
        ],
        correctAnswer: 2,
        explanation: "This is COLLIDER BIAS! Among the successful, talented people need to work less to make it, while less talented people must compensate with hard work. This creates a spurious negative relationship. The bias comes from conditioning on the collider (Success)."
      }
    ],
    identifiableElements: {
      mediator: "None",
      confounder: "None",
      collider: "Success"
    },
    regressionAdvice: {
      correct: [
        {
          spec: "HardWork ~ Talent (full population)",
          interpretation: "No relationship between talent and hard work",
          uses: "Shows the true population relationship"
        },
        {
          spec: "Success ~ Talent + HardWork",
          interpretation: "Both talent and hard work increase chances of success",
          uses: "Correct model of what causes success"
        }
      ],
      incorrect: [
        {
          spec: "HardWork ~ Talent (subset: Success = 1 only)",
          interpretation: "WRONG: Appears to show negative relationship",
          problem: "COLLIDER BIAS! By restricting to successful people only, you create spurious negative correlation. This is selection bias caused by conditioning on the collider."
        }
      ]
    }
  },

  {
    id: 4,
    title: "From Generation to Generation",
    subtitle: "Family Legacy and Academic Success",
    story: "Emma comes from a family of academics with high ParentEducation (advanced degrees). Her parents have invested heavily in her—paying for StudentResources like tutoring programs, summer camps, and a home filled with books. Emma is also naturally bright, with high StudentAptitude (analytical thinking ability she seems to have inherited). By high school, Emma has an excellent GPA, which leads to CollegeAdmission to a top university. Now researchers want to understand: is it the StudentResources (tutoring, books, programs) that propelled Emma's GPA and college success? Or is it her StudentAptitude (natural talent)? Or her parents' ParentEducation itself? The reality is messier: her parents' high ParentEducation created a cascade effect. It influenced both the StudentResources available to her AND her innate StudentAptitude. Both affect her GPA. Then her GPA directly affects college CollegeAdmission. Untangling this web of multiple pathways requires carefully thinking about what you measure and what you control for.",
    variables: ["ParentEducation", "StudentResources", "StudentAptitude", "GPA", "CollegeAdmission"],
    causalStructure: {
      description: "COMPLEX structure combining Fork and Chain",
      arrows: [
        "ParentEducation → StudentResources",
        "ParentEducation → StudentAptitude",
        "StudentResources → GPA",
        "StudentAptitude → GPA",
        "GPA → CollegeAdmission"
      ],
      explanation: "ParentEducation is a confounder (fork) affecting both StudentResources and StudentAptitude. Both converge into GPA (chain). Then GPA is a mediator flowing to CollegeAdmission."
    },
    questions: [
      {
        id: 1,
        type: "short",
        prompt: "Draw the causal graph. Identify all the pathways from ParentEducation to CollegeAdmission.",
        hint: "How many routes does parental education take to affect college admission?",
        answer: "ParentEducation affects college admission through multiple paths: (1) via StudentResources → GPA → CollegeAdmission, and (2) via StudentAptitude → GPA → CollegeAdmission",
        dagImage: "practice-causality/images/scenario4_dag.png"
      },
      {
        id: 2,
        type: "multiple-choice",
        prompt: "If you want the TOTAL effect of StudentResources on college admission, which variables do you control for?",
        options: [
          "Nothing; just regress CollegeAdmission ~ StudentResources",
          "StudentAptitude only (the confounder)",
          "GPA only (the mediator)",
          "Both StudentAptitude and GPA"
        ],
        correctAnswer: 1,
        explanation: "StudentAptitude is a confounder (both StudentResources and StudentAptitude are caused by ParentEducation), so you MUST control for it. But GPA is a MEDIATOR—the pathway through which StudentResources affects admission. If you control for GPA, you block that pathway and lose the effect. For the TOTAL effect, control confounders but NOT mediators."
      },
      {
        id: 3,
        type: "multiple-choice",
        prompt: "Identify each causal structure present in this scenario:",
        options: [
          "Only a chain",
          "Only a fork",
          "A fork (confounding) and a chain (mediation)",
          "Multiple colliders"
        ],
        correctAnswer: 2,
        explanation: "This scenario has BOTH a fork and a chain. The fork is ParentEducation causing both StudentResources and StudentAptitude. The chain is StudentResources → GPA → CollegeAdmission (and StudentAptitude → GPA → CollegeAdmission)."
      }
    ],
    identifiableElements: {
      mediator: "GPA",
      confounder: "StudentAptitude (for StudentResources effect)",
      collider: "None"
    },
    regressionAdvice: {
      correct: [
        {
          spec: "CollegeAdmission ~ ParentEducation",
          interpretation: "Total effect of parental education on college admission (all pathways)",
          uses: "When you want to know: Does family background matter for college admission?"
        },
        {
          spec: "CollegeAdmission ~ StudentResources + StudentAptitude + GPA",
          interpretation: "Effect of resources on college admission, controlling for aptitude confounder and GPA mediator",
          uses: "When you want to isolate: Does money/resources help with college admission, independent of talent?"
        }
      ],
      incorrect: [
        {
          spec: "CollegeAdmission ~ StudentResources",
          interpretation: "WRONG: Confounded by StudentAptitude",
          problem: "StudentAptitude is a confounder—it's caused by ParentEducation and affects GPA. Ignoring it biases your estimate of the resources effect."
        }
      ]
    }
  },

  {
    id: 5,
    title: "The Hospital Paradox",
    subtitle: "Treatment, Severity, Recovery, and Selection Bias",
    story: "Imagine you're analyzing a medical database to evaluate whether a new treatment for blood pressure actually works. You compare patients who received the treatment versus those who didn't, looking at who ended up needing hospitalization (as a marker of poor recovery). Surprisingly, you find that patients who received the treatment were MORE likely to be hospitalized! But here's the twist: the hospital only gave the treatment to the sickest patients (those with the highest baseline severity scores). So while the treatment actually helps, the sickest people get it. Additionally, hospitalization happens when recovery is poor—so by looking only at who was hospitalized, you're selecting a group where both the treatment and the disease severity are strongly represented, creating a spurious negative relationship between treatment and recovery. This is the hospital paradox: selection bias and confounding together can completely mask or reverse a treatment's true effect.",
    variables: ["BaselineSeverity", "TreatmentReceived", "Recovery", "Hospitalization"],
    causalStructure: {
      description: "COMPLEX (Confounder + Collider)",
      arrows: [
        "BaselineSeverity → TreatmentReceived",
        "BaselineSeverity → Recovery",
        "TreatmentReceived → Recovery",
        "Recovery → Hospitalization",
        "TreatmentReceived → Hospitalization"
      ],
      explanation: "BaselineSeverity is a CONFOUNDER (causes both Treatment and Recovery). Hospitalization is a COLLIDER (caused by both TreatmentReceived and Recovery). This combination creates two sources of bias."
    },
    questions: [
      {
        id: 1,
        type: "short",
        prompt: "Draw the causal graph. What are the pathways and what role does each variable play?",
        hint: "Think about what causes treatment assignment, what causes recovery, and what determines hospitalization. Is there a variable that affects multiple outcomes?",
        answer: "BaselineSeverity → TreatmentReceived → Recovery ← BaselineSeverity. Hospitalization is caused by both TreatmentReceived and Recovery (collider). BaselineSeverity is a confounder.",
        dagImage: "practice-causality/images/scenario5_dag.png"
      },
      {
        id: 2,
        type: "multiple-choice",
        prompt: "If you regress Hospitalization on Treatment (observing the full patient dataset), what will you likely find?",
        options: [
          "Treatment increases hospitalization risk (appears harmful)",
          "Treatment decreases hospitalization risk (appears helpful)",
          "No relationship (unbiased estimate)",
          "Strong positive relationship (very harmful)"
        ],
        correctAnswer: 0,
        explanation: "The sickest patients get the treatment (confounder: severity causes treatment). The sickest patients are more likely to be hospitalized anyway. So treatment appears harmful even though it actually helps. This is confounding bias making the treatment look bad."
      },
      {
        id: 3,
        type: "multiple-choice",
        prompt: "If you only look at hospitalized patients and regress Recovery on Treatment, what causal bias do you face?",
        options: [
          "Confounding (severity causes both treatment and recovery)",
          "Collider bias (we've conditioned on a collider)",
          "Mediation (treatment works through hospitalization)",
          "Both confounding and collider bias"
        ],
        correctAnswer: 3,
        explanation: "By selecting only hospitalized patients, you condition on a collider (Hospitalization is caused by both Treatment and Recovery). This CREATES spurious correlation between Treatment and Recovery. Additionally, the sickest patients (high severity) get treatment AND have poor recovery, so confounding still biases the relationship."
      }
    ],
    identifiableElements: {
      mediator: "None (Recovery is an outcome, not a mediator)",
      confounder: "BaselineSeverity",
      collider: "Hospitalization"
    },
    regressionAdvice: {
      correct: [
        {
          spec: "Recovery ~ Treatment + BaselineSeverity",
          interpretation: "Effect of treatment on recovery, controlling for baseline disease severity (the confounder)",
          uses: "When you want to know: Does the treatment actually improve recovery, accounting for the fact that sicker patients get it?"
        }
      ],
      incorrect: [
        {
          spec: "Recovery ~ Treatment (full dataset)",
          interpretation: "WRONG: Confounded by BaselineSeverity",
          problem: "Severity is a confounder. Sicker patients get the treatment. Their poor recovery is due to severity, not treatment quality. This estimate is biased downward."
        },
        {
          spec: "Recovery ~ Treatment (only hospitalized patients)",
          interpretation: "WRONG: Collider bias + confounding",
          problem: "By selecting only hospitalized patients, you condition on a collider. This creates spurious associations. You're looking at the sickest people who got treatment and had poor outcomes, missing healthier people who recovered well."
        }
      ]
    }
  }
];
