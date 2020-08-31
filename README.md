# osx-key-remap

Remaps keyboard keys to specific characters.

I found a piece of code using CGEventTapCreate to hook and resend keyboard events. I modified it to remap the keys I needed.

Compile it:

```
clang -fobjc-arc -framework Cocoa  ./remap.m  -o remap
```

Run it (inside screen):

```
sudo ./remap
```
