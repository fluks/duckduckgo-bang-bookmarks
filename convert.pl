#!/usr/bin/env perl
use strict;
use warnings;
use v5.10;
use feature 'signatures';
no warnings 'experimental::signatures';
use English;
use LWP::UserAgent;
use HTML::TokeParser;
use URI;
use URI::Escape;
use IO::Handle;
use open qw(:utf8 :std);
use utf8;

STDOUT->autoflush(1);
STDERR->autoflush(1);

my $ua = LWP::UserAgent->new(agent
    => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0');
my $html = get_bangs_html($ua);
my @bangs = get_bangs($html);

my $write_mode = '>';
if (scalar @ARGV == 1) {
    $write_mode = '>>';
}
open (my $bookmarks_fh, $write_mode, 'ddg_bang_bookmarks.html')
    || die "Can't open bookmarks file for saving: $!";
$bookmarks_fh->autoflush(1);
if ($write_mode eq '>') {
    say $bookmarks_fh qq[<DT><H3 ADD_DATE="${\time()}">DDG Bang Bookmarks</H3>\n<DL><p>];
}

my %bang_urls;
for my $bang (@bangs) {
    if ($write_mode eq '>>' && bang_exists($bang)) {
        next;
    }

    my $bm = create_bookmark($ua, $bang, \%bang_urls);
    say $bookmarks_fh $bm if $bm;

    # DDG limits traffic.
    sleep(10);
}

say $bookmarks_fh qq[</DL></p>];

sub bang_exists($bang) {
    my $p = HTML::TokeParser->new($ARGV[0])
        || die "Can't parse previous bookmarks file: $!";

    while (my $a = $p->get_tag('a')) {
        return 1 if @$a[1]->{shortcuturl} eq $bang;
    }
}

sub get_bangs_html($ua) {
    my $bangs_url = 'https://duckduckgo.com/bang_lite.html';
    my $res = $ua->get($bangs_url);
    my $html = $res->decoded_content;
    if (!$html) {
        die "Couldn't GET bangs page";
    }

    return $html;
}

sub get_bangs($html) {
    my $parser = HTML::TokeParser->new(\$html) || die "Couldn't parse HTML";
    my $bangs;
    while (my $token = $parser->get_tag('span')) {
        if (@$token[1]->{class} eq 'small') {
            $bangs = $parser->get_text('/span');
            last;
        }
    }

    return $bangs =~ /\(!([^(]*)\)/g;
}

sub create_bookmark($ua, $bang, $bang_urls) {
    my $search_url = 'https://duckduckgo.com/?q=';
    my $query = random_text(16);
    my $res = $ua->get($search_url . "!$bang $query");
    my $html = $res->decoded_content;
    my $url;
    if ($html =~ /uddg=(.+?)'/) {
        $url = uri_unescape($1);
    }
    elsif ($html =~ /url=(.+?)'/){
        $url = $1;
    }

    if ($url) {
        say "$bang $url";

        my $host = URI->new($url)->host;
        my $title = "!$bang @ $host";

        $url =~ s/$query/%s/g;
        $bang_urls->{$url}++;
        # If there are bangs with the same URL, but different keyword, all
        # bangs will have the same keyword after importing them. Add fragment
        # identifier(s) when there are multiple bangs with the same URL.
        $url .= '#' x ($bang_urls->{$url} - 1);

        my $add_time = time();
        my $bm_entry = qq[<DT><A HREF="$url" ADD_DATE="$add_time" SHORTCUTURL="$bang">$title</A>];

        return $bm_entry;
    }
    else {
        say STDERR "Error searching with a $bang: " . $res->status_line;
        return undef;
    }
}

sub random_text($n) {
    my $s = '';
    for (1 .. $n) {
        my @chars = ('a' .. 'z', 1 .. 9);
        $s .= $chars[rand() * scalar @chars];
    }
    return $s;
}
