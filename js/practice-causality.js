// ============================================================================
// Practice Causality Interactive JavaScript
// ============================================================================

let currentScenarioIndex = 0;
const totalScenarios = scenarios.length;

// Store question metadata to avoid quote escaping issues in HTML attributes
const questionData = {};

// ============================================================================
// Initialize Page
// ============================================================================

document.addEventListener('DOMContentLoaded', function() {
  // Update total scenarios
  document.getElementById('total-scenarios').textContent = totalScenarios;

  // Load first scenario
  loadScenario(currentScenarioIndex);

  // Update nav buttons
  updateNavButtons();
});

let answersShown = false;

// ============================================================================
// Load and Display Scenario
// ============================================================================

function loadScenario(index) {
  if (index < 0 || index >= totalScenarios) return;

  currentScenarioIndex = index;
  const scenario = scenarios[index];

  // Update counter
  document.getElementById('current-scenario').textContent = index + 1;

  // Update title and subtitle
  document.getElementById('scenario-title').textContent = scenario.title;
  document.getElementById('scenario-subtitle').textContent = scenario.subtitle;

  // Update story
  document.getElementById('story-text').textContent = scenario.story;

  // Render questions
  renderQuestions(scenario);

  // Render answers section (but keep hidden until requested)
  renderAnswers(scenario, index);

  // Reset answers visibility
  answersShown = false;
  document.getElementById('answers-section').style.display = 'none';
  const showBtn = document.getElementById('show-all-answers');
  showBtn.textContent = 'Show Full Answer';
  showBtn.classList.remove('answered');

  // Update nav buttons
  updateNavButtons();

  // Scroll to top
  window.scrollTo(0, 0);
}

// ============================================================================
// Render Full Answers
// ============================================================================

function renderAnswers(scenario, scenarioIndex) {
  const answers = scenarioAnswers[scenarioIndex];

  // Note: True model is now shown in the CSV Practice section with clickable toggle

  // Causal description
  document.getElementById('causal-description').innerHTML = answers.causalStructureDescription;

  // DAG image
  document.getElementById('dag-image').src = answers.dagImage;
  document.getElementById('dag-image').alt = scenario.title + ' - Causal DAG';

  // Regression analysis
  let regressionHTML = '';
  for (const [key, regression] of Object.entries(answers.regressionAnalysis)) {
    if (!regression.spec) continue; // Skip if no spec

    const className = regression.isCorrect ? 'regression-correct' : 'regression-incorrect';

    regressionHTML += `
      <div class="regression-result ${className}">
        <strong>${regression.spec}</strong>
        <p>${regression.result}</p>
      </div>
    `;
  }
  document.getElementById('regression-analysis').innerHTML = regressionHTML;

  // Key takeaway
  document.getElementById('key-takeaway').innerHTML = answers.keyTakeaway;

  // Identified elements
  let elementsHTML = '<div class="identified-elements-grid">';
  for (const [element, value] of Object.entries(answers.identifiedElements)) {
    const display = element.charAt(0).toUpperCase() + element.slice(1);
    elementsHTML += `
      <div class="element-box">
        <h4>${display}</h4>
        <p>${value === 'None' ? '—' : value}</p>
      </div>
    `;
  }
  elementsHTML += '</div>';
  document.getElementById('identified-elements').innerHTML = elementsHTML;
}

// ============================================================================
// Toggle All Answers
// ============================================================================

function toggleAllAnswers() {
  const section = document.getElementById('answers-section');
  const button = document.getElementById('show-all-answers');

  if (answersShown) {
    section.style.display = 'none';
    button.textContent = 'Show Full Answer';
    button.classList.remove('answered');
    answersShown = false;
  } else {
    section.style.display = 'block';
    button.textContent = 'Hide Answer';
    button.classList.add('answered');
    answersShown = true;
    // Scroll to answers
    setTimeout(() => {
      section.scrollIntoView({ behavior: 'smooth' });
    }, 100);
  }
}

// ============================================================================
// Render Questions
// ============================================================================

function renderQuestions(scenario) {
  const container = document.getElementById('questions-container');
  container.innerHTML = '';

  scenario.questions.forEach((question, qIndex) => {
    const questionCard = createQuestionCard(question, qIndex + 1, scenario);
    container.appendChild(questionCard);

    // After first question, add the CSV/Real Data practice section
    if (qIndex === 0) {
      const csvSection = createCSVPracticeSection(scenario);
      container.appendChild(csvSection);
    }
  });
}

function createCSVPracticeSection(scenario) {
  const answers = scenarioAnswers[currentScenarioIndex];
  const section = document.createElement('div');
  section.className = 'csv-practice-section';

  let html = `
    <div style="background: #e8f5e9; border-left: 4px solid #4caf50; padding: 25px; margin: 25px 0; border-radius: 8px;">
      <h3 style="color: #2e7d32; margin-top: 0;">📊 Practice with Real Data</h3>
      <p style="color: #1b5e20; margin: 10px 0;">
        Download the dataset used in this scenario and try to estimate the <strong>true underlying model</strong>.
      </p>
  `;

  if (answers.csvFile) {
    html += `
      <a href="${answers.csvFile}" download class="download-btn-small">
        ⬇️ Download CSV Data
      </a>
      <p style="font-size: 0.9rem; color: #555; margin-top: 10px;">
        <strong>Challenge:</strong> Load the data into R or your favorite stats tool and figure out which regression gives the correct coefficients!
      </p>
    `;
  }

  // Add clickable true model section
  if (answers.trueModel) {
    const modelId = `true-model-${currentScenarioIndex}`;
    html += `
      <div style="margin-top: 15px; padding: 15px; background: white; border-radius: 5px; border: 1px solid #4caf50;">
        <button onclick="toggleTrueModel('${modelId}')" style="background: none; border: none; cursor: pointer; width: 100%; text-align: left; padding: 0;">
          <strong style="color: #2e7d32;">📋 Click to see: What is the true underlying model?</strong>
          <span id="toggle-icon-${modelId}" style="float: right; color: #2e7d32;">▼</span>
        </button>
        <div id="${modelId}" style="display: none; margin-top: 10px;">
          ${answers.trueModel}
        </div>
      </div>
    `;
  }

  html += '</div>';
  section.innerHTML = html;
  return section;
}

function toggleTrueModel(modelId) {
  const element = document.getElementById(modelId);
  const icon = document.getElementById(`toggle-icon-${modelId}`);
  if (element.style.display === 'none') {
    element.style.display = 'block';
    icon.textContent = '▲';
  } else {
    element.style.display = 'none';
    icon.textContent = '▼';
  }
}

function createQuestionCard(question, questionNum, scenario) {
  const card = document.createElement('div');
  card.className = 'question-card';

  let content = `
    <div class="question-number">${questionNum}</div>
    <div class="question-text">${question.prompt}</div>
    <div class="question-content">
  `;

  // Generate question-specific content
  if (question.type === 'multiple-choice') {
    content += createMultipleChoice(question, questionNum, scenario);
  } else if (question.type === 'short') {
    content += createShortAnswerQuestion(question, questionNum, scenario);
  }

  content += '</div>';

  card.innerHTML = content;
  return card;
}

function createMultipleChoice(question, questionNum, scenario) {
  let html = '<div class="options">';

  // Store question data in global object
  questionData[questionNum] = {
    correctAnswer: question.correctAnswer,
    correctOptionText: question.options[question.correctAnswer],
    explanation: question.explanation
  };

  question.options.forEach((option, optIndex) => {
    const id = `q${questionNum}-opt${optIndex}`;
    const isCorrect = optIndex === question.correctAnswer;
    html += `
      <div class="option">
        <input
          type="radio"
          id="${id}"
          name="q${questionNum}"
          value="${optIndex}"
          data-correct="${isCorrect}"
          onchange="handleMultipleChoice(${questionNum}, ${optIndex})"
        >
        <label for="${id}">${option}</label>
      </div>
    `;
  });

  html += '</div>';

  // Add answer section
  html += `
    <div id="answer-${questionNum}" class="answer-box">
      <h4 id="answer-header-${questionNum}">✓ Correct Answer</h4>
      <p id="answer-content-${questionNum}">${question.explanation}</p>
    </div>
  `;

  return html;
}

function handleMultipleChoice(questionNum, optionIndex) {
  const data = questionData[questionNum];
  const isCorrect = optionIndex === data.correctAnswer;
  const answerBox = document.getElementById(`answer-${questionNum}`);
  const headerEl = document.getElementById(`answer-header-${questionNum}`);
  const contentEl = document.getElementById(`answer-content-${questionNum}`);

  // Show the answer box
  answerBox.classList.add('show');

  if (isCorrect) {
    // Correct answer
    headerEl.innerHTML = '✓ Correct Answer';
    contentEl.innerHTML = data.explanation;
    answerBox.classList.add('answer-correct');
    answerBox.classList.remove('answer-incorrect');
  } else {
    // Wrong answer
    headerEl.innerHTML = '✗ False Answer';
    contentEl.innerHTML = `<strong>Correct answer is:</strong> ${data.correctOptionText}<br><br>${data.explanation}`;
    answerBox.classList.add('answer-incorrect');
    answerBox.classList.remove('answer-correct');
  }
}

function createShortAnswerQuestion(question, questionNum, scenario) {
  let html = `
    <button
      class="show-answer-btn"
      onclick="toggleShortAnswer(${questionNum})"
    >
      Show Answer
    </button>

    <div id="answer-${questionNum}" class="answer-box">
      <h4>✓ Answer</h4>
      <p>${question.answer}</p>
  `;

  if (question.dagImage) {
    html += `<img src="${question.dagImage}" class="dag-image" alt="Causal DAG" style="margin-top: 15px; max-width: 100%; height: auto;">`;
  }

  if (question.hint) {
    html += `<div class="hint"><strong>Hint:</strong> ${question.hint}</div>`;
  }

  html += '</div>';

  return html;
}

function toggleShortAnswer(questionNum) {
  const answerBox = document.getElementById(`answer-${questionNum}`);
  const button = event.target;

  if (answerBox.classList.contains('show')) {
    answerBox.classList.remove('show');
    button.textContent = 'Show Answer';
    button.classList.remove('answered');
  } else {
    answerBox.classList.add('show');
    button.textContent = 'Hide Answer';
    button.classList.add('answered');
  }
}

// ============================================================================
// Toggle Answer Visibility
// ============================================================================

// ============================================================================
// Navigation Between Scenarios
// ============================================================================

function nextScenario() {
  if (currentScenarioIndex < totalScenarios - 1) {
    loadScenario(currentScenarioIndex + 1);
  }
}

function previousScenario() {
  if (currentScenarioIndex > 0) {
    loadScenario(currentScenarioIndex - 1);
  }
}

function updateNavButtons() {
  const prevBtn = document.getElementById('prev-btn');
  const nextBtn = document.getElementById('next-btn');

  // Disable prev button on first scenario
  prevBtn.disabled = currentScenarioIndex === 0;

  // Disable next button on last scenario
  nextBtn.disabled = currentScenarioIndex === totalScenarios - 1;

  // Update button text
  if (currentScenarioIndex === totalScenarios - 1) {
    nextBtn.textContent = '✓ Completed!';
  } else {
    nextBtn.textContent = 'Next Scenario →';
  }
}

// ============================================================================
// Utility Functions
// ============================================================================

// Format question number as ordinal (1st, 2nd, 3rd, etc.)
function ordinal(n) {
  const s = ["th", "st", "nd", "rd"],
    v = n % 100;
  return n + (s[(v - 20) % 10] || s[v] || s[0]);
}

// Shuffle array (if needed for randomizing answer options)
function shuffle(array) {
  const arr = [...array];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}
