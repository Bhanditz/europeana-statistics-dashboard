import time
import string
from dateutil.parser import parse



def parse_datatype(x):
    # Ordering of these conditions is extremely important.
    # Do not change order of test conditions
    if x is None:
        return x, 'blank'

    try:
        int(x)
        return x, 'integer'
    except (ValueError, TypeError) as e:
        pass

    try:
        float(x)
        return x, 'double'
    except (ValueError, TypeError) as e:
        pass

    if not x.strip(): return x, 'blank'
    if len(x) > 30: return x, 'string'

    if x in ['t', 'f', "true", "false", 'y', 'n', 'yes', 'no']: return x, 'boolean'

    count_chars = lambda l1, l2: len(list(filter(lambda c: c in l2, l1)))
    ascii_chars = count_chars(x, string.letters) #'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    if ascii_chars > 3: return x, 'string'


    valid_date_other_chars = ':-/'
    other_chars = count_chars(x, string.punctuation) #'!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
    valid_chars = count_chars(x, valid_date_other_chars)

    if other_chars > valid_chars or valid_chars < 2: return x, 'string'

    try:
        date_time = parse(x, yearfirst= True)
        only_date = date_time.replace(hour=0, minute=0, second=0, microsecond=0)
        if date_time == only_date:
            x = str(date_time.date())
            return x, 'date'
        else:
            #return 'DateTime'
            return x, 'string' #for now
    except:
        return x, 'string'



# a = [u'4-5', u'4 h $%', u"\t\nskbdsjd", u'7873', u'3232.232', u'24-12-2015', u'24-12-2015 12:12:12',u'2004-2005-2006', u'     ', u'yes', u'24/12/1989']
# a.append(u'24/12/1989')
# a.append(u'1,000')
# for x in a:
#     print parse_datatype(x)