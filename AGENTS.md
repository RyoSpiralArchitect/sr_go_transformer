# Project verification

- Keep the production runtime monolithic in `cmd/monolith/monolith.go`.
- Use `scripts/go.sh` or the pinned local `.tools/go/bin/go` when Go is not on PATH.
- Clean-checkout CI runs formatting, `go test -race -count=1 ./...`, `go vet ./...`, `python3 -S -m unittest discover -s scripts -p '*_test.py'`, `python3 -S scripts/check_probe_builds.py`, a CGO-disabled build and `scripts/smoke.sh`.
- Local ignored `runs/` can contain historical Go scratch sources. Verify `./cmd/... ./tools/...` explicitly in such a dirty development checkout; do not delete historical files to make `./...` pass. CI checks the clean tracked tree.
- Large raw run directories under `runs/` and model weights are not committed; compact receipts/probes under `validation/performance/` may be tracked. Preserve all samples, including failed stability screens. Separate allocation reductions from elapsed-time claims.
- Q8 cached invocation reuse is an archived candidate, not a production change. Its adoption requires separate stable default-runtime confirmation and FP32/Q4/prefill/lifecycle/race/compatibility checks.
- Reconstruct the historical Furnace CPU bundle with `python3 scripts/prepare_q8_furnace_bundle.py --output runs/NEW_DIRECTORY --go .tools/go/bin/go`. The output parent must exist; historical binary reproduction requires Go 1.27.3. Model assets must be supplied separately. This command only prepares local artifacts, not remote execution.
- Furnace execution uses the existing `spiral` command. Inspect contention first, operate only on owned isolated artifacts/processes, and never change host policies or unrelated jobs to obtain benchmark stability.

- Grouped Q/K/V and Gate/Up dispatch is an archived, unadopted candidate. Retain both first comparisons and require a fresh frozen performance confirmation plus compatibility checks before adoption; see `docs/grouped-projection-experiment.md`.
