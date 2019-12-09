#!/usr/bin/env python3
from flask import Flask

flaskapp = Flask(__name__)


@flaskapp.route('/')
def welcomeMsg():
    return 'A Warm Welcome to flaskapp!'


if __name__ == '__main__':
    flaskapp.run(host='0.0.0.0', debug=True)
