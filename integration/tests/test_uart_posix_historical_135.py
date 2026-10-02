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

    def test_exact_twelve_states_only(self):
        self.assertEqual(guard.PRIOR_MASKS, (0, 32, 26, 58, 37, 63))
        self.assertEqual(len(guard.PRIOR_RECORDS), 6)
        self.assertEqual(len(guard.CONSTRUCTOR_RECORDS), 11)
        self.assertEqual(len(guard.RESET_RECORDS), 11)
        self.assertEqual(len(guard.TICKET_RECORDS), 11)
        self.assertEqual(len(guard.SWEEP_RECORDS), 11)
        self.assertEqual(len(guard.ADDRESS_RECORDS), 11)
        self.assertEqual(len(guard.NATIVE_BOUNDARY_RECORDS), 15)
        approved = guard.approved_changes()
        self.assertEqual(len(approved), 12)
        self.assertEqual(len(set(approved)), 12)
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

    def test_prior_constructor_state_remains_an_exact_historical_witness(self):
        raw='\n'.join(guard.CONSTRUCTOR_RECORDS)
        self.assertEqual(hashlib.sha256(raw.encode()).hexdigest(),
                         '1b632991d57a24f16ad5a1e5e67c018b4cd2f058f60df1dd9ddc08f5f133ee89')
        self.assertEqual(guard.approved_changes()[6],raw)
        self.assertTrue(self.accepts(raw))

    def test_current_native_boundary_group_matches_files_and_modes(self):
        for record in guard.NATIVE_BOUNDARY_RECORDS:
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

    def test_all_mixed_old_constructor_reset_ticket_sweep_and_address_subsets(self):
        records = sorted(set(guard.PRIOR_RECORDS + guard.CONSTRUCTOR_RECORDS + guard.RESET_RECORDS + guard.TICKET_RECORDS + guard.SWEEP_RECORDS + guard.ADDRESS_RECORDS))
        self.assertEqual(len(records), 16)
        approved = set(guard.approved_changes()[:11])
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

    def test_every_reset_pair_reordering_fails(self):
        for first, second in itertools.combinations(range(11), 2):
            records = list(guard.RESET_RECORDS)
            records[first], records[second] = records[second], records[first]
            self.assertFalse(self.accepts('\n'.join(records)), (first, second))

    def test_prior_reset_state_remains_an_exact_historical_witness(self):
        raw='\n'.join(guard.RESET_RECORDS)
        self.assertEqual(hashlib.sha256(raw.encode()).hexdigest(),
                         'a2d3577c1bf102776a599450a1bfc6fe2bdf2e6e854d98938337487bf9928f15')
        self.assertEqual(guard.approved_changes()[7],raw)
        self.assertTrue(self.accepts(raw))

    def test_only_complete_reset_group_was_added_to_prior_seven_states(self):
        old_states=set(guard.approved_changes()[:7])
        self.assertEqual(set(guard.approved_changes()[:8])-old_states,
                         {'\n'.join(guard.RESET_RECORDS)})
        for index in range(len(guard.RESET_RECORDS)):
            records=list(guard.RESET_RECORDS)
            del records[index]
            self.assertFalse(self.accepts('\n'.join(records)),index)

    def test_only_complete_ticket_group_is_added_to_prior_eight_states(self):
        old_states=set(guard.approved_changes()[:8])
        self.assertEqual(set(guard.approved_changes()[:9])-old_states,
                         {'\n'.join(guard.TICKET_RECORDS)})
        for index in range(len(guard.TICKET_RECORDS)):
            records=list(guard.TICKET_RECORDS)
            del records[index]
            self.assertFalse(self.accepts('\n'.join(records)),index)

    def test_every_ticket_pair_reordering_fails(self):
        for first, second in itertools.combinations(range(11), 2):
            records = list(guard.TICKET_RECORDS)
            records[first], records[second] = records[second], records[first]
            self.assertFalse(self.accepts('\n'.join(records)), (first, second))

    def test_prior_ticket_state_remains_an_exact_historical_witness(self):
        raw='\n'.join(guard.TICKET_RECORDS)
        self.assertEqual(hashlib.sha256(raw.encode()).hexdigest(),
                         'cb5d9ea4479411af856d43b7cf8fadf35fee9f1a8579875bb270d7327d5e6065')
        self.assertEqual(guard.approved_changes()[8],raw)
        self.assertTrue(self.accepts(raw))

    def test_only_complete_sweep_group_is_added_to_prior_nine_states(self):
        old_states=set(guard.approved_changes()[:9])
        self.assertEqual(set(guard.approved_changes()[:10])-old_states,
                         {'\n'.join(guard.SWEEP_RECORDS)})
        for index in range(len(guard.SWEEP_RECORDS)):
            records=list(guard.SWEEP_RECORDS)
            del records[index]
            self.assertFalse(self.accepts('\n'.join(records)),index)

    def test_every_sweep_pair_reordering_fails(self):
        for first, second in itertools.combinations(range(11), 2):
            records = list(guard.SWEEP_RECORDS)
            records[first], records[second] = records[second], records[first]
            self.assertFalse(self.accepts('\n'.join(records)), (first, second))

    def test_prior_sweep_state_remains_an_exact_historical_witness(self):
        raw='\n'.join(guard.SWEEP_RECORDS)
        self.assertEqual(hashlib.sha256(raw.encode()).hexdigest(),
                         'b5f9a9dbd3c0485226827d9bb97ae9a23d793d296d284379527cf060be68fba5')
        self.assertEqual(guard.approved_changes()[9],raw)
        self.assertTrue(self.accepts(raw))

    def test_only_complete_address_group_is_added_to_prior_ten_states(self):
        old_states=set(guard.approved_changes()[:10])
        self.assertEqual(set(guard.approved_changes()[:11])-old_states,
                         {'\n'.join(guard.ADDRESS_RECORDS)})
        for index in range(len(guard.ADDRESS_RECORDS)):
            records=list(guard.ADDRESS_RECORDS)
            del records[index]
            self.assertFalse(self.accepts('\n'.join(records)),index)

    def test_every_address_pair_reordering_fails(self):
        for first, second in itertools.combinations(range(11), 2):
            records = list(guard.ADDRESS_RECORDS)
            records[first], records[second] = records[second], records[first]
            self.assertFalse(self.accepts('\n'.join(records)), (first, second))

    def test_prior_address_state_remains_an_exact_historical_witness(self):
        raw = '\n'.join(guard.ADDRESS_RECORDS)
        self.assertEqual(hashlib.sha256(raw.encode()).hexdigest(),
                         '5b8b761df9c0b99e9776834a80437de5d982ccbcb725b8363c21f4e0ef01cadf')
        self.assertEqual(guard.approved_changes()[10], raw)
        self.assertTrue(self.accepts(raw))

    def test_native_boundary_state_is_the_exact_reviewed_witness(self):
        raw = '\n'.join(guard.NATIVE_BOUNDARY_RECORDS)
        self.assertEqual(hashlib.sha256(raw.encode()).hexdigest(),
                         'e22dc6b27fd6d833a8810c2b1e282be6463ae5e7457a081d989148f193bcc6cd')
        self.assertEqual(guard.approved_changes()[11], raw)
        self.assertEqual(canonical(guard.NATIVE_BOUNDARY_RECORDS), raw)
        self.assertTrue(self.accepts(raw))

    def test_only_complete_native_boundary_state_is_added_to_prior_eleven(self):
        old_states = set(guard.approved_changes()[:11])
        self.assertEqual(set(guard.approved_changes()) - old_states,
                         {'\n'.join(guard.NATIVE_BOUNDARY_RECORDS)})
        for index in range(len(guard.NATIVE_BOUNDARY_RECORDS)):
            records = list(guard.NATIVE_BOUNDARY_RECORDS)
            del records[index]
            self.assertFalse(self.accepts('\n'.join(records)), index)

    def test_native_additions_require_the_complete_address_state(self):
        additions = tuple(record for record in guard.NATIVE_BOUNDARY_RECORDS
                          if record not in guard.ADDRESS_RECORDS)
        self.assertEqual(tuple(record.split('\t')[1] for record in additions), (
            '.github/workflows/cgminer-native.yml',
            'integration/CGMINER_FIRST_RU.md',
            'integration/check_native_core.py',
            'integration/test_native_core.py',
        ))
        self.assertEqual(set(guard.NATIVE_BOUNDARY_RECORDS) - set(additions),
                         set(guard.ADDRESS_RECORDS))
        address = '\n'.join(guard.ADDRESS_RECORDS)
        for prior in guard.approved_changes()[:11]:
            for mask in range(1 << len(additions)):
                records = prior.splitlines() + [
                    record for index, record in enumerate(additions)
                    if mask & (1 << index)]
                expected = mask == 0 or (prior == address and mask == 15)
                self.assertEqual(self.accepts(canonical(records)), expected,
                                 (prior, mask))

    def test_all_native_boundary_subsets_keep_exact_acceptance(self):
        records = guard.NATIVE_BOUNDARY_RECORDS
        approved = set(guard.approved_changes())
        accepted = set()
        for mask in range(1 << len(records)):
            raw = '\n'.join(record for index, record in enumerate(records)
                            if mask & (1 << index))
            expected = raw in approved
            self.assertEqual(self.accepts(raw), expected, mask)
            if expected:
                accepted.add(raw)
        expected_subsets = {raw for raw in approved
                            if set(raw.splitlines()).issubset(records)}
        self.assertEqual(accepted, expected_subsets)
        self.assertIn('\n'.join(guard.NATIVE_BOUNDARY_RECORDS), accepted)
        self.assertIn('\n'.join(guard.ADDRESS_RECORDS), accepted)

    def test_every_native_boundary_pair_reordering_fails(self):
        for first, second in itertools.combinations(range(15), 2):
            records = list(guard.NATIVE_BOUNDARY_RECORDS)
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
