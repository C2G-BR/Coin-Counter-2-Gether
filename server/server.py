from flask import Flask
from flask_restx import Api, reqparse

from image_name_space import name_space

parser = reqparse.RequestParser()
parser.add_argument("sort", type=str)

app = Flask(__name__)
api = Api(app, version='1.0', title='C2G Counter',
    description='',
)

api.add_namespace(name_space, path='/')

if __name__ == '__main__':
    app.run(debug=True)