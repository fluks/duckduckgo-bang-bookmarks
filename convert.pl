#!/usr/bin/env perl
use strict;
use warnings;
use v5.10;
use feature 'signatures';
no warnings 'experimental::signatures';
use English;
use LWP::Simple;
use LWP::UserAgent;
use HTML::TokeParser;
use Mojo::DOM;
use URI;

my $html = get_bangs_html();
my @bangs = get_bangs($html);

my $bookmarks :shared = qq[<DT><H3 ADD_DATE="${\time()}">DDG Bang Bookmarks</H3>\n<DL><p>];

require Thread::Pool;
my $pool = Thread::Pool->new({
    workers => 20,
    do => \&create_bookmark,
    monitor => \&aggregate_bookmarks,
});
$pool->job($_) for @bangs;
$pool->shutdown;

$bookmarks .= qq[</DL></p>];

if (@ARGV == 1) {
    add_bookmarks($bookmarks, $ARGV[0]);
}
else {
    save_bookmarks($bookmarks);
}

sub get_bangs_html() {
    my $bangs_url = 'https://duckduckgo.com/bang_lite.html';
    my $html = get($bangs_url);
    if (!defined $html) {
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

sub create_bookmark($bang) {    
    my $ua = LWP::UserAgent->new(agent
        => 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0');
    my $search_url = 'https://duckduckgo.com/html/?q=';
    my $query = 'mynotrandomtext';
    # DDG limits traffic.
    sleep(1);
    my $res = $ua->get($search_url . "!$bang $query");
    if ($res->is_success && $res->decoded_content) {
        my $dom = Mojo::DOM->new($res->decoded_content);
        my $title = $dom->at('title');
        if ($title) {
            $title = $title->text;
            $title =~ s/$query//;
        }
        else {
            $title = URI->new($res->base)->host;
        }

        my $url = $res->base;
        $url =~ s/$query/%s/;

        my $add_time = time();
        my $bm_entry = qq[<DT><A HREF="$url" ADD_DATE="$add_time" SHORTCUTURL="$bang">$title</A>\n];

        return $bm_entry;
    }
}

sub aggregate_bookmarks($bm_entry) {
    STDOUT->autoflush(1);
    say $bm_entry;
    if ($bm_entry) {
        lock($bookmarks);
        say $bm_entry;
        $bookmarks .= $bm_entry;
    }
}

sub add_bookmarks($bookmarks, $bookmarks_file) {
    local undef $INPUT_RECORD_SEPARATOR;
    open (my $fh, '<', $bookmarks_file)
        || die "Can't open bookmarks for reading: $!";
    my $dom = Mojo::DOM->new(<$fh>);
    $dom->find('h3')->last->append($bookmarks);
    
    open (my $fh_new, '>', 'bookmarks_and_ddg_bang_bookmarks.html')
        || die "Can't open new bookmarks file: $!";
    say $fh_new "$dom"; 
}

sub save_bookmarks($bookmarks) {
    open(my $fh, '>', 'ddg_bang_bookmarks.html')
        || die "Can't open new bookrmaks file for saving: $!";
    print $fh $bookmarks;
}
