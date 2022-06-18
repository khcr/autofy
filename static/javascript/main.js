// Play / Pause button
const playButton = document.querySelector('#tgl-button')
playButton.onclick = () => {
    console.log(playButton.checked);
};

// Background selection
const background_button = document.querySelector('#backgrdbtn')
background_button.onclick = (button) => {
    // update style
    document.documentElement.style.setProperty('--light-pink', button.srcElement.dataset.value1);
    document.documentElement.style.setProperty('--deep-pink', button.srcElement.dataset.value2);
    if (button.srcElement.dataset.value3 != "None")
        console.log("url('./" + button.srcElement.dataset.value3 + "');")
        console.log(document.documentElement.style.backgroundImage)
        document.body.style.backgroundImage = "url('./" + button.srcElement.dataset.value3 + "');"
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
    document.getElementById("placeButtonState").innerHTML = "<p>You are listening music in " + button.srcElement.value
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