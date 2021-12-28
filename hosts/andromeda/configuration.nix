{ config, pkgs, lib, options, ... }:

with lib;
{
  #############################################################################
  ## System Configuration
  #############################################################################

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 30;

  #############################################################################
  ## Networking
  #############################################################################

  networking.hostName = "andromeda";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.firewall.trustedInterfaces = [ "lo" "eth0" ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  #############################################################################
  ## Package Management
  #############################################################################

  environment.systemPackages = with pkgs;
    [
      inetutils
      mtr
      sysstat
    ];

  #############################################################################
  ## Services
  #############################################################################

  # WWW
  services.caddy.enable = true;
  services.caddy.config = ''
    {
      log {
        level INFO
        output file /var/log/caddy/caddy.log {
          roll_size     100MiB
          roll_keep     5
          roll_keep_for 720h
        }
      }
    }

    (common_config) {
      encode gzip

      header Permissions-Policy "interest-cohort=()"
      header Referrer-Policy "strict-origin-when-cross-origin"
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      header X-Content-Type-Options "nosniff"
      header X-Frame-Options "SAMEORIGIN"

      header -Server
    }

    balajisivaraman.com {
      import common_config
      redir https://www.balajisivaraman.com{uri}
    }

    www.balajisivaraman.com {
      import common_config

      file_server {
        root /var/www/balajisivaraman.com/home
      }

      ${fileContents ./www-balajisivaraman-com.caddyfile}
    }

    blog.balajisivaraman.com {
      import common_config

      file_server {
        root /var/www/balajisivaraman.com/blog
      }
    }

    mta-sts.balajisivaraman.com {
      file_server {
        root /var/www/balajisivaraman.com/mta-sts
      }
    }

    cloud.balajisivaraman.com {
      import common_config
      header -X-Content-Type-Options

      root * ${config.services.nextcloud.package}
      php_fastcgi unix/${config.services.phpfpm.pools.nextcloud.settings.listen} {
        env front_controller_active true
      }
      file_server

      rewrite /index.php/* /index.php?{query}
      redir /.well-known/carddav /remote.php/dav 301
      redir /.well-known/caldav /remote.php/dav 301

      @store {
        path_regexp store ^/store-apps
      }

      handle @store {
             root * ${config.services.nextcloud.home}
      }

      # .htaccess / data / config / ... shouldn't be accessible from outside
      @forbidden {
        path    /.htaccess
        path    /data/*
        path    /config/*
        path    /db_structure
        path    /.xml
        path    /README
        path    /3rdparty/*
        path    /lib/*
        path    /templates/*
        path    /occ
        path    /console.php
      }

      respond @forbidden 404
    }

    feeddb.balajisivaraman.com {
      import common_config
      reverse_proxy http://127.0.0.1:8888
    }

    git.balajisivaraman.com {
      import common_config
      reverse_proxy http://127.0.0.1:3001
    }
  '';

  services.fail2ban.enable = true;

  # Cloud
  services.nginx.enable = false;
  services.nextcloud = {
    config = {
      adminuser = "root";
      adminpassFile = "/var/lib/nextcloud/.adminpass";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbport = "5432";
      dbtype = "pgsql";
      dbuser = "nextcloud";
      extraTrustedDomains = [ "cloud.balajisivaraman.com" ];
    };
    enable = true;
    hostName = "cloud.balajisivaraman.com";
    https = true;
    package = pkgs.nextcloud22.overrideAttrs (oldAttrs: rec {
      version = "22.2.2";
      name = "nextcloud-${version}";
      src = pkgs.fetchurl {
        url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
        sha256 = "sha256-lDvn29N19Lhm3P2YIVM/85vr/U07qR+M8TkF/D/GTfA=";
      };
    });
    poolSettings = {
      "pm" = "dynamic";
      "pm.max_children" = "5";
      "pm.start_servers" = "2";
      "pm.min_spare_servers" = "1";
      "pm.max_spare_servers" = "3";
    };
  };

  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  services.phpfpm.pools.nextcloud.settings = {
    "listen.owner" = "caddy";
    "listen.group" = "caddy";
  };

  # Git
  services.gitea = {
    enable = true;
    appName = "Balaji Sivaraman - Git";
    database = {
      host = "/run/postgresql";
      port = 5432;
      type = "postgres";
      user = "gitea";
      name = "gitea";
      createDatabase = false;
    };
    domain = "balajisivaraman.com";
    rootUrl = "https://git.balajisivaraman.com";
    httpPort = 3001;
  };

  # RSS Reader
  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "localhost:8888";
      BASE_URL = "https://feeddb.balajisivaraman.com/";
    };
    adminCredentialsFile = "/home/balaji/miniflux-admin-credentials";
  };

  # SSH
  # Every machine gets an sshd
  services.openssh = {
    enable = true;
    # Do not allow root login. We already create the user we need as part of this configuration.
    permitRootLogin = "no";
    # Only pubkey auth
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  # Start ssh-agent as a systemd user service
  programs.ssh.startAgent = true;

  # Postgres
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    ensureDatabases = [ "gitea" "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions = {
          "DATABASE nextcloud" = "ALL PRIVILEGES";
        };
      }
      {
        name = "gitea";
        ensurePermissions = {
          "DATABASE gitea" = "ALL PRIVILEGES";
        };
      }
    ];
    authentication = ''
      local gitea all ident map=gitea-users
    '';
    # Map the gitea user to postgresql
    identMap =
    ''
      gitea-users gitea gitea
    '';
  };
}
