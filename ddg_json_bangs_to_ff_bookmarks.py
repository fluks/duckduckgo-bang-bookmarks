#!/usr/bin/env python3

import json
import sys
import math
import time

def main():
    json_file = sys.argv[1]
    out_file = sys.argv[2]
    with open(json_file) as fp:
        bangs = json.load(fp)
        with open(out_file, 'w') as f:
            epoch = math.ceil(time.time())
            f.write('<DT><H3 ADD_DATE="{}">DDG Bang Bookmarks</H3>\n<DL><p>\n'.format(epoch))
            for b in bangs:
                url = b['u'].replace('{{{s}}}', '%s')
                bang = b['t']
                domain = b['d']
                name = b['s']
                description = '!{} @ {} {}'.format(bang, domain, name)
                add_date = math.ceil(time.time())
                f.write('<DT><A HREF="{}" ADD_DATE="{}" SHORTCUTURL="!{}">{}</A>\n'.format(url, add_date, bang, description))
            f.write('</DL></p>\n')

if __name__ == '__main__':
    main()
