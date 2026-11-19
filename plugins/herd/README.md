# Herd — hc terminals and agents in a Tern block

A Tern plugin that shows herdr-core's terminals (`hc ls --json --all`) in a block, so
a herd run (a lead agent and its builders in git worktrees) can be watched and
steered from Tern without typing `hc` commands.

Requires **Tern 0.9.12 or later** and herdr-core **0.1.18 or later**. Linux and Windows are
tested; macOS is untested.

```
Herd   herdr-core                     [Scope… u] [Activity v] 5 [Show finished h] [Mute toasts m] [Refresh r]

Worktrees        Turns
9                108
                 most 104 (t1n)

 All   Needs you 1   Working   Done
Terminal              Agent    Status          Turn  Worktree │ ┌ b1-cart  t3n          [Watch ⏎] ┐
t1n                   hermes   ● done            104 shop     │ Status working · for 14m │
├─ b1-cart  t3n       codex    ● working 14m       1 cart     │ Agent     codex          │
├─ b2-checkout t3p    codex    ● blocked  2m       2 checkout │ Model     gpt-6-astra    │
└─ gate-cart t4a      sh       –                   0 cart     │ Worktree  ~/code/shop/…  │
                                                             │ [Attach a] [Logs l] [Send… s] │
                                                             │ [Worktree w] [Focus subtree f] │
                                                             │               [Interrupt… x] │
                                                             └───────────────────────────┘
↑↓ select  home/end jump  enter watch  1–4 tab filter
```

## The page

The block opens in Tern's sans face and follows Tern's page layout (Designing
Views):

- **Head row**: the title, `herdr-core` and the current run label, with
  **Scope…** (`u`), **Activity** (`v`, with an unread badge),
  **Show finished** (`h`), **Mute toasts** (`m`) and **Refresh** (`r`)
  controls. Run scopes switch in place; All terminals is the unfiltered
  scope. Show finished only controls row visibility; Mute toasts turns
  toasts off, not history recording. Subtree focus appears as `focus
  <terminal>`. When `hc ls` fails after a list has loaded, the meta says
  `stale, 40s old` in the warning tone and the last list stays on screen.
- **Stats** (up to four tiles): facts about the run that the tabs don't already
  count, directly on the page without a card. **Machines** appears only with
  remote machines (warning tone and "N unreachable" when hc can't reach
  some). **Worktrees** is the number of distinct working directories.
  **Turns** sums hc's turn counters, naming the busiest terminal when there is
  one. **Finished** appears only when some are hidden (or, with `h` on,
  listed). The status counts live in the filter tabs instead: Tern's
  `StatItem` is only `label`, `value`, `sub`, `tone` and `title`, and a
  stats strip's actions fire for the whole strip, so a tile can't be a
  clickable filter with a selected state; tabs can.
- **Machines hc can't reach** each get a warning card with hc's reason and how
  long ago it went away.
- **Filter tabs**: All, Needs you (blocked, error), Working, Done (done,
  idle, finished). `1`–`4` or Tab/⇧Tab switch them.
- **The table**, full width, parents before their children with `├─ └─ │`
  connectors. Within a filter the tree is built from what the filter shows:
  a terminal whose parent is filtered out becomes a root.
  - Terminal: name and address (a nameless terminal shows its address). A
    named terminal on one of hc's remote machines always leads with its
    machine (`build-box/` then the name, and the local address after it
    when that fits), so the machine stays visible when the address is
    dropped for width.
  - Agent: Tern's own icon for programs it ships one for (`app-codex`,
    `app-hermes`, `app-omp`, `app-claude`, `pi-mark`, shells as `terminal`, …),
    otherwise just the name.
  - Status: a dot in the status tone, the word, and how long it has said it.
    working = accent, blocked = warning (bold), error = error (bold), done =
    success, idle and finished = muted (the same tones in the status-line
    segment; accent keeps working visibly apart from done's green). A finished
    terminal shows its exit code. Plain programs report no status and show
    `–`. The time is only shown
    once this block has *seen* the status change: a terminal seen for the
    first time (after opening the block or a reload) has no time, rather than a
    wrong one. Rows are never tinted.
  - Turn, right-aligned with its header (`align = "end"`, which Tern draws
    in tabular figures) in the mono face.
  - Worktree: the last segment of the working directory; the full absolute
    path is the row/cell tooltip. The card shows the whole directory with
    home abbreviated to `~`, on one line when it fits the card's value
    column and otherwise with the distinctive leaf on its own line.
  - Where: hc's `where`, only when the shown rows don't all say the same
    (a uniform value stays in the card and takes no room in the table).
- **The selected terminal's card**: beside the table in a wide pane, above it
  in a narrow one; the only card on the page. Head: the name, address and agent
  icon, with the one primary action, **Watch** (Enter). Facts: status and how
  long it has said it, the blocked kind, what the program says, agent (and the
  foreground program when it differs), model only when the command line names
  one, turn, started (relative), exit code / signal / reason once finished,
  parent, children only when there are some, full worktree path, where, and
  the `run` label. Until the first `hc get`
  full worktree path, where, and the `run` label. Until the first `hc get`
  answers, the facts start with a shimmering fetching message
  (`Fetching details from build-box…`,
  without the machine for a local one) and the facts that need it read
  `fetching…`; after a failure they say what is missing and hc's error shows
  under them. Its buttons come in fixed
  groups: **Attach**, **Logs**, **Send…** (what reaches the terminal), then
  **Worktree** and **Focus subtree** (where to look; the latter is disabled
  when the terminal has no children), then applicable read-only viewer
  controls: tiled shows **Float Watch** / **Park Watch**, floating shows
  **Dock Watch** / **Park Watch**, absent or parked shows none. Only matching
  local **Report**, **Review** and **Brief** artifact buttons appear, then
  **Interrupt…** alone at the end of its own row. Other inapplicable buttons
  are disabled with a reason. Hidden viewer controls do not disable their keys:
  an inapplicable key action reports a notice in the dock.
- **Logs card**: `l` reads the last 40 lines once (`hc read <t> --lines 40`)
  into a card under the view, in a box half the pane tall that opens at the
  newest line and scrolls up. `l` again reads again; nothing polls it.
- **Activity inbox**: `v` replaces the terminal view with the newest observed
  transitions for the current run scope. Its rows contain timestamps,
  terminal names/addresses, statuses and exit codes, never terminal output.
  Opening does not mark read; **Mark read**, **Clear…** and **Back** are
  explicit controls. Clear… asks in place before removing the scope's
  activity. Unread rows carry an `unread` badge; read rows do not.
- **Dock**: a one-line notice (sent, interrupted, refused, left the list),
  the refresh problem while a stale list shows, and a compact navigation
  legend: ↑↓ select, Home/End jump, 1–4/Tab filter and `[`/`]`
  previous/next needs-you. Head controls reveal their keycaps on hover or
  keyboard focus; detail buttons keep theirs. Hidden
  viewer buttons do not remove the `p`/`d`/`z` shortcuts documented below.

### Width

The block measures each column's widest cell (headers included) on every
render, in one pass over the shown rows, and picks what fits instead of
letting the table hide columns on its own:

- Terminal, Status and Worktree always show. A worktree name longer than 24
  characters is cut in the middle; the full path is the tooltip and is in the
  card. Tree connectors take two cells per level. A name longer than 36 cells
  (less its connectors, never under 12) and a `where` longer than 24 are cut
  with "…" and shown whole in the cell's tooltip, so one long value can't
  push the other columns out.
- Then, while they fit: Turn, Agent, Where (only when the rows' `where`
  differ), then the address after each name (also in the card's head).
  What doesn't fit is still in the card (the table's priorities follow the
  same order, so if Tern runs short it drops Where, then Agent, then Turn).
- The card sits beside the table (40–48ch) only when the table keeps
  Terminal, Status, Worktree, Turn and Agent next to it; otherwise it goes
  above the table at full width.
- The head always keeps its action labels. Native flex wraps the actions
  below the title (and the buttons themselves if needed) at the actual
  available width; it does not use `cx.cols` to decide whether they fit.
  The stats strip compresses into four equal-width tiles on one row, with
  ellipsized sub-lines and full tile tooltips rather than an accidental
  three-plus-one wrap. The strip and first tile align with the title gutter.
  The keyboard legend is shorter in compact layouts.
- The card's Worktree line estimates its value column from the card's width
  (48 cells beside the table, the pane less its padding on a narrow pane) less the
  card's insets, the key column and the gap, and breaks before the leaf only
  when the full `~` path is longer than that.
- Height comes from the window's actual layout, not a `cx.rows` budget.
  A small scoped stylesheet (`herd.css`) gives the page's native flex column
  the region's real bounds. The head, stats, machine cards, tabs, selected
  card, optional logs and dock take their natural measured sizes; the table
  receives the remaining height, capped only at its full content height.
  Its header plus 4 rows is a minimum, not the normal allocation. If even
  that minimum cannot fit, the page itself scrolls instead of losing the
  card. Overflowing tables have a persistent scrollbar at the right edge.
  The ordered tree and all connectors are built
  before clipping; scrolling never turns an intermediate sibling into the
  last sibling. Selection stays in view. `cx.rows` counts terminal cells,
  not the sans line units used by view extents.

### States

- Loading (first list on its way): skeleton tiles and rows.
- Error with nothing loaded: an error card in the view's place with hc's own
  message (`{error: {kind, message, hint}}`), the first 200 bytes of anything
  that isn't JSON, and Retry. No `hc` at all: the card says where it looked.
- Empty: no live terminals → an inline empty state (with **Show finished**
  when hc hides some); a filter with no match → the table's empty line.

## Install

```sh
tern plugin link ~/code/tern-herd/plugins/herd   # use it in place
tern plugin list                                 # herd … ready
```

`tern plugin unlink herd` removes it. After editing the files, `tern plugin
reload herd`.

Open it with the palette command **Open herd console** (`plugin.herd.open`),
or **Ctrl+Alt+Shift+H** (⌘⌥⇧H on macOS). The command focuses (or unparks) a
Herd block in the current session, or opens one beside the focused pane.
The focused console wins; otherwise it reuses the most recently focused/used,
then the lowest pane id. The reused console keeps its saved run scope.

While a Herd block is open, the status line shows `herd N working`
(`· M blocked`, `· K error`, `· U unread`): error tone with errors, else
warning with blocked terminals, else info while something works. Unread
activity keeps it visible even when no terminal is active; clicking it
focuses the block.

## Keys

| Key | Does |
| --- | --- |
| ↑ ↓ / k j, Home End / g G, PgUp PgDn | move the selection |
| ] / [ | select next / previous blocked or errored terminal in the current run scope |
| 1 2 3 4, Tab ⇧Tab | filter: All, Needs you, Working, Done |
| u | choose All terminals or a remembered/typed run label without reopening |
| Enter / o (or double-click a row) | focus the existing read-only Watch viewer, or open `hc attach --observe --history 200 <t>`; agent terminals get a tab of their own (`Watch <address>`) so a full-screen TUI keeps its width, plain terminals split to the right; unpark it if hidden. Nothing you type reaches the agent and the terminal isn't resized |
| a | attach: always open a new writable `hc attach <t>` split, to type into it |
| p | float the selected terminal's read-only Watch viewer as a peek/PiP; open one if absent; already floating or parked gives a dock notice |
| d | dock the selected terminal's floating Watch viewer; absent, already tiled or parked gives a dock notice |
| z | park the selected terminal's existing Watch viewer without stopping its program; absent or already parked gives a dock notice |
| l | logs: `hc read <t> --lines 40` once into a card; `l` again re-reads |
| s | send: asks for a prompt, asks again to confirm, then runs `hc send <t> <text>` (never `--force`) |
| x | interrupt: asks to confirm, then runs `hc interrupt <t>`. Refused for done, idle and finished terminals, and checked again after you confirm |
| w | worktree: opens a git block on the terminal's working directory (`cx.git:open`, beside). Local terminals only |
| f | focus subtree: show only the selected terminal and its descendants; `f` again clears it |
| h | show or hide finished terminal rows; observation always includes them |
| v | toggle Activity; opening it does not mark read |
| m | mute or unmute toasts |
| r | refresh now |
| Esc | close Activity, then the logs card, then clear the focus |

Only `s` and `x` change terminals, and both ask first. `ctrl+\` detaches from an
attach split (hc's key); closing the split also only detaches, the terminal
keeps running.

The filter, focus, finished and mute settings and the selected terminal are
saved, so a reload or restart keeps them.

### Watch viewers

Watch reuses only viewers created by Herd with the same window, source Tern
host/session, resolved `hc` executable, terminal address and read-only mode.
Agent terminals open their viewer in a new tab named `Watch <address>`; the
full-width tab keeps a full-screen TUI from reflowing the newest frame. Plain
terminals keep the split to the right.
It never guesses from a title or changing foreground command, and never reuses
a writable Attach for Watch. **Float Watch**, **Dock Watch** and **Park Watch**
also target only that registered read-only viewer. Card controls reflect its
native layout: tiled → Float/Park; floating → Dock/Park; absent or parked →
none. The `p`, `d` and `z` keys remain active and report inapplicable actions in
the dock; `p` alone may create an absent read-only viewer. Dock/park never create
one, and a parked viewer requires Watch to unpark it.
Closing a viewer removes its registry entry; the next Watch creates a new one.
The bounded registry survives plugin reloads (up to 64 records); stale, exited,
native or moved-to-another-host/session panes are pruned. Unknown or ambiguous
ownership is refused, not guessed. Layout controls only affect Tern's disposable
view: no stop, send or interrupt reaches the hc terminal.

One window replica is the authoritative viewer-state reporter for a console.
Other replicas cannot erase its controls with an unrelated empty registry or
replace its viewer notices. Native layout changes update that reporter's state
on the existing window ticks/lifecycle events. Its renewable three-second lease
is checked by normal host polling; if the reporter disappears, ownership and
controls expire and another capable replica can claim. Reload may briefly
hide controls while the new reporter reestablishes the actual native state.

### Local artifacts

The selected terminal's card opens **Report**, **Review** and **Brief** in
Tern's native document view beside the console, never through a system opener.
Defaults are `.scratch/report.md`, `.scratch/review-*.md` and
`.scratch/brief.md`, relative to hc's working directory. Review chooses the
greatest actual filesystem modification time (including nanoseconds), not the
greatest filename; equal mtimes use a deterministic lexical path tie-break.
Missing files have no buttons; partial matches show only existing artifacts,
retaining each configured spec's original action index. Remote selections have
no artifact buttons. Herd never creates reports, briefs or review files.

Choose **Configure Herd artifacts** (`plugin.herd.artifacts`) in the palette.
It presents the saved JSON array directly, without opening, focusing or
unparking a console. For example:

```json
[
  {"label":"Report","path":".scratch/report.md"},
  {"label":"Review","path":".scratch/review-*.md"},
  {"label":"Brief","path":".scratch/brief.md"}
]
```

An empty array `[]` disables links. Specs are global to this local Tern plugin
and saved in its `artifact_specs` KV entry, surviving reloads. Saving refreshes
all live selected scans; a closed console stays closed. Up to eight entries
are allowed; labels have 1–32 characters, paths 1–256, without controls.
Paths must be relative and cannot contain `..`, drive prefixes or backslashes.
At most one `*` is supported, in the basename only; `?`, bracket and brace
globs are not supported. Invalid input leaves the previous specs unchanged.
No absolute cwd, discovered path or file contents are persisted.

Discovery waits 200 ms after selection settles and refreshes at most every
30 seconds via normal polling. Only the selected terminal is scanned, with
one discovery process in flight per console; changing selection/scope/config
invalidates older callbacks, queues only the latest selection and immediately
removes old links. Rendering launches no process. Before even inspecting a
directory, the single-owner mailbox requires a window to identify this Herd
source as belonging to its local Tern host. Remote hc addresses are refused
before that check; remote/unknown Tern hosts are refused before any filesystem
scan. Native opening rechecks selection, scope, source, saved specs and current
local host, so changing preferences cannot retarget an already queued open.

The scanner supports **Linux (GNU find `-printf`)** and **Windows (`tern.fs`
pre-check with PowerShell `LastWriteTimeUtc`)**; macOS/BSD find is
unsupported and macOS remains untested. It uses argv, never a shell command,
follows no nested symlink or reparse-point directories, and prunes unrelated subdirectories.
Each scan has a bounded timeout, at most 256 candidates and 64 KiB of
output; exceeding a bound, missing scanner tools or malformed output disables the
result with an honest error rather than picking a possibly stale “newest”
file. No artifact file contents are loaded until you explicitly open a matching
document.

### Next / previous needs-you

From any tab, choose **Next Herd terminal that needs you**
(`plugin.herd.next_needs`) or **Previous Herd terminal that needs you**
(`plugin.herd.previous_needs`) in the palette. Their global shortcuts are
**Ctrl+Alt+Shift+J** / **Ctrl+Alt+Shift+Y** (⌘⌥⇧J / ⌘⌥⇧Y on macOS,
untested). Inside the console, press `]` / `[`.

Navigation focuses, unparks or opens the current session's console and only
selects a terminal. It never opens a watch/attach split, sends text or interrupts.
It walks blocked/error rows in the full scoped parent–child tree order,
relative to the selected address, wrapping in either direction. A sole target
can select itself. Once a target is found it clears subtree focus and switches
to **Needs you**, so the target cannot remain hidden by the previous view.
A successful navigation also closes Activity so the selected target is visible.
No eligible target leaves the view unchanged and displays a notice.

Only the console's existing list is used: no discovery request or extra `hc ls`
poll is made. The normal selected-card detail debounce remains unchanged.
While the initial list is missing, one pending direction (the latest requested)
waits for the next successful normal list refresh; a scope switch cancels it.
The opening command's initial intent is consumed once; restoring the block does
not replay it.
A failed or overdue list may still be navigated, but the notice calls those
results cached and possibly out of date. A console opened after all observers
closed must wait for its first list, not invent a fresh queue.

Parked consoles are reused only when their session ownership is known from
this window's observations, or there is only one session. After a window-half
reload with multiple sessions, an unidentifiable parked console is left alone
rather than taking a console from another session. Focus/ownership bookkeeping
is bounded to 32 consoles and pruned when panes or sessions disappear.


### Run scopes

Press **u**, click **Scope…**, or choose **Choose run scope**
(`plugin.herd.scope`) from any tab. If there is no console, the command opens
one before presenting the picker; restoring that console later does not reopen
the picker. Choose **All terminals**, one of the 12 recent run labels, or
**Custom label…**. Opening the picker makes one
`hc --json` request: unlike the reduced `hc ls --json` projection, the bare
JSON command retains `Terminal.labels`, so available run labels can be discovered
without per-row `get` polling. Installed hc **0.1.18** was verified to return
`{commands, hidden_finished, machines, terminals}`, with full terminal records,
object/null status and labels objects. The inspected live and retained finished
records contained **no `labels.run`**, so this confirms the discovery source,
not an observed live run-label result. Fictional fixtures exercise actual
run-label discovery and scoped rows. At most 12 distinct labels join the recent
list; cached selected-terminal labels are remembered too. Discovery is not a
complete inventory: finished/removed runs and unreachable machines can be absent.
If discovery fails, remembered and typed labels work.
The current scope appears in the head and status segment.

The block saves its scope; `run=<id>` is only the initial default. Scope
switching clears list/detail caches, logs, subtree focus and pending mailbox
requests. A confirmation already open keeps its original address and scope
generation; confirming after a switch is refused rather than retargeted.
Recent labels are capped at 12 and saved pane scopes at 32. Scope summary
metadata belongs to its pane, so another console cannot overwrite its counts.
An open Activity inbox stays open when the scope changes, immediately switching
to that scope's cached history and unread count; its previous scope's events do
not leak into the new view.


## Activity inbox

Press **v** or click **Activity** in the head. This is **observed history, not a
complete audit**: it covers successful snapshots returned while at least one
console is open and polling, not every change between polls or during closed,
unreachable or unobserved periods. The first snapshot is a baseline, not a burst
of news; old finished terminals seen for the first time never become new events.
Existing baselines survive reloads, so a later snapshot can reveal a changed
state, but cannot reconstruct intervening transitions or their actual times.
Timestamps are when the console observed the change, in local time.

The newest 100 events are shared by all consoles on this Tern host. The head
badge, tab title and status segment show the current scope's unread count.
Rows show only timestamp, name/address, status, optional exit code and read
state. Opening or closing the inbox does not mark anything read. **Mark read**
marks the retained events in this scope; **Clear…** asks in place, then removes
them but keeps transition baselines, so the next identical poll does not recreate them.
Both changes propagate to every live console. An event's read/removal state is
shared across All terminals and any run scopes that include it.
**Back**, **v** or **Esc** returns to the terminal view without discarding its
filter, selection or logs. Terminal-steering keys do not act on an invisible
selection while Activity is open.

Run membership is learned only from scoped observations and run labels already
available in cached selected-terminal details. All terminals includes every
retained event; a run includes only events associated with that known label.
An All observation can therefore appear before its run membership is known.
This is not a complete run audit, and changing labels does not reconstruct
past membership.

Storage contains only bounded event metadata, read state and transition
baselines: no cwd, prompts, output, command arguments or logs. Retention is
capped at 100 events, 512 terminal baselines and 12 run associations per
terminal/event. Once baseline retention fills, unknown addresses are
conservatively baselined instead of treating possibly evicted old rows as
fresh unread activity; existing retained addresses still record transitions.
Unread events can age out with retention. History read/save failures are shown;
an unreadable store is not overwritten with an empty one. Muting toasts does
not mute history or unread badges.

## Toasts

The shared activity ledger records these observed transitions, and toasts each
new event once across all consoles:

- a terminal turns **blocked** (info toast) or **error** (error toast), or
  first appears in one of them;
- **working → done** (success) and **working → idle** (info);
- **finished** (success for exit 0, else error).

Repeated snapshots, overlapping run scopes and multiple consoles do not repeat
the same event/toast. An alive, relevant, unmuted console delivers it; a muted
first observer does not swallow another console's notification. `m` mutes only
that console's toasts. Turning `h` on or off does not rebaseline observations
or make an extra list request.

Tern's toast levels are `success`, `info` and `error` only (`ToastLevel` in
`tern.d.luau`); there is no warning toast, so blocked is an info toast while
the table and status segment show it in the warning tone.

The host always asks for `--all`, so a live → finished transition is recorded
and can toast even when `h` is off and the terminal was not selected. A row
that is simply absent is not assumed finished: removal, remote failures or
changes between polls may be invisible. No selected-disappearance `hc get`
probe is needed. See [Activity inbox](#activity-inbox) for retention and
observation limits.

## How it works

- `host.luau` (runs in the Tern daemon) defines the block `herd.herd`, polls
  `hc ls --json --all` (`--label run=<id>` for a run scope) every 2 s with
  one `tern.timer` per live block and
  `tern.process.run` (10 s timeout), and runs `hc get`, `hc read`, `hc send`
  and `hc interrupt`. It finds `hc` by name, then at `%LOCALAPPDATA%\Programs\herdr-core\hc.exe` on Windows, `$HOME/.local/bin/hc`,
  `/usr/local/bin/hc` and `/usr/bin/hc` (a daemon started by a launcher may
  have a short PATH).
- An `hc ls` answer identical to the last one is not parsed again. Parsing,
  the tree and the view are linear in the number of terminals.
- Status ages: the host keeps, per address, the last status and when it
  changed (`since`); a new address has no `since`. This lives only in the
  block, so a reload starts again without times.
- `activity.luau` is a host-only singleton shared by all consoles. Full
  observations reach it before finished-row presentation filtering. Request
  start times discard older overlapping observations; only newly added events
  drive toasts. Read/clear/observation changes resync every alive console's
  scoped history and unread cache, then render its root metadata. Rendering does not
  access the history store or execute commands.
- The card's `hc get <address> --json` runs only for the selected terminal:
  200 ms after the selection stops moving, and then at most once every 10 s
  while it stays selected (each poll asks; a cached answer younger than 10 s
  wins). Answers are cached per address and dropped when the terminal leaves
  the list. Rendering never starts a process.
- A host block can't split panes, open dialogs or open a git block; only the
  window half can. It queues a request in inert main-region metadata.
  `window.luau` reads only that root (`cx.session:surface`, depth 0, one node)
  and asks the serial host worker to claim a request. The host grants it to
  the first claimant; only that window acknowledges and executes the split,
  prompt, picker or git open. Other replicas, including clients without the
  window plugin, do nothing. No internal action uses a URL or system opener.
  Unlike a file-local kv queue, surface metadata also reaches remote replicas;
  unlike kv get/set, the host's claim arbitration is not a read/write race.
- Action discovery reads only the root (no descendants or table cells):
  10 Hz while a Herd pane has the window's current focus or this consumer is
  waiting on a request it might handle; otherwise idle at 2 Hz.
  It stops when no Herd block exists in the current session. Focus/lifecycle
  events cancel the old timer and read immediately, so returning to the
  console does not wait for a background tick. Tern exposes no surface-update
  event; the tiny steady-state read discovers requests without a URL effect.
  Focus is read from `cx.session:focused()`, not the remembered per-tab pane
  flag. Focused consumers claim immediately; others defer at least 200 ms.
  An unfocused consumer discovers idle requests on a 500 ms tick, then polls
  every 100 ms through the preference delay and claim/grant handshake until
  that request leaves the list. The idle rate stays at 2 Hz.
  The API does not expose which window originated a host key or row event,
  so focus is a preference, not a guarantee about the originating replica.
- Acknowledgements clear requests. Uncompleted requests expire after 5 s
  with a dock notice, so a missing consumer or a window closing mid-request
  does not wedge the queue. Requests are not saved across block restarts;
  a fresh window VM identity cannot replay its predecessor's grant. A
  confirmed send or interrupt still returns through `cx.session:event`,
  and the host rechecks it against the latest list before running `hc`.
- The status segment reads the chosen Herd pane's scope-specific root summary
  on a 3-second timer. Counts are ephemeral root metadata, not persisted
  per-pane keys; another scope never supplies the chosen console's counts.
- A pane id survives a block restart or plugin reload: the host keeps one
  state object per pane, retires the old one in `init` (cancelling its poll
  and debounce timers), and every timer or process callback checks it is still
  the live run before touching it.

## Limits

- **Local only.** The host half runs `hc` on the machine whose daemon runs the
  block. Viewing a remote Tern host runs that machine's `hc`, if it has one.
  hc's own remote machines (`hc machine`) appear as rows (`machine/t7`) when
  hc lists them, and unreachable ones as warning cards. `w` refuses remote
  terminals: `cx.git` reads local repositories only, and is desktop-only.
- Window-only actions need at least one desktop replica with Herd's window
  half installed and the console's session open. A web client runs no Lua:
  without a capable replica, actions expire with a notice rather than
  launching a browser. With multiple capable replicas, one executes each
  action; a crash between acknowledgement and execution can lose that action,
  but it is never replayed automatically. Try it again explicitly.
- Activity/finished history is bounded and only includes observed snapshots;
  see [Activity inbox](#activity-inbox), not a claim of complete terminal audit.
- `tern plugin list` reports the host half only: a syntax error in
  `window.luau` shows up as a log warning (`plugin window entry failed to
  load`) and a missing palette command.

## Testing headless

From the repository root, use the isolated fixture harness:

```sh
./test/shoot.sh demo
./test/shoot.sh --size 472x1240 demo
./test/shoot.sh --keys "2" demo
./test/shoot.sh --keys "sleep:2100" transitions
./test/shoot.sh --keys "dblclick:.sf-tbl-row.sel" activation
./test/actions.sh
```

Screenshots are written to `test/shots/`. See [the test harness README](../../test/README.md)
for fixtures, interaction keys, and isolation guarantees.

The harness copies the plugin into a temporary environment, pins its fake
`hc` as the first executable candidate, and asserts that the plugin's
`hc_path` kv value resolves to that fake before sending any keys. It also
isolates `TERN_CONFIG_DIR`, `XDG_STATE_HOME`, `XDG_DATA_HOME`,
`XDG_CACHE_HOME`, and `TERN_DAEMON_SOCKET`, and uses a unique control socket.
This keeps `tern.kv` writes out of the live plugin-data directory and makes
watch/attach/send/interrupt tests use fixture terminals rather than the live
herd.

Do not substitute a hand-written `tern serve` recipe that isolates only
`TERN_CONFIG_DIR`: kv writes can still reach the live state directory.
With the real `hc`, watch/attach splits reach the live herd even when the
Tern window is headless.