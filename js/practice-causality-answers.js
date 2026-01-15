// ============================================================================
// Complete Answer Explanations with Regression Results and True Coefficients
// ============================================================================

const scenarioAnswers = [
  {
    scenarioId: 1,
    title: "Coffee Shop Chronicles",
    dagImage: "practice-causality/images/scenario1_dag.png",
    csvFile: "practice-causality/data/scenario1_data.csv",
    trueModel: `
      <div style="background: #f0f4ff; padding: 15px; border-radius: 5px; margin: 15px 0;">
        <h5 style="color: #667eea; margin-top: 0;">True Underlying Model (used to generate data):</h5>
        <code style="display: block; padding: 10px; background: white; border-radius: 3px; margin: 10px 0;">
        Caffeine = 15 + 25 × Coffee + ε  (where ε ~ N(0, 5²))<br>
        ExamScore = 45 + 3.5 × Caffeine + ε  (where ε ~ N(0, 8²))<br>
        <br>
        <strong>Expected Total Effect:</strong> 25 × 3.5 = 87.5
        </code>
      </div>
    `,
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
          <strong>✓ CORRECT - Use this for TOTAL EFFECT</strong><br>
          <strong>Coefficient:</strong> 87.64 (p < 0.001)<br>
          <strong>R-squared:</strong> 0.9643<br>
          <strong>Interpretation:</strong> Each additional cup of coffee is associated with 87.64
          additional points on the exam. This is the TOTAL effect including the pathway through caffeine.<br>
          <strong>Compare to true model:</strong> Expected 87.5, estimated 87.64 ✓
        `,
        isCorrect: true
      },
      incorrect: {
        spec: "ExamScore ~ Coffee + Caffeine",
        result: `
          <strong>✗ WRONG - Blocks the mediator pathway</strong><br>
          <strong>Coefficient for Coffee:</strong> 0.23 (p = 0.894, NOT significant)<br>
          <strong>Coefficient for Caffeine:</strong> 3.50 (p < 0.001)<br>
          <strong>R-squared:</strong> 0.9945<br>
          <strong>Interpretation:</strong> When we control for Caffeine, the effect of Coffee disappears!
          Coffee coefficient drops from 87.64 to 0.23 (essentially zero).<br>
          <strong>Why wrong:</strong> We've blocked the main causal pathway by controlling for the mechanism itself!
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
    csvFile: "practice-causality/data/scenario2_data.csv",
    trueModel: `
      <div style="background: #f0f4ff; padding: 15px; border-radius: 5px; margin: 15px 0;">
        <h5 style="color: #667eea; margin-top: 0;">True Underlying Model (used to generate data):</h5>
        <code style="display: block; padding: 10px; background: white; border-radius: 3px; margin: 10px 0;">
        Education = 10 + 0.4 × SES + ε  (where ε ~ N(0, 3²))<br>
        Health = 60 + 0.25 × SES + ε  (where ε ~ N(0, 5²))<br>
        <br>
        <strong>KEY:</strong> Education and Health have NO direct causal relationship!<br>
        They only appear correlated because they share a common cause (SES).
        </code>
      </div>
    `,
    causalStructureDescription: `
      <h4>Causal Structure: FORK / CONFOUNDER</h4>
      <p><strong>Flow:</strong> Education ← SES → Health</p>
      <p>
        David has more education AND better health. But does education cause health?
        Not necessarily! Both are caused by SES (family wealth and background).
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
          <strong>✗ WRONG - Ignores confounder SES</strong><br>
          <strong>Coefficient:</strong> 0.539 (p < 0.001)<br>
          <strong>R-squared:</strong> 0.297<br>
          <strong>Interpretation:</strong> Appears to show education improves health.
          Each additional year of school = 0.54 additional health points.<br>
          <strong>BUT THIS IS SPURIOUS!</strong> We're seeing the effect of SES on both
          variables, not a true Education → Health relationship.
        `,
        isCorrect: false
      },
      correct: {
        spec: "Health ~ Education + SES",
        result: `
          <strong>✓ CORRECT - Control for confounder SES</strong><br>
          <strong>Coefficient for Education:</strong> 0.031 (p = 0.693, NOT significant)<br>
          <strong>Coefficient for SES:</strong> 0.253 (p < 0.001)<br>
          <strong>R-squared:</strong> 0.3618<br>
          <strong>Interpretation:</strong> When we control for SES, Education has NO effect!
          Education coefficient drops from 0.539 to 0.031 (essentially zero).<br>
          <strong>Compare to true model:</strong> True SES coefficient 0.25, estimated 0.253 ✓
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
    csvFile: "practice-causality/data/scenario3_data.csv",
    trueModel: `
      <div style="background: #f0f4ff; padding: 15px; border-radius: 5px; margin: 15px 0;">
        <h5 style="color: #667eea; margin-top: 0;">True Underlying Model (used to generate data):</h5>
        <code style="display: block; padding: 10px; background: white; border-radius: 3px; margin: 10px 0;">
        Talent ~ N(5, 2²)  (independent of HardWork)<br>
        HardWork ~ N(5, 2²)  (independent of Talent)<br>
        Success = ifelse(Talent + HardWork > 8, 1, 0)<br>
        <br>
        <strong>KEY:</strong> In FULL population, Talent and HardWork are INDEPENDENT (r ≈ 0)<br>
        Success requires high scores in at least one of them.
        </code>
      </div>
    `,
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
          <strong>✓ CORRECT - Use full population</strong><br>
          <strong>Coefficient:</strong> -0.0014 (p = 0.974, NOT significant)<br>
          <strong>R-squared:</strong> 0.0000206<br>
          <strong>Interpretation:</strong> In the full population, there is NO relationship
          between talent and hard work. They're independent, as expected.<br>
          <strong>Compare to true model:</strong> Expected correlation 0, estimated -0.0014 ✓
        `,
        isCorrect: true
      },
      incorrect: {
        spec: "HardWork ~ Talent (Success = 1 Only)",
        result: `
          <strong>✗ WRONG - COLLIDER BIAS from selection</strong><br>
          <strong>Coefficient:</strong> -0.213 (p < 0.001)<br>
          <strong>R-squared:</strong> 0.0497<br>
          <strong>Interpretation:</strong> Among the successful, talent and hard work are
          NEGATIVELY correlated! More talent = LESS hard work needed.<br>
          <strong>This is COLLIDER BIAS:</strong> The relationship is purely due to selection—we're only looking at
          winners where lack of talent must be compensated by hard work.
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
    csvFile: "practice-causality/data/scenario4_data.csv",
    trueModel: `
      <div style="background: #f0f4ff; padding: 15px; border-radius: 5px; margin: 15px 0;">
        <h5 style="color: #667eea; margin-top: 0;">True Underlying Model (used to generate data):</h5>
        <code style="display: block; padding: 10px; background: white; border-radius: 3px; margin: 10px 0;">
        StudentResources = 20 + 1.5 × ParentEducation + ε  (ε ~ N(0, 4²))<br>
        StudentAptitude = 50 + 1.8 × ParentEducation + ε  (ε ~ N(0, 6²))<br>
        GPA = 2.0 + 0.08 × StudentResources + 0.012 × StudentAptitude + ε  (ε ~ N(0, 0.5²))<br>
        CollegeAdmission: Pr(Admission) = logistic(-3 + 1.5 × GPA)<br>
        <br>
        <strong>Structure:</strong> FORK (ParentEducation → Resources & Aptitude) + CHAIN (→ GPA → Admission)
        </code>
      </div>
    `,
    causalStructureDescription: `
      <h4>Causal Structure: COMPLEX (Fork + Chain)</h4>
      <p><strong>Pathways:</strong></p>
      <ul>
        <li>ParentEducation → StudentResources → GPA → CollegeAdmission (Fork then Chain)</li>
        <li>ParentEducation → StudentAptitude → GPA → CollegeAdmission (Fork then Chain)</li>
      </ul>
      <p>
        Emma's family background creates multiple pathways to her college admission.
        Her parents' high education provides resources (fork) AND influences her aptitude (fork).
        Both affect her GPA (chain), which then affects college admission (chain).
      </p>
      <p style="color: #d32f2f; font-weight: bold;">
        KEY INSIGHT: This combines confounding and mediation—requires careful specification!
      </p>
    `,
    regressionAnalysis: {
      incorrect1: {
        spec: "CollegeAdmission ~ StudentResources",
        result: `
          <strong>✗ WRONG - Confounded by StudentAptitude</strong><br>
          <strong>Interpretation:</strong> This ignores StudentAptitude, which is a confounder.
          Both StudentResources and StudentAptitude are caused by ParentEducation.
          The estimate is biased because it conflates the effect of resources with the effect of aptitude.
        `,
        isCorrect: false
      },
      incorrect2: {
        spec: "CollegeAdmission ~ StudentResources + StudentAptitude + GPA",
        result: `
          <strong>✗ WRONG - Controls for the mediator GPA</strong><br>
          <strong>Interpretation:</strong> This blocks the main causal pathway! GPA is a MEDIATOR—it's the mechanism
          through which StudentResources affects CollegeAdmission. By controlling for GPA, you remove the main effect
          you're trying to measure. You've accounted for the confounder correctly (StudentAptitude), but you've also
          blocked the pathway through GPA.
        `,
        isCorrect: false
      },
      correct: {
        spec: "CollegeAdmission ~ StudentResources + StudentAptitude",
        result: `
          <strong>✓ CORRECT - Control for confounder, not mediator</strong><br>
          <strong>Interpretation:</strong> This gives you the TOTAL EFFECT of StudentResources on CollegeAdmission.
          You control for StudentAptitude (the confounder—both caused by ParentEducation)
          but you do NOT control for GPA (the mediator—the pathway through which resources affect admission).
          This captures the full effect: StudentResources → GPA → CollegeAdmission.
        `,
        isCorrect: true
      }
    },
    keyTakeaway: `
      <strong>Complex causal structures require careful thinking about your research question.</strong><br>
      <strong>Question:</strong> What is the total effect of StudentResources on CollegeAdmission?<br>
      <strong>Answer:</strong> Control for confounders (StudentAptitude) but NOT for mediators (GPA).<br>
      If you control for mediators, you block the causal pathway and lose the effect you're trying to measure!
      Always ask: "Am I trying to measure the total effect, or just the direct effect that doesn't go through a particular variable?"
    `,
    identifiedElements: {
      mediator: "GPA",
      confounder: "StudentAptitude (for StudentResources effect)",
      collider: "None"
    }
  }
];
