#!/usr/bin/env python3
import unittest
import check_legacy_scope as scope
class Scope(unittest.TestCase):
    def setUp(self):
        self.changes = [('M', p) for p in scope.EXPECTED]
        self.blobs = dict(scope.EXPECTED)
    def test_exact_proposal(self):
        scope.validate(self.changes, self.blobs)
    def test_unexpected_old_source(self):
        with self.assertRaises(ValueError):
            scope.validate(self.changes + [('M', 'cgminer.c')], self.blobs)
    def test_deleted_or_renamed(self):
        for status in ['D', 'R100']:
            with self.assertRaises(ValueError):
                scope.validate([(status, self.changes[0][1]), *self.changes[1:]], self.blobs)
    def test_changed_proposal_bytes(self):
        self.blobs[self.changes[0][1]] = '0' * 40
        with self.assertRaises(ValueError):
            scope.validate(self.changes, self.blobs)
    def test_missing_replacement(self):
        with self.assertRaises(ValueError):
            scope.validate(self.changes[:-1], self.blobs)
if __name__ == '__main__':
    unittest.main(verbosity=2)
