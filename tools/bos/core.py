from __future__ import annotations

import os
import subprocess
from typing import NoReturn


def exit_with_cmd(bin: str, args: list[str]) -> NoReturn:
    os.execvp(bin, [bin] + args)


def execute_cmd(cmd: str) -> subprocess.CompletedProcess:
    return subprocess.run(cmd.split(' '))
