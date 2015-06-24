# -*- coding: utf-8 -*-

import datetime
from scrapy.exceptions import DropItem
from sqlalchemy.orm import sessionmaker
import sys, json
sys.path.append("../models")
sys.path.append("../config")
sys.path.append("../extras")
sys.path.append("../utils")
from _db_connect import db_connect, mongo_connect
from projects import Projects
from data_stores import DataStores
from core_metadata_data_store_columns import CoreMetadataDataStoreColumns
from parse_utils import parse_csv, parse_excel, parse_json
from sqlalchemy.exc import StatementError, InternalError, ProgrammingError
from bson.errors import InvalidStringData


current_timestamp = lambda : str(datetime.datetime.now())

class GovcatalogsPipeline(object):

    def __init__(self):
        try:
            self.engine = db_connect()
            self.Session = sessionmaker(bind=self.engine)
            #self.session = Session()
        except:
            print "I am unable to connect to the database"

        self.mongo = mongo_connect()
        self.dataset = self.mongo.data_sets

    def __del__(self):
        """
        Close the session and dispose the engine
        """
        #self.session.close()
        self.engine.dispose()
        self.mongo.close()

    def _commit_data(self):
        try:
            self.session.commit()
        except (StatementError, InternalError, ProgrammingError) as e:
            print "*-*-*-"
            print e
            print "*-*-*-"
            self.session.rollback()


    def process_item(self, item, spider):

        print item['name']
        print item['ministry']
        if not item['name'] or not item['ministry']:
            raise DropItem('NO Name for the catalog. Probably empty item')

        account_id = 38 #mostly static

        self.session = self.Session()

        pid = self._get_core_project_id(item['ministry'])
        if not pid:
            new_ministry = Projects(account_id=account_id, name=item['ministry'], slug=self._get_slug(item['ministry']),
                                    properties={}, is_public=True, created_at=current_timestamp(),
                                    updated_at=current_timestamp())
            self.session.add(new_ministry)
            self._commit_data()

            pid = self._get_core_project_id(item['ministry'])
            if not pid:
                raise DropItem("CRITICAL_ERROR - Cannot add project %s", item['ministry'])

        print 'pid' + str(pid)
        self.session.close()
        #Step3 Table - data_stores
        print type(item)
        content, content_size, column_datatype_probability = self._get_content(item)
        print len(content), content_size, type(content)
        #print column_datatype_probability
        if content:
            self.session = self.Session()
            catalog_id = self._get_catalog_id(item['name'])
            print 'catalog_id'
            properties = self._get_properties(item, content_size)
            if catalog_id:
                print "only update content"
                self.session.query(DataStores).filter_by(id=catalog_id).update({"updated_at":current_timestamp()})
                self._commit_data()
                data_store_id = catalog_id
            else:
                new_catalog = DataStores(core_project_id=pid, name=item['name'], slug=self._get_slug(item['name']),
                                        properties=properties, created_at=current_timestamp(),
                                        updated_at=current_timestamp())
                self.session.add(new_catalog)
                self._commit_data()
                data_store_id = self._get_catalog_id(item['name'])
            

            print 'data_store_id' + str(data_store_id)
            self.session.close()

            self.session = self.Session()
            columns = self.session.query(CoreMetadataDataStoreColumns.id, CoreMetadataDataStoreColumns.column_name).\
                filter(CoreMetadataDataStoreColumns.data_store_id == data_store_id).all()
            print columns
            print "***********"

            self.session.close()
            columns_in_db = {name: id for id, name in columns}
            column_names_in_db = columns_in_db.keys()


            for column_name, column_type_probability in column_datatype_probability.iteritems():
                self.session = self.Session()
                print column_name
                datatype = max(column_datatype_probability[column_name], key=column_datatype_probability[column_name].get)
                properties = {}
                properties['datatype_probability'] = json.dumps(column_type_probability)
                print properties
                if column_name in column_names_in_db:
                    print 'column already present'
                    print data_store_id
                    self.session.query(CoreMetadataDataStoreColumns).filter_by(id=columns_in_db[column_name]).\
                        update({"properties":properties, "updated_at":current_timestamp()})
                    print 'column updated'
                else:
                    print 'column not present'
                    print data_store_id
                    new_column = CoreMetadataDataStoreColumns(data_store_id=data_store_id, column_name=column_name,
                                                              datatype=datatype,
                                                              properties=properties,
                                                              created_at=current_timestamp(),
                                                              updated_at=current_timestamp())

                    self.session.add(new_column)
                    print 'column added'


                self._commit_data()

            self.session.close()


            #Flushing all the documents in the data store
            self.dataset.remove({'__data_store_id__': data_store_id})

            #inserting catalog data in mongo data_store
            print "---"
            for x, row in enumerate(content):
                content[x]['__core_project_id__'] = pid
                content[x]['__data_store_id__'] = data_store_id
            try:
                self.dataset.insert(content)
                print content[0]
                print content[1]
            except InvalidStringData:
                # to fix -- unicode issue
                # bson.errors.InvalidStringData: strings in documents must be valid UTF-8:
                # 'The Women Farmers\x92 Entitlements Bill, 2011'
                # To-do reset size in data_stores
                print 'data_set not added. Unicode error for -- ' + str(data_store_id)

            print "***"
        else:
            raise DropItem("Possibly no content (empty rows) in file for %s", item['name'])




    def _get_core_project_id(self, ministry):
        pid = self.session.query(Projects.id).filter(Projects.name == ministry).first()
        return pid[0] if pid else False

    def _get_catalog_id(self, catalog_name):
        catalog_id = self.session.query(DataStores.id).filter(DataStores.name == catalog_name).first()
        return catalog_id[0] if catalog_id else False

    def _get_content(self, item):
        content = False
        content_size = 0
        if item['genre'] == 'csv':
            content, content_size, column_datatype_probability = parse_csv(item['dataset_download_link'])
        elif item['genre'] == 'excel':
            print "******************** EXCEL **************************"
            content, content_size, column_datatype_probability  = parse_excel(item['dataset_download_link'])
        elif item['genre'] == 'json':
            print "******************** JSON *******************"
            content, content_size, column_datatype_probability = parse_json(item['dataset_download_link'])
        else:
            print item['dataset_download_link']
            print "No parser for " + item['genre'] + " file type right now"
            raise DropItem("No parser for " + item['genre'] + " file type right now")
        #tem['genre'] = 'csv'
        if content:
            return content, content_size, column_datatype_probability


    def _get_properties(self, item, content_size=0):
        properties = {}
        properties['source'] = 'data.gov.in'
        properties['genre'] = 'csv'
        properties['commit_message'] = 'auto-scraped'
        properties['description'] = item['description']
        properties['published_at'] = current_timestamp()
        properties['source_url'] = item['source_url']
        properties['publisher'] = item['publisher']
        properties['last_updated_at'] = current_timestamp()
        properties['time_series_granularity'] = item['time_series_granularity']
        properties['license'] = item['licensed_by']
        properties['notes'] = item['notes']
        properties['contributor'] = item['contributor']
        try:
            if content_size > 0:
                properties['size'] = str(content_size)
        except UnboundLocalError:
            pass

        return properties

    def _get_slug(self, name):
        name = name.lower()
        name = name.replace('/', '_')
        return name.replace(' ','-')

