#!/bin/sh

# Start webhook
/usr/local/bin/webhook -port 80 -urlprefix "{{ project_id }}" -hooks /usr/local/bin/hooks.yaml
