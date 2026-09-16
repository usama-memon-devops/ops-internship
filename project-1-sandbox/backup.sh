#!/bin/bash

mkdir -p /opt/backups
DATE=$(date +%Y-%m-%d)
tar -czf /opt/backups/project_files-$DATE.tar.gz /opt/project_files
du -h /opt/backups/project_files-$DATE.tar.gz

