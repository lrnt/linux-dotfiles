#!/usr/bin/env python

from os import walk, listdir
from os.path import expanduser, join
from time import time, sleep

MAILDIR = '~/.mail/'
INBOX = 'inbox'
INTERVAL = 30


class Py3status:
    def mail(self, jsong, i3status_config):
        count = list()
        mail_dir = expanduser(MAILDIR)
        response = {
            'name': 'mail',
            'chached_until': time() + INTERVAL
        }

        for account in listdir(mail_dir):
            account_dir = join(mail_dir, account)
            mailboxes = {
                m: len(next(walk(join(account_dir, m, 'new')))[2])
                for m in listdir(account_dir)
            }
            inbox_count = mailboxes.pop(INBOX)
            mailbox_count = sum(mailboxes.values())
            count.append('{}.{}'.format(inbox_count, mailbox_count))

            if inbox_count > 0:
                response['color'] = i3status_config['color_bad']

        response['full_text'] = '[{}]'.format(':'.join(x for x in count))

        return response


if __name__ == "__main__":
    x = Py3status()
    while True:
        config = {
            'color_bad': '#FF0000',
            'color_degraded': '#FFFF00',
            'color_good': '#00FF00'
        }
        print(x.mail([], config))
        sleep(1)
