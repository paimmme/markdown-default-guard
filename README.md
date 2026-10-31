# Markdown Default Guard for macOS

Keep `.md` and `.markdown` files associated with the app you choose after an app install or update.

This project uses the public Launch Services API and a per-user `launchd` agent. It does not modify another app's `Info.plist`, disable code signing, or edit Launch Services database files. The guard is corrective: a periodic check may briefly follow a change before restoring the selected app.

## One-command install

The default target is Google Chrome:

```sh
./install.sh com.google.Chrome
```

For Obsidian, Visual Studio Code, or another app, pass its bundle identifier:

```sh
./install.sh md.obsidian
./install.sh com.microsoft.VSCode
```

The installer compiles the small helper, sets both common Markdown UTIs, verifies the result, and loads a per-user LaunchAgent. It does not require `sudo`.

Check or repair manually:

```sh
~/Library/Application\ Support/md-default-guard/fix-md-default.sh --check
```

Remove the guard:

```sh
./uninstall.sh
```

## Why two UTIs?

macOS may resolve `.md` as `com.unknown.md` on a particular machine, while apps commonly declare `net.daringfireball.markdown`. The helper sets both and reads them back after writing.

Apple documents explicit Launch Services bindings as the first preference when selecting an app, but that does not promise that every installer or future macOS release will never rewrite the association. The LaunchAgent is therefore a recovery mechanism, not a permanent lock.

## Caveats

The agent checks at login and every 30 minutes. `WatchPaths` is included for faster recovery when the WorkBuddy bundle changes, but filesystem watches can miss events, so the interval check remains the reliable fallback. Change `TARGET_BUNDLE_ID` in the installed config by rerunning `install.sh` with the desired bundle ID.

## References

- [Apple: Choose an app to open a file on Mac](https://support.apple.com/en-ie/guide/mac-help/mh35597/27/mac/27)
- [Apple: Launch Services Concepts](https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/LaunchServicesConcepts/LSCConcepts/LSCConcepts.html)
- [launchd.plist(5), WatchPaths caveat](https://manp.gs/mac/5/launchd.plist)

## License

MIT
