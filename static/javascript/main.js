
// State of the music
const STATE = { rate: 90, weather: 'none', place: 'none', intensity: 2, mood: 2 };

// Play / Pause button
const playButton = document.querySelector('#tgl-button')
playButton.onclick = () => {
    if (playButton.checked) {
        play_music();
    } else {
        stop_music();
    }
};

set_background(STATE['weather'], STATE['place']);

// Background selection
const background_button = document.querySelector('#backgrdbtn')
background_button.onclick = (button) => {
    // update style
    document.documentElement.style.setProperty('--light-pink', button.srcElement.dataset.value1);
    document.documentElement.style.setProperty('--deep-pink', button.srcElement.dataset.value2);
    STATE['weather'] = button.srcElement.dataset.value3;
    set_background(STATE['weather'], STATE['place']);
    document.getElementById("backButtonState").innerHTML = "<p>You are listening music with " + button.srcElement.innerHTML + " background";
    
    // update the music
    update_music();
}

// Places selection
const places_button = document.querySelector('#placesbtn')
places_button.onclick = (button) => {
    STATE['place'] = button.srcElement.dataset.value1;
    set_background(STATE['weather'], STATE['place']);
    document.getElementById("placeButtonState").innerHTML = "<p>You are listening music in " + button.srcElement.value;
    // update the music
    update_music();
}

// BPM
const rate_input = document.querySelector('#bpm');
rate_input.addEventListener('change', () => {
    let value = parseInt(rate_input.value);
    if (value <= 0) {
        value = 1;
    }
    if (value > 140) {
        value = 140;
    }
    rate_input.value = value;
    STATE['rate'] = value;
    update_music();
});

function getURLName(weather, place) {
    return "url('../images/lofi_background_" + weather + '_' + place + ".png')";
}

function set_background(weather, place) {
    var url = null
    if (place == "space" || place == "none") {
        document.getElementById("backgrdbtn").classList.add("disablebackgrdbtn");
        if (place == "space") {
            url = getURLName("", place);
        } else if (place == "none") {
            url = "url('../images/no_background.gif')";
        }
    } else {
        document.getElementById("backgrdbtn").classList.remove("disablebackgrdbtn")
        if (place == "coffee_shop" && (weather == "thunder" || weather == "hot_summer_night")) {
            url = getURLName("hot_summer_night", place);
        } else if (place == "country_side" && (weather == "thunder" || weather == "light_rain")) {
            url = "url('../images/rain.gif'), " + getURLName(weather, place);
        } else if (weather == "none") {
            url = getURLName("sunny_morning", place);
        } else {
            url = getURLName(weather, place);
        }
    }
    document.documentElement.style.setProperty('--background-image', url);
}

function update_music() {
    playButton.checked = true;
    post_json("update", STATE);
}

function play_music() {
    post_json("start", STATE);
}

function stop_music() {
    post_json("stop", {});
}

function post_json(path, data) {
    const post =  {
        method: "POST",
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    };
    fetch("http://127.0.0.1:5000/" + path, post).then(response => {
        if (!response.ok) {
            throw new Error(`Request failed with status ${response.status}`)
        }
    }).catch(error => console.log(error));
}