# Local development — foundation

Current entry point (G0.5): Import `game/project.godot`, then F5 opens the four-plot
art study. See `G0_5_TEST_GUIDE.md` for desktop/mobile, controls, captures and UI Kit.
Earlier scene instructions below are historical; G0.3/G0.4 still run with F6 on
their respective scenes. This is a session-only prototype, not production gameplay.

Use Godot **4.7.2 stable**, standard build (GDScript; no .NET). This exact installed version was validated. Runtime has no addons or third-party dependencies. Python 3.12+ is used only for repository checks. Asset audit additionally requires Pillow 12.3.0 and system `tar` with RAR support (Windows tar works here).

From the repository root (`D:\Projetos\ColheitaFelizProMax\colheita` on the audited machine):

```powershell
$godot = 'C:\Users\guilh\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:\Users\guilh\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
./tools/check.ps1 -Godot $godot -Python $python
```

On other machines install Python and Godot, then use `./tools/check.ps1 -Godot 'path/to/godot' -Python python`. CI uses the same script, a pinned stable engine and Python 3.12. It does not download asset packs or require Pillow. Backend checks are deferred because there is no backend implementation in these gates.

To open manually: start Godot project manager, choose **Import**, select `game/project.godot`, choose **Edit**, then **F5** for the G0.3 comparison menu. The earlier bootstrap remains available with **F6** on `scenes/boot/boot.tscn`. Debugger must show zero script errors. No gameplay is implemented. See `G0_3_TEST_GUIDE.md` for both visual proposals, exact portrait/desktop commands, controls and captures; creative approval is pending.

Config is optional: copy `game/config/local.example.cfg` to `game/config/local.cfg`. No configuration or connection is needed to boot. The only setting is the environment label. Never put credentials in client configuration. Services are composed in `autoload/app.gd`; only the content boundary exists. Add auth/network/economy services at their authorized gates, behind `scripts/services` and `scripts/api`, with no fake client authority.

GDScript uses tabs, snake_case functions/files, PascalCase scene nodes, explicit boundary types, composition and small scene scripts. Presentation stays in scenes/UI; domain logic stays out of scene scripts. Strings use `tr()`. Use versioned schemas and stable content IDs when content arrives. `.editorconfig` records whitespace conventions. No gameplay values or backend setup were added.

Regenerate the asset audit only after obtaining the three named archives lawfully and placing them in the root:

```powershell
& $python -m pip install -r tools/requirements-audit.txt
& $python tools/audit_assets.py
& $python tools/check_repository.py
Start-Process (Resolve-Path '.local/asset_audit/index.html')
```

The audit fully decodes and hashes every graphic, inventories every source file, parses effect atlas rectangles, and generates deterministic review materials. The HTML opens locally, with links to full source sheets and paginated category sheets. It requires no server. Sheets and extractions must stay private. `.local/` is outside the Godot resource root and ignored by Git. Do not copy it to `game/assets/` or commit it. A clean clone runs without any extracted art. Missing categories are documented in the report, not filled with invented assets.

Windows sandbox runs may report editor settings write failures under APPDATA. Run the checks in an ordinary terminal with your user permissions. Do not disable Godot safe-save globally to bypass a sandbox. The final checks were run with normal filesystem permissions.
