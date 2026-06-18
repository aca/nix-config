{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Enable Caddy web server
  services.caddy.enable = true;

  services.caddy.virtualHosts."git.internal" = {
    extraConfig = ''
      tls ${inputs.internal}/certs/internal/internal-cert.pem ${inputs.internal}/certs/internal/internal-key.pem
      # Handle git smart HTTP protocol operations
      @git_smart {
        path_regexp gitpath ^/([\w-/]+)(\.git)?/(info/refs|git-upload-pack|git-receive-pack|HEAD|objects/.+|refs/.+)$
      }
      @git_query {
        query service=git-upload-pack
      }
      @git_query2 {
        query service=git-receive-pack
      }

      handle @git_smart {
        reverse_proxy unix//run/fcgiwrap-cgit.sock {
          transport fastcgi {
            env SCRIPT_FILENAME ${pkgs.git}/libexec/git-core/git-http-backend
            env GIT_HTTP_EXPORT_ALL "1"
            env GIT_PROJECT_ROOT /home/rok/src/git.internal
            env PATH_INFO {path}
            env REMOTE_USER "anonymous"
          }
        }

        # Allow large uploads
        request_body {
          max_size 100MB
        }
      }

      handle @git_query {
        reverse_proxy unix//run/fcgiwrap-cgit.sock {
          transport fastcgi {
            env SCRIPT_FILENAME ${pkgs.git}/libexec/git-core/git-http-backend
            env GIT_HTTP_EXPORT_ALL "1"
            env GIT_PROJECT_ROOT /home/rok/src/git.internal
            env PATH_INFO {path}
            env REMOTE_USER "anonymous"
          }
        }

        # Allow large uploads
        request_body {
          max_size 100MB
        }
      }

      handle @git_query2 {
        reverse_proxy unix//run/fcgiwrap-cgit.sock {
          transport fastcgi {
            env SCRIPT_FILENAME ${pkgs.git}/libexec/git-core/git-http-backend
            env GIT_HTTP_EXPORT_ALL "1"
            env GIT_PROJECT_ROOT /home/rok/src/git.internal
            env PATH_INFO {path}
            env REMOTE_USER "anonymous"
          }
        }

        # Allow large uploads
        request_body {
          max_size 100MB
        }
      }

      # cgit web interface (catch-all for non-git operations)
      handle /* {
        @cgit {
          not path /cgit-css/*
          not path /git/*
        }

        handle @cgit {
          reverse_proxy unix//run/fcgiwrap-cgit.sock {
            transport fastcgi {
              env SCRIPT_FILENAME ${pkgs.cgit}/cgit/cgit.cgi
              env PATH_INFO {path}
              env QUERY_STRING {query}
              env HTTP_HOST {host}
            }
          }
        }

        # Static files
        handle /cgit-css/* {
          uri strip_prefix /cgit-css
          root * ${pkgs.cgit}/cgit
          file_server
        }
      }

      # Git HTTP backend for /git/* (standard path)
      handle /git/* {
        uri strip_prefix /git

        reverse_proxy unix//run/fcgiwrap-cgit.sock {
          transport fastcgi {
            env SCRIPT_FILENAME ${pkgs.git}/libexec/git-core/git-http-backend
            env GIT_HTTP_EXPORT_ALL "1"
            env GIT_PROJECT_ROOT /home/rok/src/git.internal
            env PATH_INFO {path}
            env REMOTE_USER "anonymous"
          }
        }

        # Allow large uploads
        request_body {
          max_size 100MB
        }
      }

      # Optional: Upload handler endpoint
      handle /upload/* {
        reverse_proxy unix//run/fcgiwrap-cgit.sock {
          transport fastcgi {
            env SCRIPT_FILENAME /etc/git-scripts/upload-handler.py
            env PATH_INFO {path}
          }
        }
      }
    '';
  };

  # Enable fcgiwrap for CGI
  services.fcgiwrap.instances.cgit = {
    process.user = "rok";
    process.group = "users";
    socket = {
      type = "unix";
      address = "/run/fcgiwrap-cgit.sock";
      user = "caddy";
      group = "caddy";
      mode = "0660";
    };
  };

  # cgit configuration
  environment.etc."cgitrc".text = ''
    # CSS and logo
    css=/cgit-css/cgit.css
    logo=/cgit-css/cgit.png

    # Where to look for repositories
    scan-path=/home/rok/src/git.internal

    # Remove .git suffix from project names
    remove-suffix=1

    # Enable features
    enable-index-links=1
    enable-log-filecount=1
    enable-log-linecount=1
    enable-commit-graph=1
    enable-blame=1
    enable-git-config=1

    # Allow owners to modify repo settings
    enable-git-config=1

    # Caching
    cache-size=1000
    cache-root=/var/cache/cgit

    # Clone URLs
    clone-url=http://localhost/git/$CGIT_REPO_URL

    # Site info
    root-title=My Git Server
    root-desc=Self-hosted Git repositories with cgit

    # Readme files
    readme=:README.md
    readme=:readme.md
    readme=:README

    # Source highlighting (optional)
    source-filter=${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.py

    # About filter for markdown (optional)
    about-filter=${pkgs.cgit}/lib/cgit/filters/about-formatting.sh

    # Snapshot formats
    snapshots=tar.gz tar.bz2 zip

    # Repository settings
    enable-subject-links=1
    enable-tree-linenumbers=1
    max-stats=quarter

    # Upload settings
    max-blob-size=104857600  # 100MB max file size
  '';

  # Create directories and set permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/git/repositories 0755 git git -"
    "d /var/cache/cgit 0755 git git -"
  ];

  # Open firewall for HTTP
  networking.firewall.allowedTCPPorts = [ 80 ];

  # Install required packages
  environment.systemPackages = with pkgs; [
    git
    cgit
    # For creating Caddy passwords: caddy hash-password
    caddy
  ];

  # Script to create new repositories with upload hook
  environment.etc."git-scripts/create-repo.sh" = {
    text = ''
      #!/usr/bin/env bash

      if [ $# -ne 1 ]; then
        echo "Usage: $0 <repository-name>"
        exit 1
      fi

      REPO_NAME="$1"
      REPO_PATH="/var/lib/git/repositories/''${REPO_NAME}.git"

      if [ -d "$REPO_PATH" ]; then
        echo "Repository already exists!"
        exit 1
      fi

      # Create bare repository
      sudo -u git git init --bare "$REPO_PATH"

      # Configure repository
      sudo -u git git -C "$REPO_PATH" config http.receivepack true
      sudo -u git git -C "$REPO_PATH" config receive.denyNonFastForwards false

      # Create post-receive hook for notifications (optional)
      cat << 'EOF' | sudo -u git tee "$REPO_PATH/hooks/post-receive" > /dev/null
      #!/usr/bin/env bash
      # Add any post-receive logic here
      echo "Push received for repository: ''${PWD##*/}"
      EOF

      sudo -u git chmod +x "$REPO_PATH/hooks/post-receive"

      # Create cgitrc for repo-specific settings
      cat << EOF | sudo -u git tee "$REPO_PATH/cgitrc" > /dev/null
      # Repository specific settings
      desc=Description for $REPO_NAME
      owner=Your Name
      EOF

      echo "Repository created at: $REPO_PATH"
      echo "Clone URL: http://localhost/git/''${REPO_NAME}.git"
    '';
    mode = "0755";
  };

  # Script for file upload via web interface
  environment.etc."git-scripts/upload-handler.py" = {
    text = ''
      #!/usr/bin/env python3

      import os
      import sys
      import cgi
      import cgitb

      cgitb.enable()

      print("Content-Type: text/html\n")

      form = cgi.FieldStorage()

      if "file" in form:
          fileitem = form["file"]
          repo = form.getvalue("repo", "")

          if fileitem.filename:
              # Security: sanitize filename
              filename = os.path.basename(fileitem.filename)
              repo_path = f"/var/lib/git/repositories/{repo}.git"

              if os.path.exists(repo_path):
                  # Save uploaded file to a temporary location
                  upload_path = f"/tmp/git-upload-{filename}"
                  with open(upload_path, 'wb') as f:
                      f.write(fileitem.file.read())

                  print(f"<html><body>")
                  print(f"<h2>File uploaded successfully</h2>")
                  print(f"<p>File: {filename}</p>")
                  print(f"<p>Repository: {repo}</p>")
                  print(f"<p><a href='/'>Back to repositories</a></p>")
                  print(f"</body></html>")
              else:
                  print("<html><body><h2>Error: Repository not found</h2></body></html>")
          else:
              print("<html><body><h2>Error: No file selected</h2></body></html>")
      else:
          # Show upload form
          print("""
          <html>
          <body>
          <h2>Upload File to Repository</h2>
          <form method="post" enctype="multipart/form-data">
              Repository: <input type="text" name="repo" required><br><br>
              File: <input type="file" name="file" required><br><br>
              <input type="submit" value="Upload">
          </form>
          </body>
          </html>
          """)
    '';
    mode = "0755";
  };
}
