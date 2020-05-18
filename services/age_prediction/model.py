# Copyright (C) 2020 Hiroki Takemura (kekeho)
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

from tensorflow import keras
from tensorflow.keras.models import Model
from tensorflow.keras.applications import Xception
from tensorflow.keras.layers import Conv2D, Dense, Dropout, MaxPooling2D, Input, Flatten
from tensorflow.keras.optimizers import RMSprop
from tensorflow.keras.callbacks import TensorBoard
import numpy as np
from PIL import Image
import enum
from glob import glob
from typing import List
import random
import gc


def get_images(filename: str) -> (Image.Image, int):
    age = int(filename.split('_')[0].split('/')[-1])
    with open(filename, 'rb') as imgfp:
        image = Image.open(imgfp)
        image = np.asarray(image, dtype='float16')
    
    return image, age
            

class AgeModel():    
    def __init__(self):
        self.base_model = Xception(include_top=False, input_shape=(200, 200, 3))
        self.model = self._model()

    def _model(self):
        x = self.base_model.output
        x = MaxPooling2D()(x)
        x = Conv2D(256, (3, 3))(x)
        x = Flatten()(x)
        x = Dense(64, activation='relu')(x)
        x = Dropout(0.5)(x)
        x = Dense(16, activation='relu')(x)
        x = Dropout(0.5)(x)
        x = Dense(4, activation='relu')(x)
        y = Dense(1)(x)

        model = Model(inputs=self.base_model.input, outputs=y)

        # Freeze
        for layer in model.layers[:108]:
            if layer.name.startswith('batch_normalization'):
                layer.trainable = True
                continue
            
            if layer.name.endswith('bn'):
                layer.trainable = True
                continue

            layer.trainable = False
        
        for layer in model.layers[108:]:
            layer.trainable = True
        
        model.compile(optimizer=RMSprop(), loss='mse', metrics=['mae', 'mse'])
        model.summary()
        return model
    
    def train(self):
        epoch = 30
        files = glob('./UTKFace/*')
        random.shuffle(files)
        for ep in range(epoch):
            train_x = []
            train_y = []
            index = 0
            print('ep:',ep)
            print(train_x, train_y, index)
            while index < len(files):
                x, y = get_images(files[index])
                train_x.append(x)
                train_y.append(y)
                if (index > 0 and (index % 3000 == 0)) or (index == len(files)-1):
                    train_x = np.array(train_x)
                    train_y = np.array(train_y)
                    print(train_x.shape)
                    self.model.fit(x=train_x, y=train_y, validation_split=0.2, callbacks=[TensorBoard()])
                    train_x = []
                    train_y = []
                    index += 1
                index += 1
            del train_x
            del train_y
            gc.collect()

        self.model.save('age_prediction.h5')
