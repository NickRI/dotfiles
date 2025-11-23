// content.js
// Инжектируем inject.js в контекст страницы (не в изолированный контекст content script)
// Это должно произойти до того, как страница попытается использовать geolocation
(function() {
    const script = document.createElement('script');
    script.src = chrome.runtime.getURL('inject.js');
    script.onload = function() {
        this.remove();
    };
    // На document_start document.documentElement уже доступен
    (document.head || document.documentElement).appendChild(script);
})();

// Слушаем сообщения от inject.js (в изолированном контексте content script)
window.addEventListener('message', e => {
    // Проверяем, что сообщение пришло от нашей страницы
    if (e.data && e.data.type === 'getGeo') {
        chrome.runtime.sendMessage({ type: 'geo' }, result => {
            if (chrome.runtime.lastError) {
                window.postMessage({ type: 'geoResult', error: chrome.runtime.lastError.message }, '*');
                return;
            }
            window.postMessage({ type: 'geoResult', data: result }, '*');
        });
    }
});
