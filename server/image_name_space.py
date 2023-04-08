import io
import os
import json
import base64
from PIL import Image
from flask import request, send_file, jsonify
from flask_restx import Resource

from image_dto import ImageDTO
from detector import CoinDetector

dto = ImageDTO()
name_space = dto.name_space
_image = dto.model

model_path = os.path.join(os.getcwd(), 'models/faster_rcnn_mobilenetv3_large.pt')
target2label = {1: 1, 2: 10, 3: 100, 4: 2, 5: 20, 6: 200, 7: 5, 8: 50, 0: 'background'}
cd = CoinDetector(model_path=model_path, target2label=target2label, threshold=0.5)

@name_space.route('')
class MyResource(Resource):

    @name_space.doc('Detect coins')
    @name_space.expect(_image)
    def post(self):
        data = json.loads(request.data)
        object = base64.b64decode(data['image'])
        img = Image.open(io.BytesIO(object))

        value, bboxes, texts = cd.predict(img)
        bounding_boxes = []
        for bbox, info in zip(bboxes, texts):
            bounding_boxes.append({
                'box': bbox,
                'text': info
            })
        return {'value': value, 'bounding_boxes': bounding_boxes}