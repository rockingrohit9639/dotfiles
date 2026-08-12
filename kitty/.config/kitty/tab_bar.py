"""Custom kitty tab bar, three-zone layout.

    jcode/frozen Wolf [self-dev]      ▌|||||||  2      ● Recording · 9 sessions · 91%
    └── active tab title ──┘          └── ticks ──┘    └────── status ──────┘

Rather than a chip per tab, each tab is a single tick mark: the active one is a
solid block, the rest are thin bars, and the active tab's index sits beside the
group. This keeps the bar readable with many tabs open, where titled chips would
eat the whole width.

Everything drawn here is positioned absolutely. kitty erases the tab bar line
before the drawing pass, so absolute placement is safe.
"""

import re
import subprocess
import threading
from datetime import datetime

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    color_as_int,
)

# Chalk theme colours, kept in sync with current-theme.conf by hand.
FG = 0xD2D8D9
GREY = 0x7C8A8F
DIM = 0x555B5D
TEAL = 0x44A799
YELLOW = 0xB9AB4A
GREEN = 0x789A69
RED = 0xB23A51

SEP = " · "
TICK_ACTIVE = "▌"
TICK_INACTIVE = "│"
TICK_CELLS = 2  # tick glyph + trailing space

ICON_BATTERY = "\U000f0079"  # 󰁹
ICON_CHARGING = "\U000f0084"  # 󰂄
ICON_CLOCK = "\U000f0954"  # 󰥔

TICK_SECONDS = 2.0
BATTERY_EVERY_N_TICKS = 30  # ~60s

_timer_id = None
_ticks_elapsed = 0
_battery = {"pct": None, "ac": False}
_battery_lock = threading.Lock()

# Filled during the layout pass, consumed during the drawing pass. kitty walks
# every tab in a measuring pass before it draws anything, which is the only way
# to know the total tab count while drawing the very first tab.
_layout_tabs: list = []
_tab_count = 0
_active_index = 0


# --- battery -----------------------------------------------------------------
# pmset is a subprocess, so it runs on a worker thread. Blocking the main thread
# inside draw_tab would make the whole terminal feel sluggish.


def _refresh_battery() -> None:
    try:
        out = subprocess.run(
            ["pmset", "-g", "batt"], capture_output=True, text=True, timeout=5
        ).stdout
    except Exception:
        return
    m = re.search(r"(\d+)%", out)
    with _battery_lock:
        _battery["pct"] = int(m.group(1)) if m else None
        _battery["ac"] = "AC Power" in out


def _refresh_battery_async() -> None:
    threading.Thread(target=_refresh_battery, daemon=True).start()


def _battery_cell():
    with _battery_lock:
        pct, ac = _battery["pct"], _battery["ac"]
    if pct is None:
        return None
    icon = ICON_CHARGING if ac else ICON_BATTERY
    colour = GREEN if pct > 40 else YELLOW if pct > 20 else RED
    return colour, f"{icon} {pct}%"


# --- zones -------------------------------------------------------------------


def _reset_cursor(screen: Screen, draw_data: DrawData) -> None:
    screen.cursor.bg = as_rgb(color_as_int(draw_data.default_bg))
    screen.cursor.bold = False
    screen.cursor.italic = False


def _ticks_width(count: int, active_index: int) -> int:
    return count * TICK_CELLS + len(str(active_index)) + 1


def _ticks_start(columns: int, count: int, active_index: int) -> int:
    return max(0, (columns - _ticks_width(count, active_index)) // 2)


def _draw_left(draw_data: DrawData, screen: Screen, title: str, limit: int) -> None:
    screen.cursor.x = 0
    _reset_cursor(screen, draw_data)
    if limit <= 1 or not title:
        return
    if len(title) > limit:
        title = title[: limit - 1] + "…"
    screen.cursor.fg = as_rgb(FG)
    screen.cursor.bold = True
    screen.draw(title)
    screen.cursor.bold = False


def _draw_tick(screen: Screen, is_active: bool) -> None:
    if screen.cursor.x >= screen.columns - TICK_CELLS:
        return  # more tabs than the bar can hold; drop the overflow
    screen.cursor.fg = as_rgb(FG if is_active else DIM)
    screen.cursor.bold = is_active
    screen.draw(TICK_ACTIVE if is_active else TICK_INACTIVE)
    screen.cursor.bold = False
    screen.cursor.fg = as_rgb(DIM)
    screen.draw(" ")


def _status_cells(count: int):
    cells = []
    cells.append((TEAL, f"{count} session{'' if count == 1 else 's'}"))
    battery = _battery_cell()
    if battery is not None:
        cells.append(battery)
    cells.append((GREY, f"{ICON_CLOCK} {datetime.now():%H:%M}"))
    return cells


def _draw_status(draw_data: DrawData, screen: Screen, cells) -> None:
    if not cells:
        return
    width = sum(len(t) for _, t in cells) + len(SEP) * (len(cells) - 1) + 1
    if screen.cursor.x + width >= screen.columns:
        return  # ticks already reach this far — let them win

    screen.cursor.x = screen.columns - width
    _reset_cursor(screen, draw_data)
    for i, (colour, text) in enumerate(cells):
        if i:
            screen.cursor.fg = as_rgb(GREY)
            screen.draw(SEP)
        screen.cursor.fg = as_rgb(colour)
        screen.draw(text)


# --- entry point -------------------------------------------------------------


def _timer_fired(_timer) -> None:
    global _ticks_elapsed
    _ticks_elapsed += 1
    if _ticks_elapsed % BATTERY_EVERY_N_TICKS == 0:
        _refresh_battery_async()
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global _timer_id, _tab_count, _active_index

    if _timer_id is None:
        _timer_id = add_timer(_timer_fired, TICK_SECONDS, True)
        _refresh_battery_async()

    # kitty calls draw_tab twice per render: a measuring pass (for_layout=True)
    # over every tab, then a drawing pass. Use the measuring pass purely to
    # count tabs and find the active one; drawing there would corrupt kitty's
    # width calculation.
    if extra_data.for_layout:
        if index == 1:
            _layout_tabs.clear()
        _layout_tabs.append(tab)
        if tab.is_active:
            _active_index = index
        if is_last:
            _tab_count = len(_layout_tabs)
        screen.cursor.x = min(screen.columns - 1, before + TICK_CELLS)
        return screen.cursor.x

    count = max(_tab_count, index)
    active_index = _active_index or 1

    if index == 1:
        start = _ticks_start(screen.columns, count, active_index)
        active = next((t for t in _layout_tabs if t.is_active), tab)
        _draw_left(draw_data, screen, active.title, min(start - 2, screen.columns // 3))
        screen.cursor.x = max(screen.cursor.x, start)

    _reset_cursor(screen, draw_data)
    _draw_tick(screen, tab.is_active)

    if is_last:
        screen.cursor.fg = as_rgb(TEAL)
        screen.draw(str(active_index))
        _draw_status(draw_data, screen, _status_cells(count))

    return screen.cursor.x
