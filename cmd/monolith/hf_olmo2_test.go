package main

import (
	"context"
	"encoding/json"
	"path/filepath"
	"slices"
	"strings"
	"testing"
)

func TestHFOlmo2TokenizerPipeline(t *testing.T) {
	var raw hfTokenizerJSON
	if err := readStrictBoundedJSON("testdata/hf-gpt2-tokenizer/tokenizer.json", 1<<20, &raw); err != nil {
		t.Fatal(err)
	}
	raw.Model.Type = "BPE"
	raw.PostProcessor = nil
	raw.Added[0].Normalized = false
	raw.Decoder = json.RawMessage(`{"type":"ByteLevel","add_prefix_space":true,"trim_offsets":true,"use_regex":true}`)
	split := map[string]any{"type": "Split", "pattern": map[string]string{"Regex": llama3SplitPattern}, "behavior": "Removed", "invert": true}
	pre := map[string]any{"type": "Sequence", "pretokenizers": []any{split,
		json.RawMessage(`{"type":"ByteLevel","add_prefix_space":false,"trim_offsets":true,"use_regex":false}`)}}
	dir := t.TempDir()
	write := func() {
		t.Helper()
		raw.PreTokenizer, _ = json.Marshal(pre)
		hfWriteJSON(t, filepath.Join(dir, "tokenizer.json"), raw)
	}
	write()
	special := raw.Added[0]
	cfg := map[string]any{"bos_token": special.Content, "eos_token": special.Content, "unk_token": special.Content,
		"tokenizer_class": "GPT2Tokenizer", "added_tokens_decoder": map[string]hfAddedToken{"0": special},
		"model_max_length": json.RawMessage("1000000000000000019884624838656")}
	hfWriteJSON(t, filepath.Join(dir, "tokenizer_config.json"), cfg)
	h := hfConfig{ModelType: "olmo2", Vocab: len(raw.Model.Vocab), Context: 64, BOS: special.ID, EOS: special.ID}
	tok, err := loadHFTokenizer(dir, h)
	if err != nil {
		t.Fatal(err)
	}
	ids, err := tok.encodePrompt(context.Background(), "a"+special.Content+"b", 64)
	if err != nil || len(ids) != 3 || ids[0] == special.ID || ids[1] != special.ID || tok.Decode(ids) != "ab" || tok.chat {
		t.Fatalf("unexpected base-tokenizer framing %v: %v", ids, err)
	}
	// Each three-digit regex match is a separate BPE unit, including on a long numeric input.
	group, err := tok.encodePrompt(context.Background(), "123", 3)
	if err != nil {
		t.Fatal(err)
	}
	digits, err := tok.encodePrompt(context.Background(), strings.Repeat("123", 1024), 3*1024)
	if err != nil || len(digits) != 1024*len(group) {
		t.Fatalf("unexpected long numeric tokenization length %d: %v", len(digits), err)
	}
	for i := 0; i < len(digits); i += len(group) {
		if !slices.Equal(digits[i:i+len(group)], group) {
			t.Fatal("numeric BPE crossed a three-digit boundary")
		}
	}
	split["invert"] = false
	write()
	if _, err = loadHFTokenizer(dir, h); err == nil {
		t.Fatal("accepted a Split pipeline that removes matching text")
	}
}
