from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import csv

from scrapy import Spider, Request
from scrapy.selector import Selector
from rmp.items import RmpItem
import re


class RMPSpider(Spider):
    name = 'rmp_spider'
    allowed_urls = ['http://www.ratemyprofessors.com']
    start_urls = ['http://www.ratemyprofessors.com/campusRatings.jsp?sid=1']
    
    def __init__(self):
        path_to_profile = r'C:\Users\rl80914n\AppData\Local\Google\Chrome\Scrape'
        chrome_options = webdriver.ChromeOptions()
        chrome_options.add_argument('user-data-dir=' + path_to_profile)
        self.driver = webdriver.Chrome(r'C:\Users\rl80914n\Desktop\Selenium_files\chromedriver.exe', chrome_options = chrome_options)

    def get_selenium_response(self, url):
        self.driver.get(url)
        self.driver.implicitly_wait(1)

        index=1
        while True:
            try:
                wait_button = WebDriverWait(self.driver,3)
                loadmore_button = wait_button.until(EC.element_to_be_clickable((By.XPATH,
                                                '//a[@id="loadMore"]')))
                loadmore_button.click()
                print("Loaded Clicked %s" %{index})
                index += 1

            except Exception as e:
                print(e)
                break

        return self.driver.page_source.encode('utf-8')

    # def start_request(self):
    #     total_urls = ["http://www.ratemyprofessors.com/campusRatings.jsp?sid={}".format(i) for i in range(2, 6049)]  

    #     for url in total_urls[:3]:
    #         yield Request(url=url, callback=self.parse)


    def parse(self, response):
        total_urls = ["http://www.ratemyprofessors.com/campusRatings.jsp?sid={}".format(i) for i in range(1, 20000)]  

        for url in total_urls:
            sel_response = Selector(text=self.get_selenium_response(url))

            try:
                school = sel_response.xpath('//div[@class="result-text"]/span[@class="boxfitted"]/text()').extract_first().strip()
                city_state = sel_response.xpath('//div[@class="result-title"]/span/text()').extract_first().strip()
                scores_boxes = sel_response.xpath('//td[@class="scores"]')
                num_schoolratings = int(len(scores_boxes))
                comment_boxes = sel_response.xpath('//td[@class="comments"]')

                #loop through the score boxes
                for score in scores_boxes:

                    date = score.xpath('.//div[@class="date"]/text()').extract_first().strip()

                    #storing comment box values
                    com = comment_boxes[scores_boxes.index(score)]
                    comment = com.xpath('.//p//text()').extract_first().strip()
                    thumbs_up = int(com.xpath('.//a[@class="helpful"]//span[@class="count"]//text()').extract_first().strip())
                    thumbs_down = int(com.xpath('.//a[@class="nothelpful"]//span[@class="count"]//text()').extract_first().strip())
                    
                    item = RmpItem()

                    #dictionary values
                    item['school'] = school
                    item['city_state'] = city_state
                    item['num_schoolratings'] = num_schoolratings
                    item['date'] = date  
                    item['thumbs_up'] = thumbs_up
                    item['thumbs_down'] = thumbs_down
                    item['comment'] = comment

                    #storing values from score box to extract criteria and scores
                    rating_list = score.xpath('.//div[@class="rating"]')
                    for rating in rating_list:
                        label = rating.xpath('.//div[@class="label"]/text()').extract_first().strip()
                        points = rating.xpath('.//div[starts-with(@class, "score ")]/text()').extract_first().strip()
                        item[label] = points  

                    print('%s %s %s' %('='*50, school, '='*50))

                    yield item

            except AttributeError as error:
                print("AttributeError on page: %s" %(total_urls.index(url)+1))
                print(error)
                continue


        
