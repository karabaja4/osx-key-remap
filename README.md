# osx-key-remap

So I'm a creature of habit, and for me there's nothing more annoying than learning new keyboard shortcuts.

Coming from Windows/Linux, learning OSX keyboard shortcuts was a nightmare (Alt-Shift-Š on a Croatian keyboard to write a { was just ridiculous). Karabiner was one of the solutions, but it's configuration was a horrible. Also it never worked quite right and with OSX Sierra updates, Karabiner-Elements didn't have all the features I needed.

So I found a piece of code using CGEventTapCreate to hook and resend keyboard events. I modified it to remap the keys I needed.

I might make this more user friendly in the future, so all the remap key values are not hardcoded.

Compile it:

```
clang -fobjc-arc -framework Cocoa  ./remap.m  -o remap
```

Run it (inside screen):

```
sudo ./remap
```
