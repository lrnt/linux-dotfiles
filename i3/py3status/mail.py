#!/usr/bin/env python

from os import walk, listdir
from os.path import expanduser, join
from time import time

_MAILDIR = "~/mail/"
_INTERVAL = 30

class Py3status:
    def mail(self, jsong, i3status_config):
        count = 0

        for account in listdir(expanduser(_MAILDIR)):
            path = join(expanduser(_MAILDIR), account, 'INBOX/new')
            count += len(next(walk(path))[2])

        response = {'name': 'mail',
                    'full_text': '[%d]' % count,
                    'cached_until': time() + _INTERVAL}

        if count > 0:
            response['color'] = i3status_config['color_bad']

        return (0, response)
