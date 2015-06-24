# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

from scrapy import Item, Field


class GovcatalogsItem(Item):

    #Projects
    ministry = Field() # Project Name

    #DataStore
    name = Field()

    #DataStore - Content
    dataset_download_link = Field()

    #DataStore - Properties
    genre = Field()
    description = Field()
    source_url = Field()
    publisher = Field() # Department
    time_series_granularity = Field()
    licensed_by = Field()
    notes = Field()
    contributor = Field() #Email


