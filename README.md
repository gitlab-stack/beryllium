# beryllium

turn websites into apps on your homescreen.

## what it does

beryllium wraps any website into a native ios/ipados container using wkwebview. unlike safari shortcuts, your sites run inside a dedicated app with their own navigation controls and configuration.

## features

- **website container** - wkwebview-based wrapper, not just a safari redirect
- **orientation lock** - force portrait, landscape, or let it rotate automatically
- **stikjit support** - toggle stikjit integration for sites that need jit compilation
- **full screen mode** - hide status bar and controls for an immersive experience
- **inline media** - configure inline video/audio playback per site
- **custom user agent** - spoof the user agent string for sites that need it
- **javascript toggle** - disable javascript for lightweight/reader views
- **home screen shortcuts** - add sites to your home screen via the beryllium:// url scheme
- **deep linking** - open any configured site directly with `beryllium://open?id=<uuid>`

## requirements

- ios 16.0+ / ipados 16.0+
- xcode 15.0+
- swift 5.9+

## building

1. open `Beryllium.xcodeproj` in xcode
2. select your development team under signing & capabilities
3. build and run on your device or simulator

## usage

1. tap **+** to add a new website
2. enter the site name and url
3. configure orientation, javascript, stikjit, and other options
4. tap **save** — the site appears in your list
5. tap any site to open it in the web container
6. triple-tap inside the container to toggle the navigation bar
7. use the share/shortcut feature to add sites to your home screen

## url scheme

beryllium registers the `beryllium://` url scheme. you can open any saved site directly:

```
beryllium://open?id=<site-uuid>
```

this is used by the home screen shortcut generator to launch sites without going through the main app list.

## project structure

```
Beryllium/
├── BerylliumApp.swift          # app entry point
├── Info.plist                  # app configuration and url scheme registration
├── Assets.xcassets/            # app icon and colors
├── Models/
│   ├── WebSite.swift           # site configuration model
│   └── SiteStore.swift         # persistence layer
├── Views/
│   ├── ContentView.swift       # main site list
│   ├── SiteEditorView.swift    # add/edit site form
│   └── WebContainerView.swift  # wkwebview wrapper
└── Managers/
    ├── OrientationLockModifier.swift  # orientation forcing
    ├── ShortcutManager.swift          # home screen shortcut generation
    └── URLSchemeHandler.swift         # deep link handling
```
