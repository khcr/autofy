from flask import Flask, render_template, request
from pythonosc import osc_message_builder
from pythonosc import udp_client
from string import Template

PATH = "sonic_pi_buffers/"
FILES = ["background.rb", "basic_methods.rb", "chordsList.rb", "rhythms.rb", "samples.rb"]

# SonicPi Server
server = udp_client.SimpleUDPClient('127.0.0.1', 4557)

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/update", methods=["POST"])
def update():
    state = request.json
    reload(state)
    return {}

@app.route("/start", methods=["POST"])
def start():
    state = request.json
    # load buffer files
    for i, filename in enumerate(FILES):
        with open(PATH + filename, "r") as file:
            code = file.read()
            server.send_message("/save-and-run-buffer", ["SONIC_PI_CLI", str(i), code])

    reload(state)
    return {}

@app.route("/stop", methods=["POST"])
def stop():
    server.send_message("/stop-all-jobs", ["SONIC_PI_CLI"])
    return {}

@app.route("/exit", methods=["POST"])
def exit():
    server.send_message("/exit", ["SONIC_PI_CLI"])
    return {}

def reload(state):
    with open(PATH + "main.rb", "r") as file:
        code = file.read()
        template = Template(code)
        code = template.substitute(**state)
        server.send_message("/run-code", ["SONIC_PI_CLI", code])