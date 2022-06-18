from flask import Flask, render_template, request
from pythonosc import osc_message_builder
from pythonosc import udp_client
import random

# client for Sonic Pi
sender = udp_client.SimpleUDPClient('127.0.0.1', 4560)

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/osc-request", methods=["POST"])
def osc_request():
    data = request.json
    sender.send_message(data['path'], data['value'])
    return {}