# Setup (Windows, one-time)

## 1. Download the repo with GitHub Desktop
1. Install GitHub Desktop: https://desktop.github.com and sign in.
2. **File → Clone repository** → pick `roboy2911/roblox-game1` → **Clone**.
3. Remember the folder it saved to (usually `Documents\GitHub\roblox-game1`).

## 2. Install Rokit (it installs Rojo for you)
1. Go to https://github.com/rojo-rbx/rokit/releases/latest
2. Download the file ending in **`windows-x86_64.zip`**, unzip it, and double-click **`rokit.exe`**.
   It installs itself. If Windows warns you, click **More info → Run anyway**.

## 3. Install Rojo and the Studio plugin
1. In GitHub Desktop: **Repository → Open in Command Prompt** (opens a terminal in the project folder).
2. Run these one at a time:
   ```
   rokit install
   rojo plugin install
   ```
   If `rokit install` asks whether to trust `rojo-rbx/rojo`, say **yes**.
   If it says `rokit` is not recognized, close the terminal and open it again.

## 4. Connect Studio
1. In the same terminal run:
   ```
   rojo serve
   ```
   **Leave this window open** while you work.
2. Open Roblox Studio → new **Baseplate**.
3. **Plugins** tab → **Rojo** → **Connect**.
4. Press **Play**. The **Output** window (View → Output) should show:
   `Pawn Shop Simulator v0.0.1 – Pawn Shop loaded!`
5. Save the place (**File → Save to Roblox**) so your map is kept.

## Every time after that
1. GitHub Desktop → **Fetch origin** → **Pull origin** to get the newest code.
2. Terminal: `rojo serve` (if it isn't already running).
3. Studio → Rojo → **Connect** → Play.

## Importing 3D models (later steps)
Models are in the `models/` folder. In Studio: **File → Import 3D** → pick the `.fbx` file.
