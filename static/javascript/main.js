// Play / Pause button
const playButton = document.querySelector('#tgl-button')
playButton.onclick = () => {
    console.log(playButton.checked);
};

// Background selection
const background_button = document.querySelector('#backgrdbtn')
background_button.onclick = (button) => {
    document.documentElement.style.setProperty('--light-pink', button.srcElement.dataset.value1);
    document.documentElement.style.setProperty('--deep-pink', button.srcElement.dataset.value2);
    document.getElementById("backButtonState").innerHTML = "<p>You are listening music with " + button.srcElement.value + " background"
}

// Places selection
const places_button = document.querySelector('#placesbtn')
places_button.onclick = (button) => {
    document.getElementById("placeButtonState").innerHTML = "<p>You are listening music in " + button.srcElement.value
}
