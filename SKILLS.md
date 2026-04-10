# Director's Cut — LLM Skills Reference

This document provides structured, machine-readable documentation for Director's Cut, an AI-powered video editing CLI tool. It is designed to be consumed by LLMs and AI coding assistants to help users accomplish video editing tasks.

---

## Tool Overview

**Name:** Director's Cut (CLI: `directorscut`)
**Purpose:** Transform raw video footage into finished, narrated, subtitled videos using natural language prompts.
**Platform:** macOS Apple Silicon (M1/M2/M3/M4)
**License:** 3 free generations, then $29 one-time at https://buy.polar.sh/polar_cl_c3DqnSEinyIb7eELj9SzjxDnRfig6TOzfpc6W48Ks04

---

## Installation

```bash
brew install ffmpeg
brew tap MatthewWaller/directorscut
brew install --cask directorscut
directorscut setup    # interactive API key configuration
directorscut doctor   # verify everything works
```

**Requirements:**
- macOS with Apple Silicon (M1/M2/M3/M4)
- Gemini API key (free): https://aistudio.google.com/apikey
- ElevenLabs API key (optional, for cloud narration): https://elevenlabs.io/app/settings/api-keys

---

## Command Reference

### directorscut edit

Create a video from raw footage and a natural language prompt.

```
directorscut edit -p <PROMPT> -f <FOOTAGE_DIR> -o <OUTPUT_PATH> [OPTIONS]
```

**Required arguments:**
| Argument | Description |
|----------|-------------|
| `-p, --prompt <text>` | Natural language description of the desired video |
| `-f, --footage <dir>` | Directory containing raw video clips |
| `-o, --output <dir>` | Output project directory (video is saved as `<dir>/<name>.mp4` with all derivatives alongside) |

**Optional arguments:**
| Argument | Default | Description |
|----------|---------|-------------|
| `--generate-narration` | off | Generate AI voiceover script and synthesize audio |
| `--narration <path>` | — | Use existing narration audio file instead of generating |
| `-s, --subtitles <style>` | off | Add animated subtitles. Styles: `default`, `bold`, `minimal`, `tiktok` |
| `--aspect-ratio <ratio>` | `16:9` | Output aspect ratio: `16:9`, `9:16`, `1:1`, `4:5` |
| `--preview` | off | Render at 480p for fast iteration |
| `--cache <path>` | — | Path to existing analysis cache SQLite DB |
| `--edit-decision <path>` | — | Path to existing edit decision JSON (skips AI call) |
| `--export-otio <path>` | — | Also export OpenTimelineIO file for NLE import |
| `--tts <provider>` | `elevenlabs` | TTS engine: `elevenlabs` or `local` |
| `-c, --context <text>` | — | Project description to help AI understand footage |
| `--background <mode>` | `blur` | Background fill when aspect ratio doesn't match: `blur`, `black`, `white` |
| `--background-image <path>` | — | Custom background image for aspect-fit framing |
| `--title-card <spec>` | — | Add title card. Format: `"text\|position_index\|duration[\|bg_hex[\|font_size]]"`. Repeatable |
| `--text <spec>` | — | Add text overlay. Format: `"text\|start_time\|duration[\|position[\|font_size]]"`. Positions: `top`, `center`, `bottom`. Repeatable |

**Behavior:**
1. Analyzes all video clips in the footage directory (scene detection, visual description, speech transcription)
2. Caches analysis in SQLite for instant re-use with different prompts
3. Sends analysis + prompt to LLM, which returns structured edit decisions as JSON
4. Renders timeline with MoviePy (transitions, framing, text overlays, title cards)
5. Optionally generates narration (LLM writes script, TTS synthesizes) and burns subtitles

**Output files produced** (inside the project directory):
- `<name>/<name>.mp4` — Rendered video
- `<name>/<name>_edit_decision.json` — AI edit decisions (reusable with `--edit-decision`)
- `<name>/<name>_narration.txt` — Narration script (if `--generate-narration`)
- `<name>/<name>_narration.mp3` — Narration audio (if `--generate-narration`)
- `<name>/<name>_narration.words.json` — Word-level timestamps (if `--generate-narration`)
- `<name>/<name>_narrated.mp4` — Video with narration mixed in (if `--generate-narration`)
- `<name>/<name>_subtitles.ass` — Subtitle file (if `--subtitles`)
- `<name>/<name>_narrated_subtitled.mp4` — Final video with everything (if narration + subtitles)

---

### directorscut analyze

Pre-analyze footage and cache results. Useful when you want to run multiple edits on the same footage without re-analyzing.

```
directorscut analyze <FOOTAGE_DIR> [OPTIONS]
```

| Argument | Description |
|----------|-------------|
| `<footage_dir>` | Directory containing video clips |
| `-o, --output <path>` | Output cache DB path (default: `analysis.db` in footage dir) |
| `-f, --force` | Force re-analysis, ignore existing cache |
| `-c, --context <text>` | Project description to help the model |

**Context:** The AI can only see video frames — provide context for anything it can't infer visually:

- **`context.txt`** — place in the footage directory for project-level context (auto-detected). Example: `"This is footage of a 3D scanning app called Sapling."`
- **Per-clip `.txt` sidecar files** — create `clip_name.mp4.txt` alongside each video with a description of what happens in that clip. Example: `elephant_scan.mp4.txt` containing `"Shows the 3D model alongside the original figurine that was scanned."`
- **`-c` flag** — pass context directly on the command line.

Both project-level and per-clip context are combined during analysis.

---

### directorscut narrate

Add AI-generated voiceover to an existing video.

```
directorscut narrate <VIDEO> -p <PROMPT> [OPTIONS]
```

| Argument | Default | Description |
|----------|---------|-------------|
| `<video>` | — | Path to input video file |
| `-p, --prompt <text>` | required | Creative direction for narration |
| `-o, --output <path>` | `<video>_narrated.mp4` | Output path |
| `--voice <id>` | — | ElevenLabs voice ID |
| `--duck <float>` | `0.3` | Original audio volume during narration (0.0–1.0) |
| `--script <path>` | — | Save narration script to text file |
| `--script-only` | off | Only generate script text, don't synthesize |
| `--audio-only` | off | Generate script + audio, don't mux into video |
| `-s, --subtitles <style>` | off | Add subtitles: `default`, `bold`, `minimal`, `tiktok` |
| `--tts <provider>` | `elevenlabs` | TTS: `elevenlabs` or `local` |

---

### directorscut subtitle

Add animated word-by-word subtitles to a video.

```
directorscut subtitle <VIDEO> [OPTIONS]
```

| Argument | Default | Description |
|----------|---------|-------------|
| `<video>` | — | Path to input video file |
| `-o, --output <path>` | `<video>_subtitled.mp4` | Output path |
| `-t, --timestamps <path>` | — | Word timestamps JSON (skip transcription) |
| `-s, --style <style>` | `tiktok` | Style: `default`, `bold`, `minimal`, `tiktok` |
| `--font-size <int>` | — | Override font size |
| `--words-per-group <int>` | — | Words shown simultaneously |
| `--subs-only` | off | Only generate .ass file, don't burn into video |
| `--tts <provider>` | — | Transcription provider if no timestamps |

**Subtitle styles:**
| Style | Font | Highlight Color | Words/Group | Best For |
|-------|------|----------------|-------------|----------|
| `default` | Arial 24px | Yellow | 4 | General use |
| `bold` | Arial Black 28px | Yellow | 4 | Emphasis |
| `minimal` | Helvetica Neue 20px | Orange | 4 | Clean aesthetic |
| `tiktok` | Arial Black 36px | Orange | 3 | Social media (9:16) |

---

### directorscut share-info

Generate social media metadata (title, description, hashtags) for a video.

```
directorscut share-info <VIDEO> [OPTIONS]
```

| Argument | Description |
|----------|-------------|
| `<video>` | Path to video file |
| `-o, --output <path>` | Output JSON path |
| `-i, --instructions <text>` | Extra instructions for metadata generation |
| `--instructions-file <path>` | Read instructions from file |

---

### directorscut publish

Upload video to YouTube and/or TikTok.

```
directorscut publish <VIDEO> -p <PLATFORM> [OPTIONS]
```

| Argument | Description |
|----------|-------------|
| `<video>` | Path to video file |
| `-p, --platform <name>` | Target platform: `youtube`, `tiktok`. Repeatable |
| `--share-info <path>` | Pre-generated metadata JSON |
| `-t, --title <text>` | Video title |
| `--ai-generated` | Mark as AI-generated content |
| `--schedule <iso-datetime>` | Schedule upload for later |

---

### directorscut setup

Interactive configuration wizard. Prompts for API keys and saves to `~/.directorscut/.env`.

### directorscut doctor

Health check. Validates API connectivity, FFmpeg installation, and TTS availability.

### directorscut inspect

View contents of an analysis cache.

```
directorscut inspect <CACHE_PATH>
```

### directorscut activate

Activate a license key.

```
directorscut activate [LICENSE_KEY]
```

### directorscut check-license

Display current license status and remaining free generations.

### directorscut deactivate-license

Deactivate license on current machine (allows reactivation on another device).

---

## Configuration Reference

Config file location: `~/.directorscut/.env` (global) or `.env` in project directory (local override).

| Variable | Default | Description |
|----------|---------|-------------|
| `DIRECTORSCUT_GEMINI_API_KEY` | — | Google Gemini API key for video analysis and edit decisions |
| `DIRECTORSCUT_ELEVENLABS_API_KEY` | — | ElevenLabs API key for cloud TTS narration |
| `DIRECTORSCUT_TTS_PROVIDER` | `local` | Default TTS engine: `elevenlabs` or `local` |
| `DIRECTORSCUT_DEFAULT_ASPECT_RATIO` | `16:9` | Default output aspect ratio |
| `DIRECTORSCUT_DEFAULT_RESOLUTION` | `1080p` | Default output resolution |
| `DIRECTORSCUT_PREVIEW_RESOLUTION` | `480p` | Preview mode resolution |
| `DIRECTORSCUT_ELEVENLABS_VOICE_ID` | — | Default ElevenLabs voice ID |
| `DIRECTORSCUT_ELEVENLABS_MODEL` | `eleven_multilingual_v2` | ElevenLabs model |
| `DIRECTORSCUT_VOICE_REF` | — | Path to voice cloning reference audio (10–30s) |
| `DIRECTORSCUT_WHISPER_MODEL` | `base` | Whisper model size: `tiny`, `base`, `small`, `medium`, `large-v3` |
| `DIRECTORSCUT_CACHE_DIR` | `.directorscut_cache` | Analysis cache directory |
| `DIRECTORSCUT_LICENSE_KEY` | — | License key from Polar |

---

## Providers

| Provider | Purpose | Config variable |
|----------|---------|-----------------|
| Gemini | Video analysis + edit decision generation | `DIRECTORSCUT_GEMINI_API_KEY` |
| ElevenLabs | Cloud text-to-speech narration | `DIRECTORSCUT_ELEVENLABS_API_KEY` |
| Chatterbox (local) | Local TTS with voice cloning (Apple Silicon) | `DIRECTORSCUT_VOICE_REF` |

---

## Common Workflows

### Workflow: Quick social media clip

```bash
directorscut edit \
  -p "15-second TikTok hook — start with the most impressive moment" \
  -f ./footage/ -o ./clip \
  --aspect-ratio 9:16 --generate-narration -s tiktok
```

### Workflow: Iterate on the same footage

```bash
# Analyze once
directorscut analyze ./footage

# Try different prompts (instant, no re-analysis)
directorscut edit -p "Product demo" -f ./footage -o ./v1 --cache ./footage/analysis.db
directorscut edit -p "Behind the scenes" -f ./footage -o ./v2 --cache ./footage/analysis.db
directorscut edit -p "Tutorial" -f ./footage -o ./v3 --cache ./footage/analysis.db
```

### Workflow: Manual edit decision refinement

```bash
# Generate initial edit
directorscut edit -p "Highlight reel" -f ./footage -o ./v1

# Inspect and manually edit the JSON
cat v1/v1_edit_decision.json   # review AI decisions
# ... edit the JSON to adjust clip selection, timing, etc.

# Re-render from modified JSON (no AI call)
directorscut edit -p "" -f ./footage -o ./v2 --edit-decision v1/v1_edit_decision.json
```

### Workflow: Add narration to existing video

```bash
# Step 1: Generate script only
directorscut narrate video.mp4 -p "Tech reviewer style" --script-only --script script.txt

# Step 2: Review/edit script.txt

# Step 3: Generate full narrated video
directorscut narrate video.mp4 -p "Tech reviewer style"
```

### Workflow: Voice cloning (local, private)

```bash
# Download reference audio (or record your own 10-30 second clip)
mkdir -p ~/.directorscut
curl -L -o ~/.directorscut/referrence_audio.mp3 \
  https://github.com/MatthewWaller/homebrew-directorscut/releases/download/samples/referrence_audio.mp3

# Point config at the reference audio
echo 'DIRECTORSCUT_VOICE_REF=~/.directorscut/referrence_audio.mp3' >> ~/.directorscut/.env

# Generate narration using voice cloning (never leaves your machine)
directorscut narrate video.mp4 -p "Product walkthrough" --tts local
```

### Workflow: Professional NLE handoff

```bash
# Generate rough cut with OTIO export
directorscut edit -p "Interview rough cut" -f ./footage -o ./rough --export-otio timeline.otio

# Open timeline.otio in Premiere Pro, DaVinci Resolve, or Final Cut Pro
```

### Workflow: Context-rich footage setup

```bash
# Set up footage folder with context files
footage/
  context.txt                      # "Footage of a 3D scanning app called Sapling..."
  elephant_scan.mp4
  elephant_scan.mp4.txt            # "Shows 3D model alongside the original figurine"
  robot_panda.mp4
  robot_panda.mp4.txt              # "Image-to-3D robotic panda compared in AR to a toy"
  turntable_demo.mp4
  turntable_demo.mp4.txt           # "Demonstrates the turntable scanning mode"

# Edit — context files are auto-detected, no flags needed
directorscut edit -p "Product demo showing all scanning modes" -f ./footage -o ./demo
```

---

## Edit Decision JSON Format

Edit decisions are saved as JSON alongside every rendered video. The format is:

```json
{
  "clips": [
    {
      "source": "clip_003.mp4",
      "start": 2.5,
      "end": 8.1,
      "transition": "crossfade"
    }
  ],
  "title_cards": [
    {
      "text": "Getting Started",
      "position": 0,
      "duration": 3.0,
      "background": "#1a1a2e",
      "font_size": 64
    }
  ],
  "text_overlays": [
    {
      "text": "Step 1",
      "start": 5.0,
      "duration": 3.0,
      "position": "bottom",
      "font_size": 48
    }
  ],
  "narration": "Here we see the scanning process begin..."
}
```

You can edit any field and re-render with `--edit-decision <path>`.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `FFmpeg not found` | `brew install ffmpeg` |
| `Gemini API error` | Check key at https://aistudio.google.com/apikey, run `directorscut doctor` |
| `ElevenLabs quota exceeded` | Switch to local TTS: `--tts local` |
| `License expired / generations exhausted` | Purchase at https://buy.polar.sh/polar_cl_c3DqnSEinyIb7eELj9SzjxDnRfig6TOzfpc6W48Ks04 |
| `Subtitle text too small/large` | Override with `--font-size` flag on `subtitle` command |
| `Video aspect ratio looks wrong` | Set `--background blur` (default) or try `--background black` |
