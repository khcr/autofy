from flask import Flask, render_template
from pythonosc import osc_message_builder
from pythonosc import udp_client
import random

sender = udp_client.SimpleUDPClient('127.0.0.1', 4560)

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/osc-request")
def osc_request():
    sender.send_message('/rate', random.randint(1, 10))
    return ""