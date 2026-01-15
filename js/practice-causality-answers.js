// ============================================================================
// Complete Answer Explanations with Regression Results
// ============================================================================

const scenarioAnswers = [
  {
    scenarioId: 1,
    title: "Coffee Shop Chronicles",
    dagImage: "practice-causality/images/scenario1_dag.png",
    causalStructureDescription: `
      <h4>Causal Structure: CHAIN / MEDIATOR</h4>
      <p><strong>Flow:</strong> Coffee → Caffeine → ExamScore</p>
      <p>
        Sarah's coffee consumption affects exam scores, but NOT directly.
        Instead, coffee increases caffeine levels, which then improve exam performance.
        Coffee is just the vehicle; <strong>caffeine is the mechanism</strong>.
      </p>
      <p style="color: #d32f2f; font-weight: bold;">
        KEY INSIGHT: If you control for the mediator (Caffeine), the effect of Coffee disappears!
      </p>
    `,
    regressionAnalysis: {
      correct: {
        spec: "ExamScore ~ Coffee",
        result: `
          <strong>Coefficient:</strong> 87.64 (p < 0.001)<br>
          <strong>R-squared:</strong> 0.9643<br>
          <strong>Interpretation:</strong> Each additional cup of coffee is associated with 87.64
          additional points on the exam (on average). This is a HUGE effect!
          <br><strong>This is the TOTAL effect including the pathway through caffeine.</strong>
        `,
        isCorrect: true
      },
      incorrect: {
        spec: "ExamScore ~ Coffee + Caffeine",
        result: `
          <strong>Coefficient for Coffee:</strong> 0.23 (p = 0.894, NOT significant)<br>
          <strong>Coefficient for Caffeine:</strong> 3.50 (p < 0.001)<br>
          <strong>R-squared:</strong> 0.9945 (even better fit!)<br>
          <strong>Interpretation:</strong> When we control for Caffeine, the effect of Coffee
          disappears! Coffee coefficient drops from 87.64 to 0.23 (essentially zero).<br>
          <br><strong>This is WRONG because we've blocked the main causal pathway!</strong>
          We controlled for the mechanism (mediator) instead of measuring the total effect.
        `,
        isCorrect: false
      }
    },
    keyTakeaway: `
      When your goal is to measure the <strong>total effect</strong> of a variable,
      <strong>NEVER control for mediators</strong>. The pathway goes through them—
      that's how the effect happens! Only control for mediators if you want to isolate
      the <strong>direct effect</strong> (effect that doesn't go through that pathway).
    `,
    identifiedElements: {
      mediator: "Caffeine",
      confounder: "None",
      collider: "None"
    }
  },

  {
    scenarioId: 2,
    title: "Climbing the Ladder",
    dagImage: "practice-causality/images/scenario2_dag.png",
    causalStructureDescription: `
      <h4>Causal Structure: FORK / CONFOUNDER</h4>
      <p><strong>Flow:</strong> Education ← SES → Health</p>
      <p>
        David has more education AND better health. But does education cause health?
        Not necessarily! Both are caused by SES (family wealth and resources).
        <strong>SES is the common cause</strong> that makes them appear correlated.
      </p>
      <p style="color: #d32f2f; font-weight: bold;">
        KEY INSIGHT: Ignoring the confounder gives a biased, spurious relationship!
      </p>
    `,
    regressionAnalysis: {
      incorrect: {
        spec: "Health ~ Education",
        result: `
          <strong>Coefficient:</strong> 0.539 (p < 0.001)<br>
          <strong>R-squared:</strong> 0.297<br>
          <strong>Interpretation:</strong> Appears to show a strong positive relationship:
          each additional year of education is associated with 0.54 additional health points.<br>
          <br><strong>BUT THIS IS SPURIOUS!</strong> We're seeing the effect of SES on both
          variables, not the true Education → Health relationship.
        `,
        isCorrect: false
      },
      correct: {
        spec: "Health ~ Education + SES",
        result: `
          <strong>Coefficient for Education:</strong> 0.031 (p = 0.693, NOT significant)<br>
          <strong>Coefficient for SES:</strong> 0.253 (p < 0.001)<br>
          <strong>R-squared:</strong> 0.3618<br>
          <strong>Interpretation:</strong> When we control for SES, the effect of Education
          disappears! Education coefficient drops from 0.539 to 0.031 (essentially zero).<br>
          The real driver is SES, not education. Education and Health appear correlated
          only because they share a common cause.
        `,
        isCorrect: true
      }
    },
    keyTakeaway: `
      When you have a <strong>confounder (fork)</strong>—a variable that causes two others—
      you <strong>MUST control for it</strong> to get the true relationship.
      Without controlling for SES, you see the spurious correlation created by
      the confounding. This is the most common source of bias in observational data!
    `,
    identifiedElements: {
      mediator: "None",
      confounder: "SES",
      collider: "None"
    }
  },

  {
    scenarioId: 3,
    title: "Hollywood Dreams",
    dagImage: "practice-causality/images/scenario3_dag.png",
    causalStructureDescription: `
      <h4>Causal Structure: COLLIDER</h4>
      <p><strong>Flow:</strong> Talent → Success ← HardWork</p>
      <p>
        In the general population, talent and hard work are independent.
        Some people are lazy geniuses, others are determined grinders with limited talent.
        But among the <strong>successful people only</strong>, something weird happens:
        they become negatively correlated! Talented stars don't need to work as hard;
        less talented successful people must compensate with hard work.
      </p>
      <p style="color: #d32f2f; font-weight: bold;">
        KEY INSIGHT: Conditioning on the collider creates spurious correlation!
      </p>
    `,
    regressionAnalysis: {
      correct: {
        spec: "HardWork ~ Talent (Full Population)",
        result: `
          <strong>Coefficient:</strong> -0.0014 (p = 0.974, NOT significant)<br>
          <strong>R-squared:</strong> 0.0000206<br>
          <strong>Interpretation:</strong> In the full population, there is NO relationship
          between talent and hard work. They're independent, as expected.
        `,
        isCorrect: true
      },
      incorrect: {
        spec: "HardWork ~ Talent (Success = 1 Only)",
        result: `
          <strong>Coefficient:</strong> -0.213 (p < 0.001, HIGHLY significant)<br>
          <strong>R-squared:</strong> 0.0497<br>
          <strong>Interpretation:</strong> Among the successful, talent and hard work are
          <strong>negatively correlated</strong>! For every unit of talent, hard work
          decreases by 0.21. This is <strong>COLLIDER BIAS</strong>.<br>
          <br>The relationship is purely due to selection bias—we're only looking at
          the winners, where lack of talent must be compensated by hard work.
        `,
        isCorrect: false
      }
    },
    keyTakeaway: `
      <strong>COLLIDER BIAS</strong> is one of the most insidious forms of bias.
      When you condition on a collider (Success in this case), you create
      spurious negative correlation between its causes. <strong>Never condition on colliders</strong>
      unless you specifically want to analyze the selected subset. Always be aware
      of selection bias in your data!
    `,
    identifiedElements: {
      mediator: "None",
      confounder: "None",
      collider: "Success"
    }
  },

  {
    scenarioId: 4,
    title: "From Generation to Generation",
    dagImage: "practice-causality/images/scenario4_dag.png",
    causalStructureDescription: `
      <h4>Causal Structure: COMPLEX (Fork + Chain)</h4>
      <p><strong>Pathways:</strong></p>
      <ul>
        <li>ParentEducation → StudentResources → GPA → CollegeAdmission (Fork then Chain)</li>
        <li>ParentEducation → StudentAptitude → GPA → CollegeAdmission (Fork then Chain)</li>
      </ul>
      <p>
        Emma's family background creates multiple pathways to her college admission.
        Her parents' education provides resources (fork) AND influences her aptitude (fork).
        Both affect her GPA (chain), which then affects college admission (chain).
      </p>
      <p style="color: #d32f2f; font-weight: bold;">
        KEY INSIGHT: This combines confounding and mediation—requires careful specification!
      </p>
    `,
    regressionAnalysis: {
      incorrect: {
        spec: "CollegeAdmission ~ StudentResources",
        result: `
          <strong>Coefficient:</strong> -0.091 (p = 0.028, significant)<br>
          <strong>Interpretation:</strong> Appears to show StudentResources DECREASES
          chances of college admission. This is backwards and doesn't make sense!<br>
          <br><strong>Why?</strong> StudentAptitude is a confounder. Both StudentResources
          and StudentAptitude are caused by ParentEducation. Ignoring StudentAptitude
          confounds the estimate.
        `,
        isCorrect: false
      },
      correct: {
        spec: "CollegeAdmission ~ StudentResources + StudentAptitude + GPA",
        result: `
          <strong>Coefficient for StudentResources:</strong> -0.092 (still negative!)<br>
          <strong>Coefficient for StudentAptitude:</strong> 0.015 (not significant)<br>
          <br><strong>Interpretation:</strong> This model accounts for:<br>
          - StudentAptitude confounder (both StudentResources and StudentAptitude
          are caused by ParentEducation)<br>
          - GPA as the mediating pathway<br>
          <br>The direct effects are small because most of the influence flows through GPA.
        `,
        isCorrect: true
      }
    },
    keyTakeaway: `
      <strong>Complex causal structures</strong> combine forks (confounding) and chains (mediation).
      Your regression specification depends on your research question:
      <ul>
        <li><strong>Total effect</strong> of ParentEducation? Don't control for intermediate variables.</li>
        <li><strong>Direct effect</strong> of StudentResources? Control for confounders (StudentAptitude)
        and mediators (GPA).</li>
      </ul>
      Always draw your causal graph first!
    `,
    identifiedElements: {
      mediator: "GPA",
      confounder: "StudentAptitude (for StudentResources effect)",
      collider: "None"
    }
  }
];
