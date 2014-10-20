#!/usr/bin/env python

from os import walk, listdir
from os.path import expanduser, join
from time import time

_MAILDIR = "~/mail/"
_INTERVAL = 30
_POSITION = 2

class Py3status:
    def mail(self, jsong, i3status_config):
        count = list()

        for account in listdir(expanduser(_MAILDIR)):
            path = join(expanduser(_MAILDIR), account, 'INBOX/new')
            count.append(len(next(walk(path))[2]))

        response = {'name': 'mail',
                    'full_text': '[%s]' % ':'.join(str(x) for x in count),
                    'cached_until': time() + _INTERVAL}

        if sum(count) > 0:
            response['color'] = i3status_config['color_bad']

        return (_POSITION, response)
