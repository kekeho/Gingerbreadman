# Generated by Django 2.2.5 on 2019-10-24 04:35

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('controller', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='place',
            name='latitude',
            field=models.FloatField(default=-1),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='place',
            name='longitude',
            field=models.FloatField(default=-1),
            preserve_default=False,
        ),
    ]
