"""Create the measured full-unroll variant from the archived compact source."""
from pathlib import Path
import re
import sys

src = Path(sys.argv[1]).read_text()
start = src.index("\tfor j := 0; j < 16; j++ {\n")
end = src.index("\n\t}\n\treturn", start)
body = src[start:end].split("\n", 1)[1]
# Resolve only the constant indices of the dot kernel's sixteen iterations.
blocks = []
for j in range(16):
    step = re.sub(r"j\*([24])(?:\+([123]))?", lambda m: str(j*int(m[1])+int(m[2] or 0)), body)
    blocks.append("\t{\n" + step + "\n\t}")
src = src[:start] + "\n".join(blocks) + src[end+3:]
src = src.replace("[]bool{false, true, true, false}", "[]bool{false, true, true, false, false, true, true, false}")
Path(sys.argv[2]).write_text(src)
