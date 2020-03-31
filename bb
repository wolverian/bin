#!/usr/bin/env raku

use URI;

sub MAIN(Str $remote-name = "origin") {
  my $remote = qqx|git remote get-url {$remote-name}|;
  my $u = URI.new($remote.trim);

  $u.scheme("https");
  $u.authority.userinfo = Nil;
  $u.authority.port = Nil;

  my ($project, $repo) = $u.path.segments[1,2];
  $repo.=subst(rx|\.git$|, "");
  $u.path("/projects/{$project}/repos/{$repo}");

  say $u;
}
