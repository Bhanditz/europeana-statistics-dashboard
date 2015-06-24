from xlrd import open_workbook
import subprocess, os, csv, json
import xlrd
import bson
import uuid
from _parse_datatype import parse_datatype
#utf8_encode = lambda x : x.decode('latin-1').encode('utf-8')

def parse_csv(file_url):
    print 'parsing content'
    file_name = _get_file(file_url)
    if not file_name:
        print "No file"
        return False, 0, {}

    content, content_size = [], 0
    column_datatype_probability = {}

    try: #opening file
        with open(file_name, 'rb') as csvfile:

            rows = list(csv.reader(csvfile, delimiter=',', quotechar='"'))
            headers = rows[0]
            if _is_row_empty(headers):
                _delete_file(file_name)
                return False, 0, {}

            headers = _format_headers_for_mongo(headers)
            print headers
            for row in rows[1:]:
                content_row = { headers[i] : row[i] for i in range(len(row)) if not _is_row_empty(row) }
                if '' in content_row:
                    del content_row['']
                if not content_row:
                    continue

                content.append(content_row)
                print content_row
                content_size += len(bson.BSON.encode(content_row))
                column_datatype_probability = _compute_column_datatype_probability(content)

            _delete_file(file_name)

    except (IOError, TypeError, csv.Error) as e:
        print e
        print file_url

    print column_datatype_probability
    return content, content_size, column_datatype_probability


def parse_excel(file_url):
    file_name = _get_file(file_url)
    if not file_name:
        print "No file"
        return False, 0, {}

    try:
        wb = open_workbook(file_name)
    except (xlrd.XLRDError, IOError, IndexError, TypeError) as e:
        print e
        print file_url
        _delete_file(file_name)
        return False, 0, {}

    s = wb.sheets()[0]
    if not s:
        _delete_file(file_name)
        return False, 0, {}

    content, content_size = [], 0

    headers = [unicode(s.cell(0, x).value) for x in range(s.ncols)]
    headers = _format_headers_for_mongo(headers)
    for x in range(1, s.nrows):
        content_row = { headers[y]: unicode(s.cell(x, y).value) for y in range(s.ncols) }
        if '' in content_row:
            del content_row['']
        if not content_row:
            continue
        content.append(content_row)
        content_size += len(bson.BSON.encode(content_row))
        column_datatype_probability = _compute_column_datatype_probability(content)

    _delete_file(file_name)
    return content, content_size, column_datatype_probability

def parse_json(file_url):
    file_name = _get_file(file_url)
    if not file_name:
        print "No file"
        return False, 0, {}

    try:
        json_data = open(file_name).read()
        json_data = json.loads(json_data)
    except (IOError, TypeError) as e:
        print e
        _delete_file(file_name)
        return False, 0, {}

    fields, data = json_data['fields'], json_data['data']
    headers = [x['label'] for x in fields]
    if _is_row_empty(headers):
        return False, 0, {} #NO Headers

    headers = _format_headers_for_mongo(headers)
    content, content_size = [], 0

    for x in data:
        content_row = { headers[i]: x[i] for i in range(len(headers)) if not _is_row_empty(x) }
        if '' in content_row:
            del content_row['']
        if not content_row:
            continue
        content_size += len(bson.BSON.encode(content_row))
        content.append(content_row)
        column_datatype_probability = _compute_column_datatype_probability(content)

    _delete_file(file_name)
    return content, content_size, column_datatype_probability

def _is_row_empty(row):
    return False if row and row[0].strip() else True

def _download_file(url, destination_directory='/tmp/goi/'):
    file_name = str(uuid.uuid4())
    exit_code = subprocess.call(['wget', '--tries=2', url, '-O', destination_directory + file_name])
    if exit_code == 0: #File Downloaded successfully
        print destination_directory + file_name
        return destination_directory + file_name
    else:
        return False

def _delete_file(file_name):
    os.remove(file_name) #Delete file

def _get_file(file_url):
    file_name = _download_file(file_url)
    if not file_name:
        return False
    else:
        return file_name


def _format_headers_for_mongo(headers):
    for x in range(0, len(headers)):
        headers[x] = headers[x].replace('.', "_").replace(' ',"_")

    return headers

def _compute_column_datatype_probability(content):
    column_type_probability = {}
    headers = content[0].keys()
    for x in headers:
        dtc = { 'string': 0, 'integer': 0, 'double': 0, 'boolean': 0, 'blank': 0, 'date': 0 }

        for y in range(len(content)):
            content[y][x], datatype = parse_datatype(content[y][x])
            dtc[datatype] += 1

        # dtc_foramt = {}
        # dtc_foramt['datatype_probability'] = dtc
        # column_type_probability[x] = json.dumps(dtc_foramt)
        column_type_probability[x] = _strip_extra_parameters(column_type_probability[x])

    return column_type_probability

def _strip_extra_parameters(column_type_probability):
    column_type_probability = [ (v,k) for k,v in column_type_probability.iteritems() if v > 0]
    column_type_probability = { k: v for (v,k) in column_type_probability  }
    for k, v in column_type_probability.items():
        column_type_probability[k] = v
    return column_type_probability

def _compute_column_datatype_probability(content):
    column_type_probability = {}
    headers = content[0].keys()
    for x in headers:
        dtc = { 'string': 0, 'integer': 0, 'double': 0, 'boolean': 0, 'blank': 0, 'date': 0 }

        for y in range(len(content)):
            try:
                content[y][x], datatype = parse_datatype(content[y][x])
            except KeyError as e:
                datatype = 'blank'

            dtc[datatype] += 1

        column_type_probability[x] = dtc
        column_type_probability[x] = _strip_extra_parameters(column_type_probability[x])

    return column_type_probability

def _strip_extra_parameters(column_type_probability):
    column_type_probability = [ (v,k) for k,v in column_type_probability.iteritems() if v > 0]
    column_type_probability = { k: v for (v,k) in column_type_probability  }
    for k, v in column_type_probability.items():
        column_type_probability[k] = v
    return column_type_probability


# a, b, c = parse_csv('a')
# #print a
# print b
# print c
#
#
# for column_name, cdtp in c.iteritems():
#     print cdtp
#     datatype = max(cdtp[column_name], key=cdtp[column_name].get)
#     print column_name, datatype
#     prop = {}
#     prop['datatype_probability'] = json.dumps(cdtp)
#     print prop