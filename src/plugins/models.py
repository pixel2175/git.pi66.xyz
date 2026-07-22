from dataclasses import dataclass


@dataclass
class ChangedFile:
    name: str
    added_lines: int
    removed_lines: int
    status: str = "M"


@dataclass
class Commit:
    date: str
    message: str
    author: str
    commit_hash: str
    files: list[ChangedFile]
    patch: str


@dataclass
class FileEntry:
    path: str
    mode: str
    size: str


@dataclass
class RefEntry:
    name: str
    date: str
    author: str


@dataclass
class Ref:
    name: str
    refs: list[RefEntry]


@dataclass
class Repo:
    name: str
    desc: str
    author: str
    readme: str | None
    license: str | None
    commits: list[Commit]
    files: list[FileEntry]
    refs: list[Ref]
    last_commit_date: str
