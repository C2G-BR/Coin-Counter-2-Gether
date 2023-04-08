from flask_restx import fields, Namespace

class ImageDTO:
    name_space = Namespace('image', description='image related operations')
    model = name_space.model('image', {
        'image': fields.String(attribute_id='image'),
    })