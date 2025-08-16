navigator.geolocation.getCurrentPosition = function(success, error, options) {
    fetch("__SERVER_URL__", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            considerIp: true
        })
    })
        .then(r => r.json())
        .then(data => {
            success({
                coords: {
                    latitude: data.location.lat,
                    longitude: data.location.lng,
                    accuracy: data.accuracy || 0,
                    altitude: null,
                    altitudeAccuracy: null,
                    heading: null,
                    speed: null
                },
                timestamp: Date.now()
            });
        })
        .catch(err => { if(error) error(err); });
};

navigator.geolocation.watchPosition = function(success, error, options) {
    const interval = (options && options.maximumAge) || 5000;
    const id = setInterval(() => {
        navigator.geolocation.getCurrentPosition(success, error, options);
    }, interval);
    return id;
};

navigator.geolocation.clearWatch = function(id) {
    clearInterval(id);
};