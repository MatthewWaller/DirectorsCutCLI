# Director’s Cut — Beginner tutorial

This guide walks you from **install** through **your first rendered video** using the **Sapling** sample footage.

Director’s Cut is a command-line tool: you point it at a folder of clips, describe the edit you want in plain English, and it produces an MP4 (and optional narration, subtitles, and project files).

---

## What you need

| Requirement | Why |
|-------------|-----|
| **Mac with Apple Silicon** (M1 / M2 / M3 / M4) | The app is built for Apple Silicon. |
| **Homebrew** | Used to install the CLI and FFmpeg. |
| **FFmpeg** | Required for video encoding. |
| **Gemini API key** | Powers footage analysis and edit decisions (free tier is enough to get started). |
| **Internet** | For Gemini (and optional cloud narration). |

Optional: an **ElevenLabs** API key if you want **cloud** AI voiceover. You can also use **local** narration later (`--tts local`) without ElevenLabs.

---

## 1. Install FFmpeg

```bash
brew install ffmpeg
```

---

## 2. Install Director’s Cut

```bash
brew tap MatthewWaller/directorscut
brew install directorscut
```

Confirm the command is available:

```bash
directorscut --help
```

---

## 3. Configure API keys

The easiest way is the interactive wizard:

```bash
directorscut setup
```

It stores settings in `~/.directorscut/.env`.

**Manual option:** create or edit `~/.directorscut/.env` and add at least:

```bash
DIRECTORSCUT_GEMINI_API_KEY=your_gemini_key_here
```

Get a Gemini key: [Google AI Studio — API keys](https://aistudio.google.com/apikey)

For cloud narration with ElevenLabs (optional):

```bash
DIRECTORSCUT_ELEVENLABS_API_KEY=your_elevenlabs_key_here
```

---

## 4. Check that everything works

```bash
directorscut doctor
```

Fix anything it reports (missing FFmpeg, bad API key path, etc.) before the next step.

---

## 5. Prepare the Sapling sample footage

Download the sample raw clips from the GitHub release:

```bash
curl -L -o sapling.zip https://github.com/MatthewWaller/homebrew-directorscut/releases/download/samples/sapling.zip
```

**Unpack it** (pick one):

- In Finder: double-click `sapling.zip` to expand it.
- In Terminal:

  ```bash
  unzip sapling.zip
  ```

You should get a folder named **`sapling`** containing several video files plus `context.txt` and small `.txt` sidecar files. Those text files give the AI background about the app and each clip—you do not need to edit them for this tutorial.

**Tip:** If you see a `__MACOSX` folder after unzipping, you can ignore or delete it. The footage path you pass to Director’s Cut should be the real **`sapling`** folder (the one next to your videos).

Example layout after unzipping:

```
sapling/
  context.txt
  elephant_start.mp4
  elephant_complete_desk_file.mp4
  elephantCompare.mov
  …and matching .txt sidecar files
```

---

## 6. Make your first video

Open Terminal and `cd` to wherever the **`sapling`** folder lives. Below, replace the path with yours if needed.

### Simple first render (recommended)

This creates a short edit from scratch using your prompt and the sample clips:

```bash
directorscut edit \
  -p "Create a 45-second promo for Sapling: show scanning the elephant figurine, the finished 3D model in AR on the desk, and the side-by-side comparison. Energetic but clear; end with the idea that you can scan real objects and use them for 3D printing." \
  -f ./sapling \
  -o sapling_promo.mp4
```

- **`-p`** — What you want (length, tone, story).
- **`-f`** — Folder of source clips (`sapling`).
- **`-o`** — Output filename.

The first run analyzes the clips (this can take a little time). Later runs can reuse a cache for faster iteration (see the main [README](README.md) `analyze` / `--cache` examples).

### Faster low-resolution preview

While you are experimenting with prompts:

```bash
directorscut edit \
  -p "30-second highlight reel of the elephant scan and AR result" \
  -f ./sapling \
  -o sapling_preview.mp4 \
  --preview
```

### Add AI narration and subtitles

If you configured ElevenLabs (or use local TTS per the README):

```bash
directorscut edit \
  -p "1-minute friendly tutorial explaining how Sapling scans a real object and previews it in AR" \
  -f ./sapling \
  -o sapling_narrated.mp4 \
  --generate-narration \
  --subtitles tiktok
```

---

## 7. What you get on disk

Besides **`sapling_promo.mp4`** (or whatever name you passed to `-o`), a typical successful run also creates companion files in the same directory, such as:

- `*_edit_decision.json` — The AI’s edit timeline (you can edit and re-render).
- If you used narration: script, audio, word timestamps, and combined outputs (exact names depend on flags).

See **Output Files** in [README](README.md) for the full pattern.

---

## 8. License and limits

Director’s Cut includes **three free video generations** so you can try it. After that, activate a license with `directorscut activate` (see [README — Licensing](README.md)).

---

## 9. If something goes wrong

1. Run **`directorscut doctor`** again.
2. Confirm **`./sapling`** really contains `.mp4` / `.mov` files (not only the zip).
3. Confirm your **Gemini** key is set and billing/API access matches your Google account.
4. For narration issues, check whether you need **ElevenLabs** or should switch to **`--tts local`** as documented in the README.

---

## Reference: finished example

For a full example of outputs (decision JSON, narration, subtitles), download the walkthrough files from the [samples release](https://github.com/MatthewWaller/homebrew-directorscut/releases/tag/samples).

Your Sapling tutorial run uses **different** source clips but the same overall workflow.

---

Happy editing.
