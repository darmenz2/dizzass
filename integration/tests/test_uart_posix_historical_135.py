#!/usr/bin/env python3
"""Host-only exact raw-diff fixtures; no Git, shell, original ARM or devices."""
import hashlib
import itertools
from pathlib import Path
import stat
import unittest

import check_uart_posix_historical_135 as guard

ROOT = Path(__file__).resolve().parents[2]


def blob(raw):
    return hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest()


def canonical(records):
    return '\n'.join(sorted(records, key=lambda record: record.split('\t')[1]))


class HistoricalChanges(unittest.TestCase):
    def accepts(self, raw):
        try:
            guard.check_historical_changes(raw)
        except ValueError:
            return False
        return True

    def test_exact_seven_states_only(self):
        self.assertEqual(guard.PRIOR_MASKS, (0, 32, 26, 58, 37, 63))
        self.assertEqual(len(guard.PRIOR_RECORDS), 6)
        self.assertEqual(len(guard.CONSTRUCTOR_RECORDS), 11)
        approved = guard.approved_changes()
        self.assertEqual(len(set(approved)), 7)
        for raw in approved:
            self.assertTrue(self.accepts(raw))

    def test_prior_exact_states_retain_accepted_shell_witnesses(self):
        # SHA-256 of each exact pre-constructor shell case expansion, in order.
        expected = (
            'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
            'b9296ce24661f2998b423350aab8ede8fd87f0c384dba49f0249da2eb8329cc9',
            'cc382d5d46ccf1b74982189b2d87a78d217a1317ed8b678a113a31becdbc877e',
            'c093b830381b4f4cdd5a4243e413775cf358526ac7c1a55fb4609d6539453eda',
            'ec94c519ab7809b7610272a92f0dcad2cec3ea99b5c71e7cc44a20c105daf298',
            '58a5709dd789d043e92b446835cb8cef56ccd283d8d338086d83d3b06e1fb6ea',
        )
        self.assertEqual(tuple(hashlib.sha256(raw.encode()).hexdigest()
                               for raw in guard.approved_changes()[:6]), expected)

    def test_current_constructor_group_matches_files_and_modes(self):
        for record in guard.CONSTRUCTOR_RECORDS:
            fields, path = record.split('\t')
            old_mode, new_mode, old, current, status = fields.split()
            self.assertEqual((old_mode, new_mode, status), (':100644', '100644', 'M'))
            self.assertNotEqual(old, current)
            target = ROOT
            for part in path.split('/'):
                target = target / part
                self.assertFalse(target.is_symlink(), path)
            mode = target.stat().st_mode
            self.assertTrue(stat.S_ISREG(mode) and not mode & 0o111, path)
            self.assertEqual(blob(target.read_bytes()), current, path)

    def test_all_prior_subsets_and_orders_keep_exact_acceptance(self):
        count = 0
        for length in range(7):
            for indices in itertools.permutations(range(6), length):
                mask = sum(1 << index for index in indices)
                expected = mask in (0, 32, 26, 58, 37, 63) and indices == tuple(sorted(indices))
                raw = '\n'.join(guard.PRIOR_RECORDS[index] for index in indices)
                self.assertEqual(self.accepts(raw), expected, indices)
                count += 1
        self.assertEqual(count, 1957)

    def test_all_mixed_old_and_constructor_subsets(self):
        records = sorted(set(guard.PRIOR_RECORDS + guard.CONSTRUCTOR_RECORDS))
        self.assertEqual(len(records), 12)
        approved = set(guard.approved_changes())
        accepted = set()
        for mask in range(1 << len(records)):
            raw = canonical(record for index, record in enumerate(records) if mask & (1 << index))
            expected = raw in approved
            self.assertEqual(self.accepts(raw), expected, mask)
            if expected:
                accepted.add(raw)
        self.assertEqual(accepted, approved)

    def test_every_constructor_pair_reordering_fails(self):
        for first, second in itertools.combinations(range(11), 2):
            records = list(guard.CONSTRUCTOR_RECORDS)
            records[first], records[second] = records[second], records[first]
            self.assertFalse(self.accepts('\n'.join(records)), (first, second))

    def test_every_record_field_is_bound(self):
        for raw in guard.approved_changes()[1:]:
            records = raw.split('\n')
            for index, record in enumerate(records):
                fields, path = record.split('\t')
                old_mode, new_mode, old, current, status = fields.split()
                mutants = [record.replace(old, '0' * 40),
                           record.replace(current, '0' * 40),
                           record + '.unexpected', record.replace('\t', ' ')]
                for mode in ('000000', '100755', '120000', '160000', '040000'):
                    mutants.append(f':{mode} {new_mode} {old} {current} M\t{path}')
                    mutants.append(f'{old_mode} {mode} {old} {current} M\t{path}')
                for status in ('D', 'T', 'R100', 'A', 'C100'):
                    mutants.append(f'{old_mode} {new_mode} {old} {current} {status}\t{path}')
                for mutant in mutants:
                    changed = records[:]
                    changed[index] = mutant
                    self.assertFalse(self.accepts('\n'.join(changed)), mutant)

    def test_duplicate_extra_and_malformed_records_fail(self):
        for raw in guard.approved_changes()[1:]:
            records = raw.split('\n')
            for record in records:
                self.assertFalse(self.accepts(record + '\n' + raw))
                self.assertFalse(self.accepts(raw + '\n' + record))
            for mutant in ('\n' + raw, raw + '\n', raw + ' ',
                           raw.replace('\n', '\n\n', 1),
                           raw + '\nmalformed', raw.replace('\n', '\r\n')):
                if mutant != raw:
                    self.assertFalse(self.accepts(mutant))
            unrelated = ':100644 100644 ' + '1' * 40 + ' ' + '2' * 40 + ' M\tunrelated.c'
            self.assertFalse(self.accepts(canonical(records + [unrelated])))
        for raw in (None, b'', [], '\n', 'malformed'):
            self.assertFalse(self.accepts(raw))


if __name__ == '__main__':
    unittest.main(verbosity=2)
