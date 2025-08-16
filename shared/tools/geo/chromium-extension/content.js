const s = document.createElement('script');
s.src = chrome.runtime.getURL('inject.js');
(s.parentNode || document.head || document.documentElement).appendChild(s);
s.onload = () => s.remove();
