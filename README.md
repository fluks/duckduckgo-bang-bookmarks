# Description

Use DuckDuckGo bangs without connecting to DuckDuckGo at all. The bangs are
saved as HTML bookmarks and you can import them to Firefox.

# Requirements

* Python3

# Usage

`python3 ddg_json_bangs_to_ff_bookmarks.py bang.v260.js <out file>`

Or you can just download the [bangs.html file](https://github.com/fluks/duckduckgo-bang-bookmarks/blob/master/bangs.html?raw=true)
I already created.

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
