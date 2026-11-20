# Iiinst & Siiiq

A collection of instrument and sequencer scripts for monome iii devices.

## Scripts

| Script | Device | Description |
| --- | --- | --- |
| [iiiano](docs/iiiano-manual.md) ([PDF](manuals/iiiano-manual.pdf)) | Grid One and Grid Zero | USB MIDI keyboard with scale, velocity, and note-hold controls |

## Requirements

- Grid One or Grid Zero in iii mode, with iii firmware that supports the v1.1 API. iiiano has been tested with [iii v1.1.2](https://github.com/monome/iii/releases/tag/v1.1.2).
- Python 3.11 and [uv](https://docs.astral.sh/uv/) for the local development environment.
- Busted and LuaCov to run tests with coverage. On Windows, the test task uses the default WSL distribution.

For firmware and device compatibility, see the [monome iii documentation](https://monome.org/docs/iii/).

## Setup

Install Python 3.11 and uv, then run the `Setup Environment` task in VS Code, or run the setup script from the repository root:

```powershell
# Windows
.\scripts\setup-diii.ps1
```

```bash
# macOS or Linux
source scripts/setup-diii.sh
```

On Windows, setup also checks for Busted and LuaCov in the default WSL distribution. On Ubuntu, it installs missing dependencies and may request your sudo password. On other distributions, install both tools for the Lua interpreter used by Busted.

## Upload and run iiiano

Connect the grid in iii mode. In VS Code, run the `Flash iiiano` task or press `Ctrl+Shift+B`. The task stops the running script, uploads iiiano, loads the standard library, and starts iiiano.

To perform these steps in a terminal, activate the project virtual environment and run:

```bash
diii do "^^c"
diii upload src/grid/iiiano.lua
diii do "fs_run_file('lib.lua'); fs_run_file('iiiano.lua')"
```

Uploading alone does not start the script. For controls and optional startup configuration, see the [iiiano manual](docs/iiiano-manual.md).

## Testing

Run the `Test` task in VS Code. On Windows, it runs `scripts/test.sh` through WSL. On macOS or Linux, install Busted and LuaCov, then run the same task.

Busted discovers spec files recursively under `tests/`. LuaCov writes `luacov.report.out` and accumulates statistics in `luacov.stats.out`. Remove the stats file before a run if you want a fresh report.

## Credits

Thanks to Juicy Noise Bits for testing early builds and suggesting features.
