# iiiano Manual

iiiano turns a Monome Grid One or Grid Zero into a USB MIDI keyboard. Use it to play notes and to control the scale, root note, velocity, and MIDI channel.

## Contents

1. [Quick start](#quick-start)
2. [Grid layouts](#grid-layouts)
3. [Play the keybed](#play-the-keybed)
4. [Performance controls](#performance-controls)
5. [Keybed controls](#keybed-controls)
6. [MIDI controls](#midi-controls)
7. [Reference](#reference)
8. [Troubleshooting](#troubleshooting)

## Quick start

### Requirements

- A Grid One or Grid Zero in iii mode.
- iii firmware with the v1.1 API. iiiano has been tested with [iii v1.1.2](https://github.com/monome/iii/releases/tag/v1.1.2). Firmware v1.0 and earlier is not supported.
- Python 3.11 and the Python-based [diii](https://github.com/monome/diii). The [README](../README.md#setup) explains how to set up the project environment.

Use the [monome iii documentation](https://monome.org/docs/iii/) to select and install the firmware for your grid.

### Upload and play

1. Connect the grid in iii mode. Activate the project virtual environment and open a terminal in the project directory.
2. Stop the current script and upload iiiano:

   ```bash
   diii do "^^c"
   diii upload src/grid/iiiano.lua
   ```

3. Load the standard library and start iiiano:

   ```bash
   diii do "fs_run_file('lib.lua'); fs_run_file('iiiano.lua')"
   ```

4. Connect a MIDI receiver to the grid's USB MIDI port. Select MIDI channel 1 on the receiver. Press a button in the keybed.

The VS Code default build task (`Ctrl+Shift+B`) runs the stop, upload, and start commands above. Uploading alone saves the script on the grid. It does not start the script. To start iiiano automatically when the grid boots, run `diii do "first('iiiano.lua')"`. This replaces the current startup configuration.

At startup, iiiano uses C major, chromatic mode, the 4ths layout, static velocity 104, and MIDI channel 1. The transpose offset is zero. Note hold is off.

## Grid layouts

Count columns from left to right. Count rows from top to bottom. The diagrams show physical grid positions.

### Grid One: 16 columns × 8 rows

```text
      1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16

 1    G  G  G  G  G  G  G  G  G  G  G  G  P  N  M  ·
 2    G  G  G  G  G  G  G  G  G  G  G  G  C  C  C  C
 3    G  G  G  G  G  G  G  G  G  G  G  G  C  C  C  C
 4    G  G  G  G  G  G  G  G  G  G  G  G  C  C  C  C
 5    G  G  G  G  G  G  G  G  G  G  G  G  C  C  C  C
 6    G  G  G  G  G  G  G  G  G  G  G  G  C  C  C  C
 7    G  G  G  G  G  G  G  G  G  G  G  G  C  C  C  C
 8    G  G  G  G  G  G  G  G  G  G  G  G  C  C  C  C
```

- `G`: playable keybed.
- `P`, `N`, `M`: select the performance, keybed, or MIDI panel.
- `C`: controls for the selected panel.
- `·`: unused.

The keybed has 12 columns. Press `P`, `N`, or `M` in row 1 to change the panel in columns 13–16.

### Grid Zero: 16 columns × 16 rows

```text
      1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16

 1    ·  P  P  P  P  ·  N  N  N  N  ·  M  M  M  M  ·
 2    ·  P  P  P  P  ·  N  N  N  N  ·  M  M  M  M  ·
 3    ·  P  P  P  P  ·  N  N  N  N  ·  M  M  M  M  ·
 4    ·  P  P  P  P  ·  N  N  N  N  ·  M  M  M  M  ·
 5    ·  P  P  P  P  ·  N  N  N  N  ·  M  M  M  M  ·
 6    ·  P  P  P  P  ·  N  N  N  N  ·  M  M  M  M  ·
 7    ·  P  P  P  P  ·  N  N  N  N  ·  M  M  M  M  ·
 8    ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·
 9    G  G  G  G  G  G  G  G  G  G  G  G  G  G  G  G
10    G  G  G  G  G  G  G  G  G  G  G  G  G  G  G  G
11    G  G  G  G  G  G  G  G  G  G  G  G  G  G  G  G
12    G  G  G  G  G  G  G  G  G  G  G  G  G  G  G  G
13    G  G  G  G  G  G  G  G  G  G  G  G  G  G  G  G
14    G  G  G  G  G  G  G  G  G  G  G  G  G  G  G  G
15    G  G  G  G  G  G  G  G  G  G  G  G  G  G  G  G
16    G  G  G  G  G  G  G  G  G  G  G  G  G  G  G  G
```

- `G`: playable keybed.
- `P`: performance panel.
- `N`: keybed panel.
- `M`: MIDI panel.
- `·`: unused gap.

The keybed has 16 columns. All three panels stay visible. Columns 6 and 11 separate the panels. Columns 1 and 16 are empty. Row 8 separates the panels from the keybed.

### How to read the control tables

Each table shows a panel with four columns and seven rows. Read the table from left to right and top to bottom.

| Grid | Panel rows 1–7    | Performance columns | Keybed columns | MIDI columns |
| ---- | ----------------- | ------------------- | -------------- | ------------ |
| One  | Physical rows 2–8 | 13–16               | 13–16          | 13–16        |
| Zero | Physical rows 1–7 | 2–5                 | 7–10           | 12–15        |

On Grid One, select the panel first. On Grid Zero, use its fixed position. A dash in a control table means that the button is unused.

## Play the keybed

Press a keybed button to send a MIDI note. Release it to send a note-off message. Note hold can keep a note sounding after you release the button.

### Read the lights

- A root note is brighter than the other notes in the scale.
- Other notes in the scale are dimmer than the root notes.
- In chromatic mode, notes outside the scale are off. You can still play them.
- A pressed note shows its velocity. Other buttons for the same note class also light up.
- In in-key mode, a button outside the MIDI note range is off and silent.

### Chromatic and in-key modes

Use the **Key / Chromatic** button in the keybed panel to change modes.

- **Chromatic:** each button to the right is one semitone higher. The keybed includes notes outside the selected scale.
- **In-key:** each button to the right plays the next degree of the selected scale. The keybed contains only scale notes.

In in-key mode, change the root or scale while notes are held to retune them. iiiano sends note-off for each changed pitch before it sends the new note-on. It keeps the original velocity and MIDI channel. It does not retrigger a pitch that stays the same. For example, a held E changes to E♭ when C major changes to C minor. A held C stays sounding.

In chromatic mode, a root or scale change does not retune notes that are already held. New notes use the new mapping.

### Row layouts

The row-layout buttons set the interval between a button and the button directly above it.

| Layout | Chromatic mode | In-key mode      |
| ------ | -------------- | ---------------- |
| Octave | 12 semitones   | One scale octave |
| 3rds   | 4 semitones    | 2 scale steps    |
| 4ths   | 5 semitones    | 3 scale steps    |

For example, start at C in C major. The button above it is E in 3rds and F in 4ths. In C minor, the 3rds button above C is E♭ in in-key mode.

iiiano follows the vertical 3rds and 4ths layout described in the [Ableton Push manual](https://www.ableton.com/en/push/manual/#playing-in-other-keys). iiiano also provides its own octave layout.

## Performance controls

Grid One: select the performance panel in row 1, column 13. Use rows 2-8, columns 13-16. Grid Zero: use rows 1-7, columns 2-5.

| Panel row | Column 1        | Column 2      | Column 3         | Column 4         |
| --------- | --------------- | ------------- | ---------------- | ---------------- |
| 1         | Transpose up    | Hold toggle   | Hold momentary   | Hold damper      |
| 2         | Transpose reset | Velocity mode | Minimum velocity | Maximum velocity |
| 3         | Transpose down  | Velocity mode | Minimum velocity | Maximum velocity |
| 4         | 104             | 111           | 119              | 127              |
| 5         | 72              | 80            | 88               | 96               |
| 6         | 41              | 49            | 57               | 65               |
| 7         | 10              | 18            | 26               | 33               |

### Transpose

Press the up or down button to shift the keybed by one octave. The range is two octaves up or down. Press reset to return to the original octave.

### Note hold

- **Toggle:** press once to hold notes. Press again to release held notes.
- **Momentary:** hold the button to hold notes. Release it to release held notes.
- **Damper:** press to turn damper hold on or off. While it is on, press either of the other hold buttons to release held notes.

### Velocity

**Static mode** uses one velocity for each new note. Press a velocity pad to select the value. The selected pad blinks. The two velocity-mode buttons stay at medium brightness.

Press either velocity-mode button to select **random mode**. Both mode buttons blink. Each new note gets a random integer velocity between the minimum and maximum, including both endpoints.

To set an endpoint:

1. Hold either minimum button or either maximum button.
2. Press a velocity pad. For example, press `41` to set that endpoint to 41.
3. Release the endpoint button.

While you hold an endpoint button, both buttons for that endpoint pulse. After you release them, they show the selected value as brightness. The lowest value, 10, is off. The highest value, 127, is at maximum brightness. You can set endpoints in either mode.

If the selected minimum is greater than the maximum, iiiano uses the range between the two values. Switching modes keeps the static value and both random endpoints.

## Keybed controls

Grid One: select the keybed panel in row 1, column 14. Use rows 2-8, columns 13-16. Grid Zero: use rows 1-7, columns 7-10.

| Panel row | Column 1       | Column 2      | Column 3 | Column 4        |
| --------- | -------------- | ------------- | -------- | --------------- |
| 1         | Major          | Dorian        | Phrygian | Lydian          |
| 2         | Mixolydian     | Minor         | Locrian  | Natural minor   |
| 3         | Harmonic minor | Melodic minor | —        | —               |
| 4         | C              | C♯            | D        | D♯              |
| 5         | E              | F             | F♯       | G               |
| 6         | G♯             | A             | A♯       | B               |
| 7         | Octave         | 3rds          | 4ths     | Key / Chromatic |

Press a scale and a root note to set the key. Press a row-layout button to change the interval between rows. Press Key / Chromatic to change the note mapping.

When you hold an assigned control, an abbreviation appears on the keybed. The keybed returns when you release the control. The two unused buttons in row 3 do nothing.

## MIDI controls

Grid One: select the MIDI panel in row 1, column 15. Use rows 2-8, columns 13-16. Grid Zero: use rows 1-7, columns 12-15.

| Panel row | Column 1   | Column 2   | Column 3   | Column 4   |
| --------- | ---------- | ---------- | ---------- | ---------- |
| 1         | Panic      | Panic      | Panic      | Panic      |
| 2         | Panic      | Panic      | Panic      | Panic      |
| 3         | —          | —          | —          | —          |
| 4         | Channel 1  | Channel 2  | Channel 3  | Channel 4  |
| 5         | Channel 5  | Channel 6  | Channel 7  | Channel 8  |
| 6         | Channel 9  | Channel 10 | Channel 11 | Channel 12 |
| 7         | Channel 13 | Channel 14 | Channel 15 | Channel 16 |

Press a channel button to select the USB MIDI output channel. The selected button is brightly lit. Hold the button to show the channel number on the keybed.

Press a panic button to send MIDI All Notes Off (CC 123) on all 16 channels. The panic sprite stays visible while you hold the button.

## Reference

| Item            | Value                                      |
| --------------- | ------------------------------------------ |
| Keybed size     | Grid One: 12 × 8; Grid Zero: 16 × 8        |
| Scales          | 10                                         |
| Velocity pads   | 16 values from 10 to 127                   |
| Random velocity | Any integer between the selected endpoints |
| Transpose       | Up to two octaves in either direction      |
| MIDI output     | Note-on, note-off, and All Notes Off CC    |
| MIDI channels   | 1–16                                       |

## Troubleshooting

### No MIDI output

- Check the USB MIDI connection and the receiver's channel.
- Check that iiiano is running and the grid is in iii mode.
- Check that the firmware supports the iii v1.1 API.

### Unexpected notes or lights

- Check the root, scale, Key / Chromatic mode, and row layout.
- Check the transpose setting.
- In in-key mode, a button outside the MIDI note range is dark and silent.

### Stuck notes

- Press a panic button in the MIDI panel.
- Check the receiver's MIDI connection and channel.
- If necessary, stop and restart iiiano.
