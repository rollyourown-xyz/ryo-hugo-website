#!/bin/sh

# Start webhook
/usr/local/bin/webhook -port 80 -hooks /usr/local/bin/hooks.yaml
