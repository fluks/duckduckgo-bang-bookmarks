# Description

Use DuckDuckGo bangs without connecting to DuckDuckGo at all. The bangs are
saved as HTML bookmarks and you can import them to Firefox.

Well, not all bangs, because there are problems connecting to Tor and some
other problems too. There are 13505 bangs on DuckDuckGo and 13511 currently
in the [bookmarks file](ddg_bang_bookmarks.html), meaning some of the bangs in the
file are probably old.

# Requirements

* HTML::TokeParser

Probably Needed
* Tor
* torsocks

# Usage

Run the script with Tor. This is needed because DuckDuckGo rate limits traffic
and simply limiting requests doesn't seem to work that well or I don't know how
long time between requests there should be. Saves bangs in
ddg_bang_bookmarks.html. Running the script takes many hours.

`torsocks ./convert.pl`

If you want to append new bangs.

`torsocks ./convert.pl <OLD_BOOKMARKS_FILE>`

Then move the new bangs inside the DL tags.

Then in Firefox open bookmarks.

`Bookmarks > Show All Bookmarks`
`Import and Backup > Import Bookmarks from HTML`

Importing bookmarks takes a while, but it should succeed, even if doesn't
appear to do anything. You should hide this bookmark folder somewhere deeper in
the bookmark hierarchy, because opening this folder will make your browser lag.

If you already have a bookmark with the same URL and have assigned a keyword to
it or if you have assigned a keyword that a new bookmark uses too, the old
keyword will be gone and used for the new one.

# License

GPL3.
