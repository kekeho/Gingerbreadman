# Generated by Django 2.2.5 on 2019-09-23 13:11

import controller.models
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('controller', '0002_auto_20190922_1459'),
    ]

    operations = [
        migrations.AlterField(
            model_name='image',
            name='id',
            field=models.CharField(default=controller.models.uuid4_str, max_length=36, primary_key=True, serialize=False),
        ),
    ]
