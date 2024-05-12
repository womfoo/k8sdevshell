{
  pkgs,
  ruby,
  writeScriptBin,
}: let
  ruby' = ruby.withPackages (ps: with ps; [netrc]);
  prog = pkgs.writeText "update-hosts-file" ''
    require 'hosts'

    hosts = Hosts::File.read('/etc/hosts')

    puts hosts
  '';
in
  writeScriptBin "uphosts" ''
    exec ${ruby'}/bin/ruby ${prog}
  ''
