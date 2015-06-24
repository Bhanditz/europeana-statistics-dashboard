# -*- coding: utf-8 -*-

# Scrapy settings for govcatalogs project
#
# For simplicity, this file contains only the most important settings by
# default. All the other settings are documented here:
#
# http://doc.scrapy.org/en/latest/topics/settings.html
#

BOT_NAME = 'govcatalogs'

SPIDER_MODULES = ['govcatalogs.spiders']
NEWSPIDER_MODULE = 'govcatalogs.spiders'

LOG_LEVEL = 'DEBUG'

ITEM_PIPELINES = {
    'govcatalogs.pipelines.GovcatalogsPipeline' : 800,
}
# Crawl responsibly by identifying yourself (and your website) on the user-agent
#USER_AGENT = "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36"
USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 Safari/537.36"
COOKIES_ENABLED = False
DOWNLOAD_DELAY = 0.5
