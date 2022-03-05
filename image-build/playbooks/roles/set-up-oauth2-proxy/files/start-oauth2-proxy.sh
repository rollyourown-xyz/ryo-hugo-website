#!/bin/sh
# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Start oauth2-proxy
/usr/local/bin/oauth2-proxy --config=/etc/oauth2-proxy.cfg --email-domain=*
