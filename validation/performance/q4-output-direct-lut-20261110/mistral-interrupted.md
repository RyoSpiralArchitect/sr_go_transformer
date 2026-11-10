# Interrupted first real-model comparison

Candidate eaff99b055489657aa01bf73ca17851adf61ed2c was committed before
validation. Local formatting, full Go race, vet, Python, isolated probe,
CGO-free build and CLI smoke checks finished in the first worktree.

The first real comparison used the frozen Mistral protocol. The observed
progress log contained the following entries before the working directory
became unavailable.

```text
0 before complete; signature matches
1 after complete; signature matches
2 after complete; signature matches
```

The fourth process had started, with 3-before.log present. No complete
receipt or timing medians were read. The tool then could not start in
the worktree because the parent _wt directory was absent. The original
comparison job exited 1. The location and cause of the disappearance are
unknown. The search did not locate the original raw files. Preserve this
interrupted attempt in the decision record. The new checkout runs the
same commit and protocol in a separate directory, without relaxing gates.

The same source was restored and its frozen hashes matched. The restart
failed before any probe execution because the pinned Mistral directory,
including config.json, was absent. The configured HF cache contained no
copy of this pinned revision. No Mistral result is available for a speed
decision. The separate Llama 3.2 3B comparison uses existing cached assets.
