# Description

Use DuckDuckGo bangs without connecting to DuckDuckGo at all. The bangs are
saved as HTML bookmarks and you can import them to Firefox.

Well, not all bangs, because there are problems connecting to Tor and some
other problems too. There are 9886 bangs on DuckDuckGo and 9342 currently
in [](ddg_bang_bookmarks.html) file.

# Requirements

* HTML::TokeParser
Probably Needed
* Tor
* torify

# Usage

Run the script with Tor. This is needed because DuckDuckGo rate limits traffic
and simply limiting requests doesn't seem to work that well or I don't know how
long time between requests there should be. Saves bangs in
ddg_bang_bookmarks.html. Running the script takes many hours.

`torify ./convert.pl`

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