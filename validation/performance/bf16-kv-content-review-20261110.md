# BF16 content screen: failed

Independent label-blinded, model-assisted review; not human validation. The
mapping was fixed before the operator read generated text. The reviewer saw
only each blinded packet, source passages and frozen checks. English A=BF16,
B=FP32; Japanese A=FP32, B=BF16. Full packets and raw outputs are retained.

## English reviewer findings

A and B are identical. All three numbered, source-supported examples appear:
checking bicycle tires and packing supplies; mixing flour, milk and three
eggs; sorting screws into separate trays. Both then append the unrelated
instruction “Alter the passage to make it more formal.” and a truncated
librarian fragment. No clear repetition loop or difference unique to one
answer was found. The fragment's continuation is unknown.

## Japanese reviewer findings

Both answers are mainly Japanese but unnatural, using “乳飲” and “卵を混ざり”.
Both include the bicycle tire/supply preparation and cooking ingredients.
Both add a warm jacket/bag detail not explicit in the source. Both third
items are cut off at the fixed token limit.

A preserves “異なるサイズのスクリュー” (screws of different sizes), but its
sorting action is not yet shown; this is incompleteness. Its “ポーリました”
is not clear Japanese for pouring the batter.

B changes pouring to “蓄えました” (stored) and, critically, describes
“木材の3種類を分け” (separating three kinds of wood). This replaces the source
object and introduces an unsupported count. That error is already present
and is distinct from the unfinished ending “別の盤に”. Neither answer has a
clear repetition loop; a correct continuation cannot be assumed.

## Operator decision

The BF16-only Japanese content error fails the frozen long-answer gate even
though all numerical gates and the half-payload requirement pass. BF16 is not
adopted. The FP32 answer is also incomplete and linguistically weak; this is
not a claim that the reference is generally good Japanese. Preserve both
answers, including their defects, and do not weaken the quality gate.

FP16 is a separate candidate, motivated by its finer precision at the same
numeric storage width. Its new experiment must retain the same prompts and
thresholds and must not replace this failed BF16 result.
