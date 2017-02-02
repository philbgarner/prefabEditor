# prefabEditor

Made as an editor for the Nature project in my repository collection.

Tracked separately because it's cleaner.

## Installation

The .love file should execute as-is, however it is dependent upon the dear imgui library binaries.

On Linux, the imgui.so file must be in the .love archive, in the same folder as the archive is executing in, or in one of the folders specified in the environment path variables.

On Windows, the appropriate .dll file must be in the .love archive, in the same folder or in environment variable paths.

There are 32 and 64 bit versions of the binaries, the 64 bit version is included with the .love archive.

If you get errors upon execution, please try a different dll or build them yourself from scratch and (re)place the dll in the .love archive.

See this lua dear imgui bindings project for details:
https://github.com/slages/love-imgui

## Saving/Loading Assets

Place images you want to import into the game engine into the /assets
folder and then start the editor.

The images will be listed and when you select them you will be able to view and manipulate the bounding boxes/physical properties for the assets before
saving them into a 'prefab' pack.  This will contain the images and a lua
script that has all of the corresponding physical properties in a separate file.

The game engine will unpack the prefab pack to a special folder during execution.

(Implementation is not complete yet in this commit).
