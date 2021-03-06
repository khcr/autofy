var myGamePiece;

function startGame() {
    myGamePiece = new component(10, 10, "#fff", myGameArea.canvas.width / 2, myGameArea.canvas.height / 2);
    myGameArea.start();
}

var happiness_level = 3;
var speed_level = 3;
const nb_level = 5;
var myGameArea = {
    canvas : document.createElement("canvas"),
    start : function() {
        this.canvas.width = 370;
        this.canvas.height = 370;
        this.context = this.canvas.getContext("2d");

        document.getElementById("canvas").insertAdjacentElement("afterbegin", this.canvas);
        this.interval = setInterval(updateGameArea, 20);

        var isClick = false
        window.addEventListener('mousedown', function (e) {
            var currentX = e.pageX - myGameArea.context.canvas.offsetLeft - 5;
            var currentY = e.pageY - myGameArea.context.canvas.offsetTop - 10;
            var isIn = 0 <= currentX && currentX <= myGameArea.context.canvas.width &&
                        0 <= currentY && currentY <= myGameArea.context.canvas.height;
            if (isIn) {
                isClick = true
                myGameArea.x = e.clientX - myGameArea.context.canvas.offsetLeft - 5;
                myGameArea.y = e.clientY - myGameArea.context.canvas.offsetTop - 5;
                happiness_level = Math.round(myGameArea.x * nb_level / myGameArea.context.canvas.width);
                speed_level = nb_level - Math.round(myGameArea.y * nb_level / myGameArea.context.canvas.height);
                STATE['mood'] = happiness_level;
                STATE['intensity'] = speed_level;
                update_music();
            } else {
                isClick = false;
            }
        })
        this.canvas.addEventListener('mousemove', function (e) {
            if (!isClick) {
                myGameArea.x = e.clientX - myGameArea.context.canvas.offsetLeft - 5;
                myGameArea.y = e.clientY - myGameArea.context.canvas.offsetTop - 5;
            }
        })
    },
    clear : function(){
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);

        // Y axis line
        this.context.beginPath();
        this.context.moveTo(this.canvas.width / 2, 0);
        this.context.lineTo(this.canvas.width / 2, this.canvas.height);
        this.context.stroke();

        // X axis line
        this.context.beginPath();
        this.context.moveTo(0, this.canvas.height / 2);
        this.context.lineTo(this.canvas.width, this.canvas.height / 2);
        this.context.stroke();

        this.context.font = "20px monospace";
        this.context.fillStyle = '#FFF';
        this.context.fillText("Intense", this.canvas.width / 2 + 2, 20);
        this.context.fillText("Chill", this.canvas.width / 2 + 2, this.canvas.height - 5);
        this.context.fillText("Sad", 0, this.canvas.height / 2 - 5);
        this.context.fillText("Happy", this.canvas.width - 60, this.canvas.height / 2 - 5);

        const step = this.canvas.width / nb_level;
        const color = getComputedStyle(document.documentElement).getPropertyValue('--deep-pink');
        this.context.lineWidth = 1.5
        this.context.strokeStyle = '#fff'
        this.context.shadowBlur = 10;
        this.context.shadowColor = color;
        for(var i = 0; i < nb_level + 1; i++) {
            // X-axis coords
            this.context.beginPath();
            this.context.moveTo(i * step + step/2, this.canvas.height / 2 + 5);
            this.context.lineTo(i * step + step/2, this.canvas.height / 2 - 5);
            this.context.stroke();

            // Y-axis coords
            this.context.beginPath();
            this.context.moveTo(this.canvas.width / 2 + 5, i * step + step/2);
            this.context.lineTo(this.canvas.width / 2 - 5, i * step + step/2);
            this.context.stroke();
        }
    }
}

//The cursor that is moving
function component(width, height, color, x, y) {
    this.width = width;
    this.height = height;
    this.speedX = 0;
    this.speedY = 0;    
    this.x = x;
    this.y = y;    
    this.update = function() {
        var ctx = myGameArea.context;
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.arc(this.x, this.y, 5, 0, 2 * Math.PI);
        ctx.fill();
    }
}

function updateGameArea() {
    myGameArea.clear();
    if (myGameArea.x && myGameArea.y) {
        myGamePiece.x = myGameArea.x;
        myGamePiece.y = myGameArea.y;
    }
    myGamePiece.update();
}

// Start the game
startGame();