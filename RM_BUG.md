How to get this bug:

```
Assertion failed: (!NIL_P(exc)), function push_current_exception, file vm.cpp, line 3987.
```

```
bundle 
rake clean:all
rake pod:install
rake
```

Enter `104090` when asked for a "jeweler number" and hit Save.

Wait for the Database to download from the web and hit the "+" button.

Enter a name of someone.

Change the "Show Total" to 500

Go to the "FREE" tab and tap about 5 rows.

Go to the genie tab and tap the "best deal" button at the bottom

Immediately cancel.

Go to the FREE tab and tap a new row to add it.

Go to the genie tab and hit the button & cancel immediately again.

Tap the row on the genie screen that corresponds with the item you just added to remove it.

Tap the best deal button again.

Crash.
