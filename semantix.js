(function () {
  function normalize(s) {
    return (s || '').toLowerCase().trim().normalize('NFD').replace(/\p{Diacritic}/gu, '');
  }

  function daysSince(ref, d) {
    var t = d.getTime() - ref.getTime();
    return Math.floor(t / (24 * 60 * 60 * 1000));
  }

  function wordOfTheDay(words) {
    var ref = new Date(2025, 0, 1);
    var today = new Date();
    var days = daysSince(ref, today);
    var idx = ((days % words.length) + words.length) % words.length;
    return words[idx];
  }

  function jaccard(a, b) {
    var sa = new Set((a || '').split(''));
    var sb = new Set((b || '').split(''));
    var inter = 0;
    sa.forEach(function (c) {
      if (sb.has(c)) inter++;
    });
    var union = new Set([].concat.apply([], [Array.from(sa), Array.from(sb)]));
    return union.size ? inter / union.size : 0;
  }

  // Exactement comme l'app : Glacial, Froid, Tiède, Chaud, Brûlant
  function heatFromScore(score) {
    var label, color;
    if (score < 0.15) {
      label = 'Glacial'; color = 'rgba(0, 100, 255, 0.7)';
    } else if (score < 0.35) {
      label = 'Froid'; color = 'cyan';
    } else if (score < 0.6) {
      label = 'Tiède'; color = '#facc15';
    } else if (score < 0.85) {
      label = 'Chaud'; color = 'orange';
    } else {
      label = 'Brûlant'; color = '#ef4444';
    }
    return { label: label, color: color };
  }

  // Température -10°C à 50°C comme l'app
  function temperature(score) {
    return Math.round(-10 + score * 60);
  }

  window.runSemantix = function runSemantix() {
    var target = null;
    var guesses = [];
    var won = false;

    var inputEl = document.getElementById('semantix-input');
    var submitBtn = document.getElementById('semantix-submit');
    var listEl = document.getElementById('guesses-list');
    var msgEl = document.getElementById('semantix-msg');
    var hintEl = document.getElementById('semantix-hint');
    var legendEl = document.getElementById('semantix-legend');

    function renderLegend() {
      if (!legendEl) return;
      var levels = [
        { label: 'Glacial', color: 'rgba(0, 100, 255, 0.7)' },
        { label: 'Froid', color: 'cyan' },
        { label: 'Tiède', color: '#facc15' },
        { label: 'Chaud', color: 'orange' },
        { label: 'Brûlant', color: '#ef4444' }
      ];
      legendEl.innerHTML = levels.map(function (l) {
        return '<span class="semantix-legend-item"><span class="semantix-legend-dot" style="background:' + l.color + '"></span>' + l.label + '</span>';
      }).join('');
    }

    function renderGuesses() {
      listEl.innerHTML = '';
      guesses.forEach(function (g) {
        var heat = heatFromScore(g.score);
        var temp = temperature(g.score);
        var pct = Math.round(g.score * 100);
        var row = document.createElement('div');
        row.className = 'guess-item';
        row.innerHTML =
          '<div class="guess-item-top">' +
            '<span class="guess-text">' + g.text + '</span>' +
            '<div class="guess-meta">' +
              '<span class="guess-heat" style="color:' + heat.color + '">' + heat.label + '</span>' +
              '<span class="guess-temp">' + temp + '°C</span>' +
            '</div>' +
          '</div>' +
          '<div class="guess-bar-wrap">' +
            '<div class="guess-bar-bg">' +
              '<div class="guess-bar-fill" style="width:' + pct + '%;background:' + heat.color + '"></div>' +
            '</div>' +
          '</div>';
        listEl.appendChild(row);
      });
    }

    function submit() {
      var raw = (inputEl.value || '').trim();
      if (!raw) return;
      var text = raw.toLowerCase();
      if (guesses.some(function (g) { return g.text.toLowerCase() === text; })) {
        inputEl.value = '';
        return;
      }
      var targetNorm = normalize(target.text);
      var guessNorm = normalize(text);
      if (guessNorm === targetNorm) {
        won = true;
        msgEl.textContent = 'Félicitations ! Vous avez trouvé le mot du jour.';
        msgEl.className = 'win-msg';
        inputEl.disabled = true;
        submitBtn.disabled = true;
        return;
      }
      var score = 0;
      var inBank = window.semantixWords.words.find(function (w) { return normalize(w.text) === guessNorm; });
      if (inBank) {
        if (inBank.category === target.category) score = 0.7;
        else score = 0.3;
      }
      var j = jaccard(guessNorm, targetNorm);
      score = Math.max(score, j);
      guesses.push({ text: raw, score: score });
      renderGuesses();
      inputEl.value = '';
    }

    fetch('data/semantix-words.json')
      .then(function (r) { return r.json(); })
      .then(function (data) {
        window.semantixWords = data;
        target = wordOfTheDay(data.words);
        if (hintEl) hintEl.textContent = 'Un mot optique secret par jour. Propose des mots, approche-toi du bon terme grâce à l\'indice froid/chaud.';
        renderLegend();
        submitBtn.addEventListener('click', submit);
        inputEl.addEventListener('keydown', function (e) { if (e.key === 'Enter') submit(); });
      })
      .catch(function () {
        msgEl.textContent = 'Erreur de chargement.';
      });
  };
})();
