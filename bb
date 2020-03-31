#!/usr/bin/env raku

use URI;

#| Browse repository in BitBucket.
sub MAIN(
  $file? where { !$file.defined or $file.IO.f }, #= open a file
  Str :$remote-name = "origin",                  #= open this bitbucket remote
  Str :$cmd = "open"                             #= command to run
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
