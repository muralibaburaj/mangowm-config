"""Shared, minimal terminal menu for the webcam and power commands."""

import os
import sys


def style(text, code):
    if not sys.stdout.isatty() or "NO_COLOR" in os.environ:
        return text
    if code in ("36", "1;36"):
        rgb = "147;138;169" if os.environ.get("XDG_SESSION_DESKTOP") == "mango" else "203;166;247"
        code = f"{'1;' if code.startswith('1;') else ''}38;2;{rgb}"
    return f"\033[{code}m{text}\033[0m"


def heading(title):
    print(f"\n{style('─' * 42, '2')}\n{style(title, '1;36')}\n{style('─' * 42, '2')}")


def menu_item(number, label, detail=""):
    suffix = f"  {style(detail, '2')}" if detail else ""
    print(f"  {style(str(number), '1;36')}  {label}{suffix}")


def ask(prompt="Choice"):
    return input(f"\n{style(prompt, '1')} {style('›', '36')} ").strip()
