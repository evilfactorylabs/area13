<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>cache.komunix.org (di raspi) - UP</title>
  </head>
  <body>
<pre>













                                                                     __                  __
                                                                    /\ \                /\ \                                          __
                                                 ___     __      ___\ \ \___      __    \ \ \/'\     ___     ___ ___   __  __    ___ /\_\   __  _       ___   _ __    __
                                                /'___\ /'__`\   /'___\ \  _ `\  /'__`\   \ \ , <    / __`\ /' __` __`\/\ \/\ \ /' _ `\/\ \ /\ \/'\     / __`\/\`'__\/'_ `\
                                                /\ \__//\ \L\.\_/\ \__/\ \ \ \ \/\  __/  __\ \ \\`\ /\ \L\ \/\ \/\ \/\ \ \ \_\ \/\ \/\ \ \ \\/>   /  __/\ \L\ \ \ \//\ \L\ \
                                                \ \____\ \__/.\_\ \____\\ \_\ \_\ \____\/\_\\ \_\ \_\ \____/\ \_\ \_\ \_\ \____/\ \_\ \_\ \_\/\_/\_\/\_\ \____/\ \_\\ \____ \
                                                \/____/\/__/\/_/\/____/ \/_/\/_/\/____/\/_/ \/_/\/_/\/___/  \/_/\/_/\/_/\/___/  \/_/\/_/\/_/\//\/_/\/_/\/___/  \/_/ \/___L\ \
                                                                                                                                                   /\____/
                                                                                                                                                   \_/__/

                                                                                        <b>/nix/store milik bersama</b> | <b>tulung@komunix.org</b>





                > NixOS

                # /etc/nixos/configuration.nix

                { nix.settings.substituters = [ https://cache.komunix.org/ ]; }

                > GNU/Linux

                # /etc/nix/nix.conf

                fallback = true
                binary-caches = https://cache.komunix.org/ https://cache.nixos.org/

                # OR

                fallback = true
                substituters = https://cache.komunix.org


                > Mac OS

                # $HOME/.nixpkgs/darwin-configuration.nix

                nix.settings.substituters = pkgs.lib.mkBefore [ "https://cache.komunix.org/" ];

                > Flake

                nix.settings.experimental-features = [ "nix-command" "flakes" ];
                nix.settings.trusted-substituters = [ "https://cache.komunix.org" ];

                # Recomendation
                nix.settings.fallback = true;


                enjoy :^)

                ---

                # stats for nerds

                $> find /home/komunix/nfs/nix-cache -type f | wc -l

                $TOTAL_CACHE

                $> du -sh /home/komunix/nfs/nix-cache; echo; df -h /home/komunix/nfs/nix-cache; echo; date +%s

                $NICE

                Filesystem                      Size  Used Avail Use% Mounted on
                $USAGE

                $TIMESTAMP
</pre>
  </body>
</html>
