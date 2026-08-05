---
permalink: /assets/js/copy-button.js
---
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('pre').forEach(function (pre) {
    if (pre.dataset.copyReady) return;
    pre.dataset.copyReady = '1';

    // Capture the text BEFORE inserting the button, so we don't end up copying
    // the button's own text along with the code.
    var codeEl = pre.querySelector('code') || pre;
    var codeText = codeEl.textContent;

    pre.style.position = 'relative';

    var btn = document.createElement('button');
    btn.type = 'button';
    btn.textContent = 'Copy';
    btn.style.cssText = 'position:absolute;top:6px;right:6px;padding:2px 10px;' +
      'font:12px/1.6 monospace;cursor:pointer;background:#24292f;color:#fff;' +
      'border:1px solid #444;border-radius:4px;opacity:0.75;';

    btn.addEventListener('mouseenter', function () { btn.style.opacity = '1'; });
    btn.addEventListener('mouseleave', function () { btn.style.opacity = '0.75'; });

    btn.addEventListener('click', function () {
      navigator.clipboard.writeText(codeText).then(function () {
        var original = btn.textContent;
        btn.textContent = 'Copied!';
        setTimeout(function () { btn.textContent = original; }, 1500);
      });
    });

    pre.appendChild(btn);
  });
});
