# golden-ubuntu

A **hardened, minimal Ubuntu base image** built for secure, reusable container development. This image serves as the foundation for production-ready container stacks such as PostgreSQL, Kafka, Redis, and more — all running on a secure and clean operating system layer.

## Features

-   Based on latest Ubuntu LTS (`22.04`)
-   System-level hardening (no SUID/SGID, no core dumps)
-   Runs as non-root user: `imdhruv99`
-   Only minimal essential packages (`bash`, `curl`, `ca-certificates`, etc.)
-   Unused services removed: `cron`, `rsyslog`, `systemd`
-   Ready for use as a secure foundation in multi-stage builds or production images

## Explanation of some of the commands

###### Why removing `cron, rsyslog, systemd`

-   `cron`: Used for scheduling tasks in OS, In containers, we do not need to schedule task. we can use K8s CronJobs or other CI/CD tools.

-   `rsyslog`: A logging daemon that's used on servers but overkill and insecure in containers

-   `systemd`: The init system for full OS, not needed in Docker where PID 1 is app or process.

###### `RUN find / -path /proc -prune -o -perm /6000 -type f -exec chmod a-s {} \;`

-   `SUID/SGID` permissions allow binaries to run with elevated privileges. Disable them in containers to eliminate unnecessary privilege escalation paths especially since containers typically run with reduced privileges.

###### `echo "umask 027" >> /etc/profile`

-   Setting a restrictive `umask` like `027` ensures new files have secure default permissions, it prevents users from accidentally exposing data to other users in the same container or pod

###### `RUN echo '* hard core 0' >> /etc/security/limits.conf`

-   Core dumps may contain sensitive runtime data. Disabling them is a common security control to prevent information leakage in crash scenarios.
