# beryllium

turn websites into apps on your homescreen.

## what it does

beryllium wraps any website into a native ios/ipados container using wkwebview. unlike safari shortcuts, your sites run inside a dedicated app with their own navigation controls and configuration.

## features

- **website container** - wkwebview-based wrapper, not just a safari redirect
- **custom icons** - pick from photo library, auto-fetch favicons, or use a color+letter fallback
- **orientation lock** - force portrait, landscape, or let it rotate automatically
- **stikjit support** - toggle stikjit integration for sites that need jit compilation
- **full screen mode** - hide status bar and controls for an immersive experience
- **inline media** - configure inline video/audio playback per site
- **custom user agent** - spoof the user agent string for sites that need it
- **javascript toggle** - disable javascript for lightweight/reader views
- **home screen shortcuts** - add sites to your home screen via the beryllium:// url scheme
- **deep linking** - open any configured site directly with `beryllium://open?id=<uuid>`
- **ipa generator** - build standalone .ipa files for individual sites (requires macos + xcode)

## requirements

- ios 16.0+ / ipados 16.0+
- xcode 15.0+
- swift 5.9+

## building

### locally (requires a mac)

the xcode project is generated from `project.yml` using [xcodegen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen
xcodegen generate
open Beryllium.xcodeproj
```

1. run `xcodegen generate` to create the `.xcodeproj`
2. open `Beryllium.xcodeproj` in xcode
3. select your development team under signing & capabilities
4. build and run on your device or simulator

### without a mac (github actions)

you don't need a mac at all — github actions builds the ipa for you in the cloud:

**build the main beryllium app:**

1. go to the **actions** tab in your github repo
2. select **build beryllium ipa**
3. click **run workflow** (optionally pick debug/release)
4. when it finishes, download the ipa from the **artifacts** section

**build a single-site wrapper ipa:**

1. go to **actions** > **build site wrapper ipa**
2. click **run workflow**
3. fill in the site name, url, and options (orientation, stikjit, etc.)
4. download the generated ipa from artifacts

the ipas are unsigned but work with sideloading tools like altstore, sidestore, trollstore, or any signing service.

the main app ipa is also auto-built on every push to `main` and attached to github releases when you push a version tag (e.g. `v1.0`).

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

## ipa generator

the `ipa-generator/` folder contains a python script that builds standalone .ipa files wrapping a single website. this runs on macos and requires xcode.

```bash
cd ipa-generator
python3 generate.py --name "my app" --url "https://example.com" --icon icon.png --output MyApp.ipa
```

see [ipa-generator/README.md](ipa-generator/README.md) for full documentation.

## project structure

```
project.yml                             # xcodegen spec (generates .xcodeproj)
Beryllium/                              # ios/ipados app
├── BerylliumApp.swift                  # app entry point
├── Info.plist                          # app configuration and url scheme registration
├── Assets.xcassets/                    # app icon and colors
├── Models/
│   ├── WebSite.swift                   # site configuration model (with icon support)
│   └── SiteStore.swift                 # persistence layer + favicon fetching
├── Views/
│   ├── ContentView.swift               # main site list + icon rendering
│   ├── SiteEditorView.swift            # add/edit form with photo picker
│   └── WebContainerView.swift          # wkwebview wrapper
└── Managers/
    ├── OrientationLockModifier.swift   # orientation forcing
    ├── ShortcutManager.swift           # home screen shortcut generation
    └── URLSchemeHandler.swift          # deep link handling

ipa-generator/                          # macos command-line tool
├── generate.py                         # ipa build script
├── example-config.json                 # sample site config
└── README.md                           # generator documentation

.github/workflows/                      # ci/cd pipelines
├── build-ipa.yml                       # builds main app ipa (auto + manual)
└── build-site-ipa.yml                  # builds single-site wrapper ipa (manual)
```
