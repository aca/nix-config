# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## NixOS System Configuration

This is a NixOS configuration repository. The main system switch command is:
```bash
./@/switch
```

## cgit with Caddy Setup

The cgit web interface for Git repositories is configured in `./cgit.nix`. Key details:

- Runs on `http://localhost:80` (no TLS/SSL)
- Uses Caddy as the web server with FastCGI to cgit
- Socket path: `/run/fcgiwrap-cgit.sock`
- Git repositories location: `/var/lib/git/repositories`
- Static files (CSS/images) served under `/cgit-css/*`

### Git Operations
- Clone: `git clone http://localhost/git/<repo-name>.git`
- Push/pull work over HTTP with anonymous access enabled
- Create new repositories: `sudo /etc/git-scripts/create-repo.sh <repo-name>`

### Common Issues
- If socket permission errors occur, restart the fcgiwrap socket:
  ```bash
  sudo systemctl stop fcgiwrap-cgit.socket fcgiwrap-cgit.service
  sudo systemctl start fcgiwrap-cgit.socket
  ```
- For push access, ensure repository has: `git config http.receivepack true`

### Testing
To test the cgit setup:
1. Check web interface: `curl http://localhost/`
2. Check static files: `curl http://localhost/cgit-css/cgit.css`
3. Create test repo and clone/push/pull as shown in the Git Operations section