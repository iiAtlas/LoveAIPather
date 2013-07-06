LoveAIPather
============

A Lua/Love2D randomly generated "maze" with an AI to solve it.  The AI attempts to run from his starting place on the left side of the map to the right side, but he will terminate pathing if he (accidentally) finds another way out.  Upon completion the map will change to show the AI's path.  The colors of each tile represents how many times the AI visited a square.  Green = 1, Blue = 2, Red = 3, White = 4+.  Once the AI reaches it's goal (other side/any other escape route) the map will switch to show the AI's path, simply press "R" to start again.  This AI is not the fastest, most efficiant, or most compact possible, but it is mine and I like it :)  This project was an experiment and I recomend you treat it as such.  Feel free to poke around the code and use anything you find useful, but I don't recomend my pathing methods for much more than experimenting.  For something more efficiant/powerful check out A* or write your own!

Controls
--------

D - Change draw mode (show map or path)
R - Regenerate map/restart
S - Change AI path speed

Build
------

Building must be done with Love2D.  Simply open the folder with the Love2D, drag the folder to the Love2D application, or use a command line solution.

