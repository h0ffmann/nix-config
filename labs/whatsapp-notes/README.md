# whatsapp-notes

WhatsApp voice notes to common audio files and to text, on your own machine. WhatsApp keeps a
voice note as `.opus` (Opus audio in an Ogg container, named like `PTT-20261012-WA0001.opus`),
which many players and editors do not open. This lab gives **ffmpeg** to convert the notes and
**whisper.cpp** to transcribe them offline, behind one script, `wa-notes`.

```
just shell                     # wa-notes, ffmpeg, whisper-cli and just on PATH
just convert chat/             # every .opus/.ogg in chat/ to .mp3 next to it (--to wav|m4a|ogg)
just transcribe chat/          # every note to .txt next to it (--lang pt, --model small, --srt)
just model small               # download a whisper.cpp model into the cache
just self-test                 # the script's --self-test, from source (CI)
just versions                  # every tool's version, built in the Nix sandbox (CI)
just smoke                     # a generated Opus note converted to each format, in the sandbox (CI)
```

`wa-notes` takes files or directories. A directory means every `*.opus` and `*.ogg` in it, so the
media folder of an exported chat works as it is. The output goes next to each note, with the same
name.

## Transcription

whisper.cpp runs on the CPU, so the audio never leaves the machine and nothing needs a key. The
first `transcribe` downloads its model (a ggml file from
[huggingface.co/ggerganov/whisper.cpp](https://huggingface.co/ggerganov/whisper.cpp)) into
`$WA_NOTES_MODELS`, by default `~/.cache/whatsapp-notes`; later runs use the cached file.

| Model | Size | Use |
|---|---|---|
| `tiny`, `base` (default) | 75 MB, 142 MB | fast drafts, clear speech |
| `small` | 466 MB | Portuguese and noisy notes |
| `medium`, `large-v3-turbo` | 1.5 GB, 1.6 GB | best text, slow on a CPU |
| `*.en` (`base.en`, …) | | English only, a little better on English |

`--lang auto` (the default) detects the language of each note. Give `--lang pt` or `--lang en` if
detection picks the wrong one. `--srt` also writes subtitles with timestamps.

The lab uses the CPU build of whisper.cpp. For the GPU, a consumer can use
`pkgs.whisper-cpp.override { cudaSupport = true; }` in its own shell; `wa-notes` calls whichever
`whisper-cli` is first on PATH.

## Other methods, and why not here

- **faster-whisper** and **openai-whisper**: the same models in Python (CTranslate2, PyTorch).
  Faster on a GPU, but a much larger closure and a second model download.
- **Vosk**: smaller and offline, but less accurate, and weaker in Portuguese.
- **Cloud speech APIs**: accurate, but they need a paid key and send the audio away.

## Checks

`checks.wa-notes` runs the script's `--self-test` with fake ffmpeg, whisper-cli and curl.
`checks.smoke` encodes one second of tone as Opus, as WhatsApp does, then converts it to mp3, wav,
m4a and ogg with the real ffmpeg and checks each duration. A real transcription needs a model
download, so the sandbox does not run one.

## Reusing it from another repository

```nix
{
  inputs.whatsapp-notes.url = "github:h0ffmann/picasso?dir=labs/whatsapp-notes";
  outputs = { nixpkgs, whatsapp-notes, ... }: {
    devShells.x86_64-linux.default = whatsapp-notes.devShells.x86_64-linux.default;
    # or, with the project's own tools:
    # devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
    #   packages = [ /* the project's own tools */ ] ++ whatsapp-notes.lib.x86_64-linux.tools;
    # };
  };
}
```

Without a flake: `nix run 'github:h0ffmann/picasso?dir=labs/whatsapp-notes' -- transcribe chat/`.
