# attempt-1

This was my first attempt at making this website. A couple of issues:
1. I didn't like the final design. At all.
2. Multiple CSS files is generally bad because it'll require multiple requests to load. A better solution would be to have everything in one CSS file, or use something like SASS or LESS to bundle multiple CSS files into one.

This was a bit of a learning experience, though. Some notable insights:
- ::after pseudo element
- first time using animation
- getBoundingClientRect() is the position of the element on the screen, add ScrollX and scrollY to get element’s absolute position on doc
- viewport = client’s screen