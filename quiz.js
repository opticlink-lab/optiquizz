(function () {
  const POINTS = { facile: 1, moyen: 2, difficile: 3 };

  function shuffleArray(arr) {
    var a = arr.slice();
    for (var i = a.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var t = a[i]; a[i] = a[j]; a[j] = t;
    }
    return a;
  }

  function normalize(q) {
    if (q.prompt && q.options) {
      return {
        text: q.prompt,
        answers: q.options,
        correctAnswerIndex: q.correctAnswerIndex,
        explanation: q.explanation || ''
      };
    }
    return {
      text: q.text,
      answers: q.answers,
      correctAnswerIndex: q.correctAnswerIndex,
      difficulty: q.difficulty,
      explanation: q.explanation || ''
    };
  }

  window.runQuiz = function runQuiz(dataUrl) {
    var questions = [];
    var title = '';
    var score = 0;
    var index = 0;
    var chosen = -1;
    var shuffledAnswers = [];
    var shuffledCorrectIndex = 0;
    var currentExplanation = '';

    var container = document.getElementById('quiz-container');
    var header = document.getElementById('quiz-header');
    var questionBlock = document.getElementById('question-block');
    var questionText = document.getElementById('question-text');
    var answersList = document.getElementById('answers-list');
    var explanationEl = document.getElementById('quiz-explanation');
    var nextBtn = document.getElementById('next-btn');
    var scoreEl = document.getElementById('score-display');

    function shuffleAnswers(q) {
      var indices = q.answers.map(function (_, i) { return i; });
      indices = shuffleArray(indices);
      shuffledAnswers = indices.map(function (i) { return q.answers[i]; });
      var idx = indices.indexOf(q.correctAnswerIndex);
      shuffledCorrectIndex = idx >= 0 ? idx : 0;
    }

    function renderQuestion() {
      if (index >= questions.length) {
        showResult();
        return;
      }
      var q = normalize(questions[index]);
      chosen = -1;
      currentExplanation = q.explanation || '';
      shuffleAnswers(q);
      questionText.textContent = q.text;
      if (explanationEl) {
        explanationEl.style.display = 'none';
        explanationEl.innerHTML = '';
      }
      answersList.innerHTML = '';
      shuffledAnswers.forEach(function (ans, i) {
        var li = document.createElement('li');
        var btn = document.createElement('button');
        btn.className = 'answer-btn';
        btn.textContent = ans;
        btn.type = 'button';
        btn.addEventListener('click', function () {
          if (chosen >= 0) return;
          chosen = i;
          shuffledAnswers.forEach(function (_, j) {
            var b = answersList.querySelectorAll('.answer-btn')[j];
            b.disabled = true;
            if (j === shuffledCorrectIndex) b.classList.add('correct');
            else if (j === i && i !== shuffledCorrectIndex) b.classList.add('wrong');
          });
          var pts = (q.difficulty && POINTS[q.difficulty]) ? POINTS[q.difficulty] : 1;
          if (i === shuffledCorrectIndex) score += pts;
          scoreEl.textContent = score + ' pt' + (score !== 1 ? 's' : '');
          if (explanationEl && currentExplanation) {
            explanationEl.innerHTML = '<p class="quiz-explanation-title">Explication</p><p class="quiz-explanation-text">' + currentExplanation + '</p>';
            explanationEl.style.display = 'block';
          }
          nextBtn.style.display = 'block';
        });
        li.appendChild(btn);
        answersList.appendChild(li);
      });
      nextBtn.style.display = 'none';
      nextBtn.textContent = index + 1 < questions.length ? 'Question suivante' : 'Voir le résultat';
    }

    function showResult() {
      questionBlock.style.display = 'none';
      nextBtn.style.display = 'none';
      var total = questions.length;
      var maxPossible = questions.reduce(function (acc, q) {
        var n = normalize(q);
        var pts = (n.difficulty && POINTS[n.difficulty]) ? POINTS[n.difficulty] : 1;
        return acc + pts;
      }, 0);
      header.innerHTML = '<h1 class="quiz-title">' + title + '</h1><a href="index.html" class="back-link">← Accueil</a>';
      var div = document.createElement('div');
      div.className = 'result-screen';
      div.innerHTML = '<h2>Résultat</h2><p class="score">' + score + ' / ' + maxPossible + ' points</p><p>' + total + ' question(s)</p><a href="index.html" class="back-link">← Retour à l\'accueil</a>';
      container.appendChild(div);
    }

    nextBtn.addEventListener('click', function () {
      index++;
      renderQuestion();
    });

    fetch(dataUrl)
      .then(function (r) { return r.json(); })
      .then(function (data) {
        questions = data.questions || [];
        title = data.title || 'Quiz';
        if (questions.length === 0) {
          questionBlock.innerHTML = '<p>Aucune question disponible.</p>';
          return;
        }
        scoreEl.textContent = '0 pt';
        renderQuestion();
      })
      .catch(function () {
        questionBlock.innerHTML = '<p>Erreur de chargement des questions.</p>';
      });
  };
})();
