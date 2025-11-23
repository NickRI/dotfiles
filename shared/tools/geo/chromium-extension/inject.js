// inject.js
(function() {
    // Создаем объект ошибки, совместимый с GeolocationPositionError
    function createGeolocationError(code, message) {
        const error = new Error(message);
        error.code = code;
        error.message = message;
        error.PERMISSION_DENIED = 1;
        error.POSITION_UNAVAILABLE = 2;
        error.TIMEOUT = 3;
        return error;
    }
    
    navigator.geolocation.getCurrentPosition = function(success, error, options) {
        window.postMessage({ type: 'getGeo' }, '*');
        
        const timeout = setTimeout(() => {
            window.removeEventListener('message', handler);
            if (error) {
                error(createGeolocationError(3, 'Request timeout'));
            }
        }, 10000); // 10 секунд таймаут
        
        const handler = function(e) {
            if (e.data.type === 'geoResult') {
                clearTimeout(timeout);
                window.removeEventListener('message', handler);
                
                if (e.data.error) {
                    if (error) {
                        error(createGeolocationError(2, e.data.error));
                    }
                } else if (e.data.data && e.data.data.coords) {
                    const position = {
                        coords: {
                            latitude: e.data.data.coords.latitude,
                            longitude: e.data.data.coords.longitude,
                            accuracy: e.data.data.coords.accuracy,
                            altitude: null,
                            altitudeAccuracy: null,
                            heading: null,
                            speed: null
                        },
                        timestamp: e.data.data.timestamp || Date.now()
                    };
                    success(position);
                } else {
                    if (error) {
                        error(createGeolocationError(2, 'Invalid response format'));
                    }
                }
            }
        };
        
        window.addEventListener('message', handler);
    };
    
    // Также переопределяем watchPosition, если нужно
    if (navigator.geolocation.watchPosition) {
        navigator.geolocation.watchPosition = function(success, error, options) {
            // Для watchPosition используем простую реализацию через setInterval
            let watchId = setInterval(() => {
                navigator.geolocation.getCurrentPosition(success, error, options);
            }, 1000);
            return watchId;
        };
    }
})();
