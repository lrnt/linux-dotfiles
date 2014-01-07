#!/usr/bin/env python

import shlex, subprocess
import re

from time import time

_HOST = "localhost"
_PORT = "6600"
_CMD = "/usr/bin/mpc -h %s -p %s status" % (_HOST, _PORT)
_INTERVAL = 5

class Py3status:
    def mpd(self, json, i3status_config):
        response = {'full_text': 'MPD', 'name': 'mpd'}

        mpc = subprocess.Popen(shlex.split(_CMD), stdout=subprocess.PIPE)

        if mpc.wait() == 0:
            output = mpc.communicate()[0].decode("utf-8").splitlines()

            if len(output) > 2:
                song = output[0]
                status = re.search(r'\[([a-z]*)\]', output[1]).group(1)

                response['full_text'] = song

                if status != 'playing':
                    response['color'] = i3status_config['color_degraded']

        else:
            response['color'] = i3status_config['color_bad']

        response['cached_until'] = time() + _INTERVAL

        return (0, response)
