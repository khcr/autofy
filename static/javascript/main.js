// Play / Pause button
const playButton = document.querySelector('#tgl-button')
playButton.onclick = () => {
    console.log(playButton.checked);
};

var weather_state = "sunny"
var place_state = "countrySide"
set_background(weather_state, place_state)
// Background selection
const background_button = document.querySelector('#backgrdbtn')
background_button.onclick = (button) => {
    // update style
    document.documentElement.style.setProperty('--light-pink', button.srcElement.dataset.value1);
    document.documentElement.style.setProperty('--deep-pink', button.srcElement.dataset.value2);
    if (button.srcElement.dataset.value3 != "None")
        weather_state = button.srcElement.dataset.value3
        set_background(weather_state, place_state)
        //document.documentElement.style.setProperty('--background-image', "url('./lofi_background_" + button.srcElement.dataset.value3 + "')")
    document.getElementById("backButtonState").innerHTML = "<p>You are listening music with " + button.srcElement.value + " background"

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
    if (button.srcElement.dataset.value1 != null)
        place_state = button.srcElement.dataset.value1
        set_background(weather_state, place_state)
    //document.documentElement.style.setProperty('--background-image', "url('./" + button.srcElement.dataset.value1 + "')")
    document.getElementById("placeButtonState").innerHTML = "<p>You are listening music in " + button.srcElement.value
}

function getURLName(weather, place) {
    return "url('./lofi_background_" + weather + '_' + place + ".png')"
}

function set_background(weather, place) {
    var url = null
    if (place == "space") {
        url = getURLName("", place)
    } else if (place == "coffeeShop" && (weather == "thunder" || weather == "night")) {
        url = getURLName("night", place)
    } else {
        url = getURLName(weather, place)
    }
    console.log(url)
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