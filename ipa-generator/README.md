# beryllium ipa generator

generates standalone .ipa files that wrap a single website into a native ios app using wkwebview.

## requirements

- **macos** (any version that supports xcode 15+)
- **xcode** with command line tools installed
- **python 3.8+**

## usage

### from command line arguments

```bash
# basic usage
python3 generate.py --name "my app" --url "https://example.com" --output MyApp.ipa

# with a custom icon and forced landscape
python3 generate.py \
  --name "game" \
  --url "https://game.io" \
  --icon icon-1024x1024.png \
  --orientation landscape \
  --fullscreen \
  --output Game.ipa

# with stikjit enabled
python3 generate.py \
  --name "emulator" \
  --url "https://emu.site" \
  --stikjit \
  --output Emulator.ipa
```

### from a config file

```bash
python3 generate.py --config site.json --output MyApp.ipa
```

see `example-config.json` for the full config format.

## options

| flag | description |
|---|---|
| `--name` / `-n` | app display name |
| `--url` / `-u` | website url to wrap |
| `--output` / `-o` | output .ipa file path (required) |
| `--config` / `-c` | path to a json config file (alternative to --name/--url) |
| `--bundle-id` | custom bundle identifier (default: auto-generated) |
| `--icon` | path to a 1024x1024 png for the app icon |
| `--orientation` | force `portrait`, `landscape`, or `automatic` (default) |
| `--no-javascript` | disable javascript in the webview |
| `--stikjit` | enable stikjit url scheme support |
| `--fullscreen` | hide status bar for immersive mode |
| `--user-agent` | custom user agent string |
| `--version` | app version string (default: 1.0) |

## how it works

1. generates a minimal swift app that embeds a wkwebview pointed at your url
2. creates a temporary xcode project with the correct build settings
3. copies your custom icon into the asset catalog (if provided)
4. runs `xcodebuild archive` to build for device
5. exports the archive as an .ipa (or falls back to manual packaging)

the generated app is a single-view swiftui app with no dependencies. it supports orientation locking, stikjit url passthrough, custom user agents, and all the same configuration options as the main beryllium app.

## config file format

```json
{
    "name": "my app",
    "url": "https://example.com",
    "bundle_id": "com.beryllium.wrap.my-app",
    "orientation": "automatic",
    "javascript": true,
    "stikjit": false,
    "inline_media": true,
    "fullscreen": false,
    "user_agent": "",
    "icon_path": "/path/to/icon.png",
    "version": "1.0",
    "deployment_target": "16.0"
}
```

only `name` and `url` are required; everything else has sensible defaults.

## signing

the generator uses `CODE_SIGN_STYLE = Automatic` which means xcode will use whatever signing identity is available. for sideloading, you typically need:

- a free apple id (7-day signing) or
- an apple developer account ($99/year)

the resulting .ipa can be installed via:
- altstore / sidestore
- trollstore (if available for your ios version)
- any other sideloading tool that accepts .ipa files
