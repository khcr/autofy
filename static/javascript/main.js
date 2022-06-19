// Play / Pause button
const playButton = document.querySelector('#tgl-button')
playButton.onclick = () => {
    console.log(playButton.checked);
};

var weather_state = "night"
var place_state = "city"
set_background(weather_state, place_state)
// Background selection
const background_button = document.querySelector('#backgrdbtn')
background_button.onclick = (button) => {
    // update style
    document.documentElement.style.setProperty('--light-pink', button.srcElement.dataset.value1);
    document.documentElement.style.setProperty('--deep-pink', button.srcElement.dataset.value2);
    weather_state = button.srcElement.dataset.value3
    set_background(weather_state, place_state)
    document.getElementById("backButtonState").innerHTML = "<p>You are listening music with " + button.srcElement.value + " background"
    console.log(button.srcElement.value)
    // update the music
    const data = {
        "path" : "rate",
        "value" : 10
    }
    osc_request(data);
}

// Places selection
const places_button = document.querySelector('#placesbtn')
places_button.onclick = (button) => {
    place_state = button.srcElement.dataset.value1
    set_background(weather_state, place_state)
    //document.documentElement.style.setProperty('--background-image', "url('./" + button.srcElement.dataset.value1 + "')")
    document.getElementById("placeButtonState").innerHTML = "<p>You are listening music in " + button.srcElement.value
    console.log(button.srcElement.value)
}

function getURLName(weather, place) {
    return "url('./lofi_background_" + weather + '_' + place + ".png')"
}

function set_background(weather, place) {
    var url = null
    if (place == "space" || place == "None") {
        document.getElementById("backgrdbtn").classList.add("disablebackgrdbtn")
        weather = "no"
        if (place == "space") {
            url = getURLName("", place)
        } else if (place == "None") {
            url = "url('./no_background.gif')"
        }
    } else {
        document.getElementById("backgrdbtn").classList.remove("disablebackgrdbtn")
        if (place == "coffeeShop" && (weather == "thunder" || weather == "night")) {
            url = getURLName("night", place)
        } else if (place == "countrySide" && (weather == "thunder" || weather == "rain")) {
            url = "url('./rain.gif'), " + getURLName(weather, place)
        } else if (weather == "None") {
            url = getURLName("sunny", place)
        } else {
            url = getURLName(weather, place)
        }
    }
    document.documentElement.style.setProperty('--background-image', url)
}

function osc_request(data) {
    const post =  {
        method: "POST",
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    }
    fetch("http://127.0.0.1:5000/osc-request", post).then(response => {
        if (!response.ok) {
            throw new Error(`Request failed with status ${reponse.status}`)
        }
    }).catch(error => console.log(error))
}