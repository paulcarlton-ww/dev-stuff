#!/bin/bash

for c in `env | cut -f1 -d= | grep -i proxy`; do unset $c;done
