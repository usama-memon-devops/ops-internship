# Restore Test

## Purpose

This document records the real restore drill for Project 2.

The backup archive was restored after the contents of `/opt/project_files` were deleted.

## Archive Used

`/opt/backups/project_files-2026-09-08-0857.tar.gz`

## Restore Command

```bash
sudo /opt/scripts/restore.sh --confirm /opt/backups/project_files-2026-09-08-0857.tar.gz
```

## Restore Terminal Output

```text
[2026-09-09 08:34:57] START restore
[2026-09-09 08:34:57] Archive: /opt/backups/project_files-2026-09-08-0857.tar.gz
[2026-09-09 08:34:57] Checksum verified successfully
[2026-09-09 08:34:57] Archive extracted to staging: /tmp/restore-staging
[2026-09-09 08:34:57] Restored files to: /opt/project_files
[2026-09-09 08:34:57] RESULT: SUCCESS
```

## Verification

After the restore, `/opt/project_files` contained the restored files:

```text
total 12
drwxrwsr-x+ 2 admin devs  4096 Sep  8 07:55 .
drwxr-xr-x  5 root  root  4096 Sep  8 08:39 ..
-rw-rw-r--  1 dev   devs     0 Sep  8 07:55 test2.txt
-rw-rw-r--  1 admin admin   12 Sep  8 07:34 test.txt
```

## Result

**PASS** — The real restore completed successfully. The archive checksum was verified before extraction, the archive was extracted to staging, and the files were restored to `/opt/project_files`.
