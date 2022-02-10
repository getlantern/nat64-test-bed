#!/usr/bin/env python3

import sys


USAGE_STR =\
"""Converts an IPv4 address to an embedded IPv6 (two-group) suffix or
vice-versa. The input form is determined automatically.

Usage:
    %s address-or-suffix

Examples:
    192.168.1.1 converts to c0a8:11
    172.18.0.1  converts to ac12:1
    8.8.8.8     converts to 88:88

    c0a8:11 converts to 192.168.1.1
    ac12:1  converts to 172.18.0.1
    88:88   converts to 8.8.8.8 
""" % sys.argv[0]


def four_to_six(ipv4_address):
    fields = ipv4_address.split('.')
    if len(fields) != 4:
        raise Exception("expected four dot-separated fields")
    groups = []
    for field in fields:
        if field == "0":
            groups.append('')
        else:
            groups.append(format(int(field), 'x'))
    return groups[0] + groups[1] + ':' + groups[2] + groups[3]


def six_to_four(ipv6_suffix):
    groups = ipv6_suffix.split(':')
    if len(groups) != 2:
        raise Exception("expected two-group suffix")
    for i, group in enumerate(groups):
        while len(group) < 4:
            group = '0' + group
        groups[i] = group
    hex_fields = [groups[0][:2], groups[0][2:], groups[1][:2], groups[1][2:]]
    fields = []
    for hf in hex_fields:
        fields.append(str(int(hf, 16)))
    return '.'.join(fields)


def usage():
    print(USAGE_STR)


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] in ["-h", "--help", "help"]:
        usage()
        sys.exit(1)
    input = sys.argv[1]
    if "." in input:
        print(four_to_six(input))
        sys.exit(0)
    elif ":" in input:
        print(six_to_four(input))
        sys.exit(0)
    else:
        raise Exception("invalid input")