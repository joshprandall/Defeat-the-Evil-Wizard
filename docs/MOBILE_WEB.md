# Mobile controls and browser build

The landscape touch overlay appears during gameplay on touchscreen devices. It is hidden on desktop computers without a touchscreen, on the title screen, while the game is paused, and during dialogue/cutscenes. Desktop keyboard and gamepad controls remain available.

- Left thumb: analog movement, pull down to crouch.
- Right thumb: round fist for light attack, up arrow for jump, sword for heavy attack, chevrons for dash/slide, E to interact, 1 and 2 for class abilities, U for ultimate, pause in the top-right.
- Multiple touches can be held simultaneously, so moving while jumping and attacking is supported.
- Turn the phone sideways for gameplay. The overlay shows a rotation prompt in portrait orientation.
- Movement Lab also has touch controls; its top-right control returns to the main menu.

The buttons feed the existing Godot Input Map actions. Mouse-from-touch emulation is temporarily disabled while the gameplay overlay is active, to prevent joystick touches from firing mouse attacks; it is restored for menu interaction. The current version uses the game's existing aim logic; advanced touch aiming, device-specific layout tuning, and real-device performance still require playtesting.

## Build from a phone

GitHub Actions runs the `Godot Web build` workflow on pushes and pull requests. It downloads and verifies the official Godot 4.7.2 Linux binary and export templates, imports the project, exports a non-threaded Web build, checks its `.html`, `.js`, `.wasm`, and `.pck` files, and uploads a downloadable `evil-wizard-web-<commit>` artifact retained for 14 days.

Open this repository's **Actions → Godot Web build → latest run → Artifacts** to download the browser build after the run succeeds. A build artifact is **not** a deployment. Nothing in this workflow changes the OSU-hosted portfolio, learning platform, or existing live game; deploying an approved build to OSU is a separate step.
