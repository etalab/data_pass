#!/bin/bash

rm -f app/migration/dumps/*
./app/migration/export_v1.sh
./app/migration/export_v2.sh
./app/migration/export_hubee.sh
