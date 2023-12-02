{ pkgs, ruby, writeScriptBin }:

let
  ruby' = ruby.withPackages (ps: with ps; [ netrc ]);
  prog = pkgs.writeText "users-groups.json" ''
    require 'netrc'

    netrc = Netrc.read
    github_creds = netrc['github.com']

    if github_creds.nil?
      puts "Error: GitHub credentials not in .netrc file."
      exit
    end

    github_username, github_token = github_creds
    puts "export GIT_USERNAME=#{github_username}"
    puts "export GITHUB_TOKEN=#{github_token}"
  '';
in writeScriptBin "netrc2env" ''
  exec ${ruby'}/bin/ruby ${prog}
''
