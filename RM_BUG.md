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

Change the "Show Total" to 500.

Go to the "FREE" tab and tap about 5 rows so that there's a (1) next to them.

Go to the genie tab and tap the "best deal" button at the bottom.

Immediately cancel.

Do this 2 more times.

Crash.
