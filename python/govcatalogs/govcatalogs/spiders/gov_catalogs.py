#from __future__ import print_function
from scrapy.spider import Spider
from scrapy.http import Request
from scrapy.selector import Selector
#from scrapy.utils.response import open_in_browser
from scrapy.contrib.loader import ItemLoader
from govcatalogs.items import GovcatalogsItem
from scrapy.contrib.loader.processor import TakeFirst
from scrapy.exceptions import CloseSpider


class GovCatalogsSpider(Spider):
    """
        Default: scrapy crawl gov_catalogs  #1 day
        Custom: scrapy crawl gov_catalogs days = 365 #365 days
    """
    name = 'gov_catalogs'
    start_urls = ['http://data.gov.in/catalogs']
    _BASE_URL = "http://data.gov.in"
    days_to_scrape = 1

    def __init__(self, days=1):
        self.days_to_scrape = days

    def parse(self, response):
        """
        Parse Catalog Collections Details and extract catalog links
        """
        sel = Selector(response)
        sel = sel.xpath("//div[@id='block-system-main']/div[contains(@class,'view-id-catalogs')]")
        cat_list = sel.xpath(".//div[@class='view-content']/div[re:test(@class, 'views-row-\d')]")

        for catalog in cat_list:
            meta = {}
            name = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-title')]/span/a/text()").extract()).strip()
            catalog_link = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-title')]/span/"
                                                  "a/@href").extract())

            meta['description'] = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-body')]/span/text()")
                                           .extract()).strip()
            if not meta['description']:
                meta['description'] = "__No_Description_Provided__"
            last_updated = u''.join(catalog.xpath(".//div[contains(@class, 'catalog-bottom')]/span/"
                                                  "span[@class='catalog-bottom-updated']/em/text()").extract())


            #last_updated = self._resolve_last_updated(last_updated)
            #if last_updated['days'] > self.days_to_scrape:
               # print 'NO more new or updated catalogs'
               # raise CloseSpider('NO more new or updated catalogs')

            #print last_updated
            #if last_updated['days'] > 2:
            #    raise DropItem('not updated since last 2 days')

            # ministry_dept = catalog.xpath(".//div[contains(@class, 'views-field-field-ministry-department')]/"
            #                               "span/text()").extract()
            # meta['ministry'], meta['publisher'] = self._resolve_ministry_and_department(ministry_dept)

            # meta['keywords'] = catalog.xpath(".//div[contains(@class, 'views-field-field-keywords')]/"
            #                                  "span[@class='field-content']/a/text()").extract()


            if name and catalog_link:
                catalog_link = self._BASE_URL + catalog_link
                yield Request(catalog_link, callback=self.parse_catalogs, meta=meta)


        next_page = self._get_next_page(sel)
        if next_page:
            next_page = self._BASE_URL + next_page
            print "************************** NEXT PAGE ************************"
            print next_page
            yield Request(next_page, callback=self.parse)


    def parse_catalogs(self, response):
        """
        Parse Catalogs from a catalog collection page
        """
        sel = Selector(response)
        sel = sel.xpath("//div[@id='web_catalog_tab_block_10']/div[contains(@class, 'view-id-resource_detail_popup')]")
        catalogs = sel.xpath(".//div[@class='view-content']/div[re:test(@class, 'views-row-\d')]")
        meta = response.meta


        for catalog in catalogs:
            loader = ItemLoader(item=GovcatalogsItem(), response=response)
            loader.default_output_processor = TakeFirst()

            loader.add_value('source_url', response.url)

            name = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-title')]/span[@class='field-content']"
                                          "/span[@class='title-content']/text()").extract())
            loader.add_value('name', name)

            loader.add_value('description', meta['description'])

            genre, dataset_download_link = self._get_genre(catalog)
            loader.add_value('genre', genre)
            loader.add_value('dataset_download_link', dataset_download_link)

            granularity = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-field-granularity')]/"
                                                 "div[@class='field-content']/text()").extract()).strip()
            loader.add_value('time_series_granularity', granularity)

            notes = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-field-note')]/"
                                           "div[@class='field-content']/text()").extract()).strip()
            if not notes:
                notes = "__NO__NOTES__"
            loader.add_value('notes', notes)

            licensed_by = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-field-license')]/"
                                                 "div[@class='field-content']/a/@title").extract()).strip()
            loader.add_value('licensed_by', licensed_by)


            contributor_details = sel.xpath("//section[@id='block-web-catalog-web-catalog-data-manager']")
            contributor_details = contributor_details.xpath(".//div[contains(@class, 'view-id-data_manager')]/"
                                                            "div[@class='view-content']/"
                                                            "div[contains(@class, 'views-row')]")
            ministry_dept = contributor_details.xpath(".//div[contains(@class, 'views-field-nothing')]/"
                                                      "span[@class='field-content']/text()").extract()
            ministry, publisher = self._resolve_ministry_and_department(ministry_dept)

            contributor = contributor_details.xpath(".//div[contains(@class, 'views-field-field-dc-email')]")
            contributor = u''.join(contributor.xpath(".//div[@class='item-list']/ul/li/text()").extract())

            loader.add_value('ministry', ministry)
            loader.add_value('publisher', publisher)
            loader.add_value('contributor', contributor)

            # file_size = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-field-file-size')]/"
            #                                    "div[@class='field-content']/text()").extract()).strip()
            #download_count = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-field-file-download-count')]"
            #                                         "/div[@class='field-content']/text()").extract()).strip()
            # frequency = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-field-frequency')]/"
            #                                    "div[@class='field-content']/text()").extract()).strip()
            # reference_urls = catalog.xpath(".//div[contains(@class, 'views-field-field-reference-url')]/"
            #                                "div[@class='field-content']/a/@href").extract()
            # license_link = u''.join(catalog.xpath(".//div[contains(@class, 'views-field-field-license')]/"
            #                                       "div[@class='field-content']/a/@href").extract()).strip()

            # print(name, meta['description'], source_url, genre, dataset_download_link, granularity, notes,
            #      licensed_by,contributor, ministry, publisher, sep='\n')
            next_page = self._get_next_page(sel)
            if next_page:
                next_page = self._BASE_URL + next_page
                print "************************** NEXT PAGE ************************"
                print next_page
                yield Request(next_page, callback=self.parse_catalogs)

            yield loader.load_item()

    def _get_genre(self, catalog_xpath):
        default_dataset_type = u''.join(catalog_xpath.xpath(".//div[contains(@class, 'views-field-field-short-name')]/"
                                                            "div[@class='field-content']/a/text()").extract()).strip()
        if 'csv' in default_dataset_type:
            dataset_download_link = u''.join(catalog_xpath.xpath(".//div[contains(@class, "
                                                                 "'views-field-field-short-name')]/"
                                                                 "div[@class='field-content']/a/@href")
                                             .extract()).strip()
            return 'csv', dataset_download_link
        else:
            other_formats = catalog_xpath.xpath(".//div[contains(@class, 'views-field-dms-allowed-operations')]/"
                                                "span[@class='field-content']/ul/li/a")
            other_formats_links = other_formats.xpath(".//@href").extract()
            other_formats = other_formats.xpath(".//@title").extract()
            other_formats = [x.strip().lower() for x in other_formats] #remove extra whitespaces if any
            if 'csv' in other_formats:
                csv_index = other_formats.index('csv')
                return 'csv', other_formats_links[csv_index]
            elif 'excel' in other_formats:
                excel_index = other_formats.index('excel')
                return 'excel', other_formats_links[excel_index]
            else:
                dataset_download_link = u''.join(catalog_xpath.xpath(".//div[contains(@class, "
                                                                     "'views-field-field-short-name')]/"
                                                                     "div[@class='field-content']/a/@href")
                                                 .extract()).strip()
                return default_dataset_type, dataset_download_link


    def _get_next_page(self, sel):
        next_page = u''.join(sel.xpath(".//div[@class='item-list']/ul[@class='pager']/"
                                       "li[contains(@class, 'pager-next')]/a/@href").extract()).strip()
        if next_page:
            return next_page
        else:
            return False

    def _resolve_ministry_and_department(self, ministry_dept):
        ministry, publisher = False, False
        for x in ministry_dept:
            x = x.strip()
            if 'ministry' in x.lower():
                #In some cases, ministry and publisher (department) are the same
                ministry = publisher = x
            elif 'department' in x.lower():
                publisher = x
            else:
                ministry = publisher = x

        if publisher and not ministry:
            ministry = publisher

        return ministry, publisher

    def _resolve_last_updated(self, last_updated):
        last_updated = last_updated.strip().split( )
        result = {}
        result['days'] = 0
        for i, x in enumerate(last_updated):
            if x in ['days', 'day']:
                result['days'] += int(last_updated[i - 1])
            elif x in ['week', 'weeks']:
                result['days'] += int(last_updated[i - 1]) * 7

        return result
