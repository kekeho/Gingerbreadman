# Copyright (c) 2019 Hiroki Takemura (kekeho)
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import flask
from flask import request
from sklearn.cluster import DBSCAN
import json
import numpy as np
from sklearn.manifold import TSNE


app = flask.Flask(__name__)

@app.route('/cluster/', methods=['POST'])
def clustering():
    faces_json = request.json
    face_encodings = np.array([x['face_encoding'] for x in faces_json], dtype='float32')

     # 128d -> 2d
    compressor = TSNE(n_components=2)
    compressed = compressor.fit_transform(face_encodings)

    # Clustering
    model = DBSCAN(eps=0.5, min_samples=1)
    cluster = model.fit(compressed)

    for i, group_index in enumerate(cluster.labels_):
        faces_json[i]['group_index'] = int(group_index)
    
    return flask.jsonify(faces_json)


if __name__ == "__main__":
    app.run(host='service_face_grouping', port=8000)
