"""Convert extracted Mac 'snd ' resources to WAV: uv run python sounds.py"""
import sys, wave, json, glob
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent / 'drxtract'))
from drxtract.snd import snd_to_sampled
ROOT = Path(__file__).resolve().parent.parent
ok = fail = 0
for f in sorted((ROOT / 'assets').glob('*/snd/*.snd')):
    try:
        s = snd_to_sampled(f.read_bytes())
        out = f.with_suffix('.wav')
        w = wave.open(str(out), 'w')
        w.setnchannels(s.num_channels); w.setsampwidth(s.bits_per_sample // 8); w.setframerate(s.sample_rate)
        w.writeframesraw(s.samples); w.writeframes(b''); w.close()
        ok += 1
    except Exception as e:
        fail += 1
        print('FAIL', f, e)
# update manifests to point at wavs
for mf in (ROOT / 'assets').glob('*/manifest.json'):
    m = json.load(open(mf)); changed = False
    for e in m['members']:
        if e.get('file', '').endswith('.snd') and (mf.parent / e['file']).with_suffix('.wav').exists():
            e['file'] = e['file'][:-4] + '.wav'; changed = True
    if changed: mf.write_text(json.dumps(m, indent=1))
print('ok', ok, 'fail', fail)
