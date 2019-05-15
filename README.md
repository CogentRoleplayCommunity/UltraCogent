OSRC Page source... (see http://www.osrc.rip)

Disclaimer:
The method used in here was designed from the beginning to handle hundreds, possibly thousands of pages easily by running a few commands in linux shell, requiring only a basic text editor capable of detecting changed content(gedit is fine), but no additional software what so ever. This is for sites that are constantly expanding, like OSRC, blogs, news page, shops, etc, where changes must be applied to possibly thousands of pages at once... This process may not be appropriate, if you're looking for a few page online presence.
Even with that in mind, the scripts may or may not require changes to suit your specific needs. I can not guarantee that this is gonna make your life easier.
I also will not add features on request! I only add features that I need, the rest is up to you. Open source does not mean that I'm gonna make your wish a reality, it means that it's available for you to use/modify/re-distribuite it according to the license.

The package contains the help page sources initially... You can play with that to se what does what...

Step by step instructions for creating pages, changing theme, and uploading:
0. You need a linux PC to work on... (I recommend ubuntu for simplicity as I know for sure that it contains everything that is necessary by default, requirements are: bash, gedit, and a browser.)
1. Enter the directory in the terminal, and run the Construct.sh script to build the pages...
2. Open the index.html in your browser from the www folder...

V1.1 Features
- Added google verification tag to index page.
- Site map generation for google crawlers. (Don't forget to specify the "YourURL/Sitemap.txt" in the google search console!)
- Added canonical links from light to dark pages.
- Added noindex tag for LatestUpdates.html page.
