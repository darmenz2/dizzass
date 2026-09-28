#!/usr/bin/env python3
"""Offline checks for the R-01 runner's exclusive output and pinned inputs."""
import hashlib
import io
from pathlib import Path
import tarfile
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
namespace = {"__file__": str(HERE / "run.py"), "__name__": "r01_runner_test_subject"}
exec(compile((HERE / "run.py").read_text(), str(HERE / "run.py"), "exec"), namespace)


class RunnerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="r01-runner-test-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        namespace["ROOT"] = self.root

    def test_dependency_hashes(self):
        data = b"pinned source\n"
        entry = {"path": "demo.c", "blob": hashlib.sha1(b"blob 14\0" + data).hexdigest(),
                 "sha256": hashlib.sha256(data).hexdigest()}
        namespace["verify"](data, entry)
        with self.assertRaises(ValueError):
            namespace["verify"](data + b"modified", entry)

    def test_invalid_output_paths(self):
        for path in ("/tmp/outside", "integration/new", "build/../outside", "build"):
            with self.subTest(path=path), self.assertRaises(ValueError):
                namespace["exclusive_output"](path)
        self.assertEqual(list(self.root.iterdir()), [])

    def test_output_refuses_overwrite(self):
        out = namespace["exclusive_output"]("build/single-use")
        (out / "sentinel").write_bytes(b"unchanged")
        with self.assertRaises(FileExistsError):
            namespace["exclusive_output"]("build/single-use")
        self.assertEqual((out / "sentinel").read_bytes(), b"unchanged")

    def test_output_refuses_symlink(self):
        target = self.root / "outside"
        target.mkdir()
        (self.root / "build").symlink_to(target, target_is_directory=True)
        with self.assertRaises(ValueError):
            namespace["exclusive_output"]("build/new")
        self.assertEqual(list(target.iterdir()), [])

    def test_regular_archive(self):
        payload = b"plain source\n"
        stream = io.BytesIO()
        with tarfile.open(fileobj=stream, mode="w") as archive:
            item = tarfile.TarInfo("sub/test.c")
            item.size = len(payload)
            item.mode = 0o644
            archive.addfile(item, io.BytesIO(payload))
        destination = self.root / "source"
        namespace["extract_base"](stream.getvalue(), destination)
        self.assertEqual((destination / "sub/test.c").read_bytes(), payload)

    def test_archive_rejects_link_and_traversal(self):
        for number, name in enumerate(("../escape", "/absolute", "linked")):
            stream = io.BytesIO()
            with tarfile.open(fileobj=stream, mode="w") as archive:
                item = tarfile.TarInfo(name)
                if name == "linked":
                    item.type = tarfile.SYMTYPE
                    item.linkname = "../outside"
                archive.addfile(item)
            destination = self.root / ("bad-" + str(number))
            with self.subTest(name=name), self.assertRaises(ValueError):
                namespace["extract_base"](stream.getvalue(), destination)
            self.assertEqual(list(destination.iterdir()), [])


if __name__ == "__main__":
    unittest.main(verbosity=2)
