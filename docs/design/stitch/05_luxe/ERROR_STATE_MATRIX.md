# Luxe Error State Matrix

Reference: `luxe-recovery-states.png`.

| State | Player-Facing Recovery |
| --- | --- |
| Drop failed | The Feed missed that drop. Your design is safe. |
| Atelier session failed | The Atelier lost the thread. Your choices are still here. |
| Mint failed | The Atelier lost the thread. Your choices are still here. |
| Offline | Luxe cannot reach the room yet. Try again when the signal returns. |
| Empty feed | The room is quiet. Your next drop can change that. |
| Feature locked | Luxe is holding this door for later. |

Do not surface `FunctionException`, `PostgrestException`, `Supabase`, `RPC`, `null`, `500`, or `401` in player-facing recovery UI.
