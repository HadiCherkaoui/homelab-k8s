# Placeholder Certificates

This directory contains placeholder self-signed certificates that are used temporarily until Let's Encrypt certificates are issued.

The files in this directory:
- `placeholder.crt`: Self-signed certificate for `*.cherkaoui.ch`
- `placeholder.key`: Private key for the self-signed certificate

These certificates are only used if Let's Encrypt integration is disabled or before the actual certificates are issued. They will be automatically replaced by valid Let's Encrypt certificates once the system is up and running.

**Note**: These certificates are not meant to be trusted and will generate browser warnings if used. They are only placeholders.
