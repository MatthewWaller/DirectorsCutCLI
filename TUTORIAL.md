# Director's Cut — Beginner Tutorial

This guide walks you from **install** through **your first rendered video** with AI narration, using the **Sapling** sample footage and **local TTS** (no cloud narration service needed).

Director's Cut is a command-line tool: you point it at a folder of clips, describe the edit you want in plain English, and it produces an MP4 with optional narration, subtitles, and project files.

---

## What you need

| Requirement | Why |
|-------------|-----|
| **Mac with Apple Silicon** (M1 / M2 / M3 / M4) | The app is built for Apple Silicon. |
| **Homebrew** | Used to install the CLI and FFmpeg. |
| **FFmpeg** | Required for video encoding. |
| **Gemini API key** | Powers footage analysis and edit decisions (free tier is enough to get started). |
| **A short audio clip of your voice** | Used by local TTS to clone your voice for narration. |

---

## 1. Download the reference audio

Local TTS uses **Chatterbox** to clone a voice from a short audio sample. We provide a default reference clip you can start with — you can replace it with your own voice later.

```bash
mkdir -p ~/.directorscut
curl -L -o ~/.directorscut/referrence_audio.mp3 \
  https://github.com/MatthewWaller/homebrew-directorscut/releases/download/samples/referrence_audio.mp3
```

> **Want to use your own voice?** Record a **10–30 second** clip of clear speech (reading a paragraph works great), export as `.mp3` or `.wav`, and replace the file above.

---

## 2. Install FFmpeg and Director's Cut

```bash
brew install ffmpeg
brew tap MatthewWaller/directorscut
brew install --cask directorscut
```

Confirm the command is available:

```bash
directorscut --help
```

---

## 3. Run interactive setup

```bash
directorscut setup
```

The wizard walks you through each setting. Here's what to expect:

1. **Gemini API key** — Paste your key. Get one free at [Google AI Studio](https://aistudio.google.com/apikey).
2. **Video provider** — Choose `gemini` (the default).
3. **TTS provider** — Choose `local` for local narration (no cloud API needed).
4. **Voice reference** — Point to your audio file: `~/.directorscut/referrence_audio.mp3`
5. **Whisper model** — `base` is fine for most uses (used for subtitle word timing).

Settings are saved to `~/.directorscut/.env`. You can edit this file directly any time.

---

## 4. Check that everything works

```bash
directorscut doctor
```

Fix anything it reports (missing FFmpeg, bad API key, etc.) before continuing.

---

## 5. Prepare the Sapling sample footage

Download the sample raw clips from the GitHub release:

```bash
curl -L -o sapling.zip https://github.com/MatthewWaller/homebrew-directorscut/releases/download/samples/sapling.zip
unzip sapling.zip
```

You should get a folder named **`sapling`** containing several video files plus `context.txt` and small `.txt` sidecar files. Those text files give the AI background about the app and each clip — you don't need to edit them.

Example layout:

```
sapling/
  context.txt
  elephant_start.mp4
  elephant_complete_desk_file.mp4
  elephantCompare.mov
  ...and matching .txt sidecar files
```

---

## 6. Make your first video

### Quick preview (low resolution, fast)

Start with a preview to test your prompt:

```bash
directorscut edit \
  -p "30-second highlight reel of the elephant scan and AR result" \
  -f ./sapling \
  -o ./sapling_preview \
  --aspect-ratio "9:16" \
  --preview
```

### Full quality edit

```bash
directorscut edit \
  -p "Create a 45-second promo for Sapling: show scanning the elephant figurine, the finished 3D model in AR on the desk, and the side-by-side comparison. Energetic but clear; end with the idea that you can scan real objects and use them for 3D printing." \
  -f ./sapling \
  -o ./sapling_promo \
  --aspect-ratio "9:16" \
  --background black
```

- **`-p`** — What you want (length, tone, story).
- **`-f`** — Folder of source clips.
- **`-o`** — Output project directory (video saved as `sapling_promo/sapling_promo.mp4`).

The first run analyzes the clips (this takes a moment). Later runs can reuse a cache — see the [README](README.md) for `analyze` / `--cache` examples.

---

## 7. Add narration with local TTS

Now narrate the video using your cloned voice:

```bash
directorscut narrate sapling_promo/sapling_promo.mp4 \
  -p "Friendly tutorial explaining how Sapling scans a real object and previews it in AR" \
  -o sapling_promo/sapling_narrated.mp4 \
  --tts local
```

Since you configured local TTS in step 3, Chatterbox uses your reference audio to generate speech that sounds like you. The first run downloads the Chatterbox model (~1 GB) — subsequent runs are fast.

---

## 8. Burn in subtitles

Add TikTok-style animated subtitles to the narrated video:

```bash
directorscut subtitle sapling_promo/sapling_narrated.mp4 \
  -o sapling_promo/sapling_final.mp4 \
  --style tiktok
```

Or do narration + subtitles in one shot during edit:

```bash
directorscut edit \
  -p "45-second Sapling promo" \
  -f ./sapling \
  -o ./sapling_full \
  --generate-narration \
  --subtitles tiktok \
  --tts local \
  --aspect-ratio "9:16"
```

---

## 9. What you get on disk

Inside your project directory (e.g. `sapling_promo/`):

- `sapling_promo.mp4` — The rendered video.
- `*_edit_decision.json` — The AI's edit timeline (you can edit and re-render).
- Narration files (if used): script, audio, word timestamps.

See **Output Files** in the [README](README.md) for the full pattern.

---

## 10. License and limits

Director's Cut includes **three free video generations** so you can try it. After that, activate a one-time payment license with `directorscut activate` (see [README — Licensing](README.md)).

---

## Troubleshooting

1. Run **`directorscut doctor`** again.
2. Confirm **`./sapling`** really contains `.mp4` / `.mov` files (not only the zip).
3. Confirm your **Gemini** key is set and billing/API access matches your Google account.
4. If narration sounds wrong, try a clearer reference audio clip (less background noise, 10–30 seconds of speech).
5. If local TTS model download fails, check your internet connection and try again — the model is cached after the first download.

---

Happy editing.
