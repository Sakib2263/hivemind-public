"""say.py FOLDER [--lang hi]  - Chatterbox voice clone, one WAV per line.

FOLDER/voice.wav  10-30 s of clean speech from the voice to copy (your own, or someone who agreed in writing)
FOLDER/lines.txt  one sentence per line
Writes FOLDER/vo/001.wav, 002.wav ... Lines already voiced are skipped (delete a file to redo it).
--lang: English by default. Other codes use the multilingual model (hi, ar, es, fr, de, ...; no Bangla yet).
"""
import os, sys

def main(a):
    if not a or a[0] in ("-h", "--help"):
        print(__doc__); return 0
    d, lang = a[0].strip('"'), (a[a.index("--lang") + 1] if "--lang" in a else "en")
    ref, txt = os.path.join(d, "voice.wav"), os.path.join(d, "lines.txt")
    for p in (ref, txt):
        if not os.path.isfile(p):
            print("missing", p); return 1
    lines = [l.strip() for l in open(txt, encoding="utf-8") if l.strip()]
    out = os.path.join(d, "vo"); os.makedirs(out, exist_ok=True)
    import torch, torchaudio
    dev = "cuda" if torch.cuda.is_available() else "cpu"
    if lang == "en":
        from chatterbox.tts import ChatterboxTTS
        m = ChatterboxTTS.from_pretrained(device=dev); gen = lambda t: m.generate(t, audio_prompt_path=ref)
    else:
        from chatterbox.mtl_tts import ChatterboxMultilingualTTS
        m = ChatterboxMultilingualTTS.from_pretrained(device=dev)
        gen = lambda t: m.generate(t, language_id=lang, audio_prompt_path=ref)
    for i, t in enumerate(lines, 1):
        p = os.path.join(out, "%03d.wav" % i)
        if os.path.exists(p):
            continue
        torchaudio.save(p, gen(t), m.sr); print("%s  %s" % (os.path.basename(p), t[:60]))
    print("done: %d lines in %s (device %s)" % (len(lines), out, dev)); return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
