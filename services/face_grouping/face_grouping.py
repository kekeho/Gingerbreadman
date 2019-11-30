# Copyright (C) 2019 Hiroki Takemura (kekeho)
# 
# This file is part of Gingerbreadman.
# 
# Gingerbreadman is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Gingerbreadman is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Gingerbreadman.  If not, see <http://www.gnu.org/licenses/>.

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
    # compressor = TSNE(n_components=2)
    # compressed = compressor.fit_transform(face_encodings)

    # Clustering
    model = DBSCAN(eps=0.6, min_samples=1)
    cluster = model.fit(face_encodings)

    grouped = dict()
    for i, group_index in enumerate(cluster.labels_):
        faces_json[i]['group_index'] = int(group_index)

        try:
            grouped[int(group_index)]['faces'].append(faces_json[i])
        except KeyError:
            grouped[int(group_index)] = {'faces': [faces_json[i]]}
    
    return flask.jsonify(grouped)


if __name__ == "__main__":
    app.run(host='service_face_grouping', port=8000)
