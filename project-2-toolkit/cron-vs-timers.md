# Cron vs systemd Timers

## Three things systemd timers give you

1. **Better status and monitoring**
   systemd timers can be checked easily with `systemctl list-timers` and `systemctl status`.

2. **Better integration with systemd**
   The timer works with a systemd service, so logs, status, and service control are handled by systemd.

3. **Persistent scheduling**
   With `Persistent=true`, a missed scheduled job can run when the system starts again.

## When cron is better

Cron is still a good choice for simple jobs. If I only need a small command to run at a fixed time and do not need systemd features, cron is simpler and easier to set up.

## What Persistent=true means

`Persistent=true` means that if the computer is turned off when the scheduled time arrives, systemd remembers that the job was missed. When the computer starts again, the timer can run the missed job instead of waiting for the next scheduled time.
