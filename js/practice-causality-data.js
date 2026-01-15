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
        answer: "Coffee → Caffeine → ExamScore (a chain/mediator structure)"
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
    story: "David grew up in a wealthy suburb with excellent schools and top-tier healthcare facilities. His childhood friend Marcus, from the other side of town, had access to fewer educational resources and couldn't afford regular medical checkups. As they got older, David noticed something striking: people like him—well-educated and healthy—seemed to have a strong positive relationship between how many years they spent in school and how well they felt. But when David started studying this relationship scientifically, he realized he might be missing the bigger picture. What if the real reason educated people are healthier isn't because education itself makes you healthy, but because people with more money (and better family backgrounds) can afford both better education AND better healthcare?",
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
        answer: "SES causes both Education and Health (fork/common cause structure)"
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
        answer: "Talent → Success ← HardWork (both point into Success - a collider)"
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
    story: "Emma comes from a family of academics. Her parents both have graduate degrees and have invested heavily in her education—tutoring programs, summer camps, and a home filled with books. Emma is also naturally bright, having inherited what seems like a genetic predisposition toward analytical thinking. By high school, Emma has an excellent GPA, which leads her to get accepted to a top university. Now researchers want to understand: is it the resources her parents provided that propelled Emma to success? Or is it her natural aptitude? Or her parents' education itself? The reality is messier: Emma's parents' education created a cascade effect, influencing both the resources available to her AND her innate abilities, both of which show up in her GPA, which then opens doors to college. Untangling this web of influence requires carefully thinking about what you measure and what you control for.",
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
        answer: "ParentEducation affects college admission through multiple paths: (1) via StudentResources → GPA → CollegeAdmission, and (2) via StudentAptitude → GPA → CollegeAdmission"
      },
      {
        id: 2,
        type: "multiple-choice",
        prompt: "If you want to estimate the effect of StudentResources on college admission, which variables do you NEED to control for?",
        options: [
          "Nothing; just regress CollegeAdmission ~ StudentResources",
          "StudentAptitude (to control for confounding)",
          "GPA (to control for mediation)",
          "Both StudentAptitude and GPA"
        ],
        correctAnswer: 3,
        explanation: "StudentAptitude is a confounder of the StudentResources → CollegeAdmission relationship (both are caused by ParentEducation). GPA is the mediating pathway. You need both to isolate the true effect of resources."
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
  }
];
