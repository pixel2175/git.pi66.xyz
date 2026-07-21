import sys


def progress(label, current, total):
    print(f"\r\033[K[{label}]: [{current}/{total}]", end="", flush=True)


def progress_done(label, total):
    print(f"\r\033[K[{label}]: [{total}/{total}] done")
