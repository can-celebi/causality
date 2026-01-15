// ============================================================================
// Practice Causality Interactive JavaScript
// ============================================================================

let currentScenarioIndex = 0;
const totalScenarios = scenarios.length;

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

  // Update nav buttons
  updateNavButtons();

  // Scroll to top
  window.scrollTo(0, 0);
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
  });
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

  question.options.forEach((option, optIndex) => {
    const id = `q${questionNum}-opt${optIndex}`;
    html += `
      <div class="option">
        <input
          type="radio"
          id="${id}"
          name="q${questionNum}"
          value="${optIndex}"
          onchange="toggleAnswer(${questionNum}, ${optIndex}, this.checked)"
        >
        <label for="${id}">${option}</label>
      </div>
    `;
  });

  html += '</div>';

  // Add answer section
  html += `
    <div id="answer-${questionNum}" class="answer-box">
      <h4>✓ Correct Answer</h4>
      <p>${question.explanation}</p>
    </div>
  `;

  return html;
}

function createShortAnswerQuestion(question, questionNum, scenario) {
  let html = `
    <button
      class="show-answer-btn"
      onclick="toggleAnswer(${questionNum}, null, true)"
    >
      Show Answer
    </button>

    <div id="answer-${questionNum}" class="answer-box">
      <h4>✓ Answer</h4>
      <p>${question.answer}</p>
  `;

  if (question.hint) {
    html += `<div class="hint"><strong>Hint:</strong> ${question.hint}</div>`;
  }

  html += '</div>';

  return html;
}

// ============================================================================
// Toggle Answer Visibility
// ============================================================================

function toggleAnswer(questionNum, optionIndex, show) {
  const answerBox = document.getElementById(`answer-${questionNum}`);

  if (answerBox.classList.contains('show')) {
    answerBox.classList.remove('show');
  } else {
    answerBox.classList.add('show');

    // Update button text if it exists
    const buttons = document.querySelectorAll('.show-answer-btn');
    buttons.forEach(btn => {
      if (btn.onclick.toString().includes(questionNum)) {
        btn.classList.add('answered');
        btn.textContent = 'Hide Answer';
      }
    });
  }
}

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
