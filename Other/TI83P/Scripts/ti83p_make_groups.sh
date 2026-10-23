#!/bin/bash
# TI-83 Plus core: gathers the files of a game into a single .8xg group file
#
# Run it from the MiSTer menu: Scripts > ti83p_make_groups
#
# For each sub-folder of games/TI83P (for example games/TI83P/MyGame/), the
# script creates games/TI83P/MyGame.8xg with every TI-83 Plus file of the
# folder (.8xp .8xg .8xv .8xl .8xm .8xn .8xs .8xi .8xy .8xd .8xw .8xz .8xt
# .8xc, sub-folders included). A group that is already up to date is kept.
# Then, in the core: Load TI file > MyGame.8xg (sends the whole game).
#
# Skipped: .8xk (applications), .8xu (operating systems), .8xb (backups).
# 64 KB at most per group (send buffer of the core).

DIR="${TI83P_DIR:-/media/fat/games/TI83P}"

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 was not found on this MiSTer."
    exit 1
fi
if [ ! -d "$DIR" ]; then
    echo "Folder not found: $DIR"
    exit 1
fi

python3 - "$DIR" <<'PYEOF'
import os, struct, sys

top = sys.argv[1]
EXTS = {'.8xp', '.8xg', '.8xv', '.8xl', '.8xm', '.8xn', '.8xs', '.8xi',
        '.8xy', '.8xd', '.8xw', '.8xz', '.8xt', '.8xc'}
SKIP = {'.8xk': 'application', '.8xu': 'operating system', '.8xb': 'backup'}
MAX_SIZE = 65536


def entries(path):
    d = open(path, 'rb').read()
    if d[:8] != b'**TI83F*' or len(d) < 0x37:
        raise ValueError("not a TI-83 Plus file")
    n = struct.unpack_from('<H', d, 0x35)[0]
    p, end = 0x37, 0x37 + n
    if end > len(d):
        raise ValueError("truncated file")
    out = []
    while p < end:
        hl = struct.unpack_from('<H', d, p)[0]
        if hl not in (0x0B, 0x0D):
            raise ValueError("unexpected entry header")
        size = struct.unpack_from('<H', d, p + 2)[0]
        total = 2 + hl + 2 + size
        if p + total > end:
            raise ValueError("truncated entry")
        out.append(d[p:p + total])
        p += total
    return out


def group(folder):
    ents, files, newest = [], 0, 0.0
    for base, dirs, names in os.walk(folder):
        dirs.sort()
        for name in sorted(names):
            ext = os.path.splitext(name)[1].lower()
            path = os.path.join(base, name)
            if ext in SKIP:
                print("   skipped: %s (%s)" % (name, SKIP[ext]))
            elif ext in EXTS:
                try:
                    ents += entries(path)
                    files += 1
                    newest = max(newest, os.path.getmtime(path))
                except ValueError as err:
                    print("   skipped: %s (%s)" % (name, err))
    return ents, files, newest


made = 0
for name in sorted(os.listdir(top)):
    folder = os.path.join(top, name)
    if not os.path.isdir(folder) or name.startswith('.'):
        continue
    out = os.path.join(top, name + '.8xg')
    ents, files, newest = group(folder)
    if not ents:
        continue
    if os.path.exists(out) and os.path.getmtime(out) >= newest:
        print("%s.8xg: already up to date" % name)
        continue
    body = b''.join(ents)
    comment = ('Group of %d files, TI-83 Plus MiSTer core' % files).encode('ascii')[:42].ljust(42, b'\0')
    data = b'**TI83F*\x1a\x0a\x00' + comment + struct.pack('<H', len(body)) + body
    data += struct.pack('<H', sum(body) & 0xFFFF)
    if len(data) > MAX_SIZE:
        print("%s: too big (%d bytes, 64 KB at most): split the game into two folders" % (name, len(data)))
        continue
    with open(out, 'wb') as f:
        f.write(data)
    made += 1
    print("%s.8xg: %d variables, %d files, %d bytes" % (name, len(ents), files, len(data)))

print()
print("%d group(s) created in %s" % (made, top))
PYEOF

sync
