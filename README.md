# prefabEditor

Made as an editor for the Nature project in my repository collection.

Tracked separately because it's cleaner.

## Saving/Loading Assets

Place images you want to import into the game engine into the /assets
folder and then start the editor.

The images will be listed and when you select them you will be able to view and manipulate the bounding boxes/physical properties for the assets before
saving them into a 'prefab' pack.  This will contain the images and a lua
script that has all of the corresponding physical properties in a separate file.

The game engine will unpack the prefab pack to a special folder during execution.

(Implementation is not complete yet in this commit).
