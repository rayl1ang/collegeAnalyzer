# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class RmpItem(scrapy.Item):
    # define the fields for your item here like:
    school = scrapy.Field()
    city_state = scrapy.Field()
    num_schoolratings = scrapy.Field()
    date = scrapy.Field()
    thumbs_up = scrapy.Field()
    thumbs_down = scrapy.Field()
    comment = scrapy.Field()
    Reputation = scrapy.Field()
    Location = scrapy.Field()
    Internet = scrapy.Field()
    Food = scrapy.Field()
    Facilities = scrapy.Field()
    Social = scrapy.Field()
    Happiness = scrapy.Field()
    Opportunities = scrapy.Field()
    Clubs = scrapy.Field()
    Safety = scrapy.Field()
    Library = scrapy.Field()
    Campus = scrapy.Field()

