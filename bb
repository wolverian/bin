#!/usr/bin/env raku

use URI;

sub MAIN(
  $file? where { !$file.defined or $file.IO.f },
  Str :$remote-name = "origin",
  Str :$cmd = "open"
) {
  my $remote = qqx|git remote get-url {$remote-name}|;
  my $u = URI.new($remote.trim);

  $u.scheme("https");
  $u.authority.userinfo = Nil;
  $u.authority.port = Nil;

  my ($project, $repo) = $u.path.segments[1,2];
  $repo.=subst(rx|\.git$|, "");

  if $file {
    $u.path("/projects/{$project}/repos/{$repo}/browse/{$file}");
  } else {
    $u.path("/projects/{$project}/repos/{$repo}");
  }

  shell "$cmd $u";
}
