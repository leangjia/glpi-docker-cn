#!/bin/bash
set -ex

/etc/init.d/cron reload
/etc/init.d/cron restart
/etc/init.d/cron status

exec "$@"
