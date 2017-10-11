#!/usr/bin/env python

import os
import re
import sys

re_version = re.compile(r'([0-9]*)\.([0-9]*)\.([0-9]*)')
re_version_major = re.compile(r'([0-9]*)\.([0-9]*)')

class ArgumentError(Exception):
    def __init__(self, message):
        Exception.__init__(self, message)

def get_version(pattern):
    result = re_version.findall(str(pattern))
    if len(result) == 1:
        return map(int,result[0])
    return None

def find_upgrade_files(version_base_str, version_new_str, upgrade_directory_files):
    version_base = get_version(version_base_str)
    if version_base is None or len(version_base) != 3:
        raise ArgumentError('Invalide base version : [{}]'.format(version_base_str))
    version_new = get_version(version_new_str)
    if version_new is None or len(version_new) != 3:
        raise ArgumentError('Invalide new version : [{}]'.format(version_new_str))
    minor_upgrade = 'minor-upgrade.sh'
    if minor_upgrade not in upgrade_directory_files:
        raise ArgumentError('Invalid directory content : no [{}] script'.format(minor_upgrade))

    if version_new < version_base:
        raise ArgumentError("Can't downgrade from [{}] to [{}]. Downgrade is never allowed.".format('.'.join(map(str,version_base)),'.'.join(map(str,version_new))))

    if (version_base[:2] == version_new[:2]):
        return [minor_upgrade]

    upgrade_scripts = []
    for filename in upgrade_directory_files:
        if filename.startswith('upgrade_') and filename.endswith('.sh'):
            versions = filename[len('upgrade_'):-len('.sh')]
            if '_' in versions:
                versions_parts = versions.split('_')
                if len(versions_parts)==2:
                    version_start = versions_parts[0]
                    version_end = versions_parts[1]
                    version_start_match = re_version_major.match(version_start)
                    version_end_match = re_version_major.match(version_end)
                    if version_start_match is not None and version_end_match is not None:
                        upgrade_scripts.append((filename, tuple(map(int,version_start_match.groups())), tuple(map(int,version_end_match.groups())) ))

    upgrade_scripts.sort(key=lambda x:(x[1],x[2]))
    version_base_major = (version_base[0], version_base[1])
    version_new_major = (version_new[0], version_new[1])
    result = []
    for upgrade_script in upgrade_scripts:
        filename, version_start, version_end = upgrade_script
        if version_base_major <= version_start and version_end <= version_new_major:
            result.append(filename)

    return result

def find_upgrade(version_base, version_new, upgrade_directory):
    files = os.listdir(upgrade_directory)
    upgrade_files = find_upgrade_files(version_base, version_new, files)
    for filename in upgrade_files:
        print filename

def main():
    if len(sys.argv) != 4:
        raise ArgumentError("Usage: {} VERSION_BASE VERSION_NEW UPGRADE_DIRECTORY : You should provide 3 arguments to this script".format(sys.argv[0]))
    self_script_name, version_base, version_new, upgrade_directory = sys.argv
    find_upgrade(version_base, version_new, upgrade_directory)

def test():
    import unittest
    
    class TestUpgrade(unittest.TestCase):
        upgrade_dir_content_classical = [ 
            'add_collate.sh',
            'db_update_1.3_1.4.py',
            'db_update_helper.py',
            'fix_mysql_user.py',
            'minor-upgrade.sh',
            'regenerate_secret_key.sh',
            'sql',
            'upgrade_1.2_1.3.sh',
            'upgrade_1.3_1.4.sh',
            'upgrade_1.4_1.5.sh',
            'upgrade_1.5_1.6.sh',
            'upgrade_1.6_1.7.sh',
            'upgrade_1.7_1.8.sh',
            'upgrade_1.8_2.0.sh',
            'upgrade_2.0_2.1.sh',
            'upgrade_2.1_2.2.sh',
            'upgrade_2.2_3.0.sh',
            'upgrade_3.0_3.1.sh',
            'upgrade_3.1_4.0.sh',
            'upgrade_4.0_4.1.sh',
            'upgrade_4.1_4.2.sh',
            'upgrade_4.2_4.3.sh',
            'upgrade_4.3_4.4.sh',
            'upgrade_4.4_5.0.sh',
            'upgrade_5.0_5.1.sh',
            'upgrade_5.1_6.0.sh',
            'upgrade_7.12_7.33.sh',
            'upgrade_7.8_7.12.sh',
            'upgrade_7.0_7.8.sh',
            ]
        upgrade_dir_content_no_minor = list(upgrade_dir_content_classical)
        upgrade_dir_content_no_minor.remove('minor-upgrade.sh')
        def assert_version(self, version_base_str, expected_result):
            version = get_version(version_base_str)
            self.assertEqual(version, expected_result)

        def assert_upgrade_files(self, version_base_str, version_new_str, upgrade_directory_files, upgrade_files_expected, argument_error=None):
            if argument_error is None:
                upgrade_files = find_upgrade_files(version_base_str, version_new_str, upgrade_directory_files)
                self.assertEqual(upgrade_files, upgrade_files_expected)
            else:
                self.assertRaisesRegexp(ArgumentError, argument_error, find_upgrade_files, version_base_str, version_new_str, upgrade_directory_files)

        def test_version_simple_4_0_5(self):
            self.assert_version('4.0.5',[4,0,5])

        def test_version_simple_4_0_12(self):
            self.assert_version('4.0.12',[4,0,12])

        def test_version_invalid_4_0(self):
            self.assert_version('4.0',None)

        def test_version_simple_12_18_802(self):
            self.assert_version('12.18.802',[12,18,802])

        def test_version_invalid_poide(self):
            self.assert_version('poide',None)

        def test_version_with_trash_v4_0_5_alpha(self):
            self.assert_version('v4.0.5-alpha',[4,0,5])

        def test_version_with_trash_v4_0_5alpha(self):
            self.assert_version('v4.0.5alpha',[4,0,5])

        def test_version_with_trash_v4_0_12_alpha(self):
            self.assert_version('v4.0.12-alpha',[4,0,12])

        def test_version_with_trash_v4_0_12alpha(self):
            self.assert_version('v4.0.12alpha',[4,0,12])

        def test_upgrade_invalid_no_minor(self):
            self.assert_upgrade_files('4.0.8','6.0.5',self.upgrade_dir_content_no_minor,None,r'Invalid directory content : no \[minor-upgrade.sh\] script')

        def test_upgrade_valid_4_0_to_6_0(self):
            self.assert_upgrade_files('4.0.8','6.0.5',self.upgrade_dir_content_classical,['upgrade_4.0_4.1.sh','upgrade_4.1_4.2.sh','upgrade_4.2_4.3.sh','upgrade_4.3_4.4.sh','upgrade_4.4_5.0.sh','upgrade_5.0_5.1.sh','upgrade_5.1_6.0.sh'])

        def test_upgrade_valid_4_0_8to_4_0_10(self):
            self.assert_upgrade_files('4.0.8','4.0.10',self.upgrade_dir_content_classical,['minor-upgrade.sh'])

        def test_upgrade_valid_6_0_2_to_6_0_5(self):
            self.assert_upgrade_files('6.0.2','6.0.5',self.upgrade_dir_content_classical,['minor-upgrade.sh'])

        def test_upgrade_valid_4_0_8_to_4_3_2(self):
            self.assert_upgrade_files('4.0.8','4.3.2',self.upgrade_dir_content_classical,['upgrade_4.0_4.1.sh','upgrade_4.1_4.2.sh','upgrade_4.2_4.3.sh'])

        def test_upgrade_valid_4_3_2_to_6_0_5(self):
            self.assert_upgrade_files('4.3.2','6.0.5',self.upgrade_dir_content_classical,['upgrade_4.3_4.4.sh','upgrade_4.4_5.0.sh','upgrade_5.0_5.1.sh','upgrade_5.1_6.0.sh'])

        def test_upgrade_invalid_downgrade_6_0_5_to_4_3_2(self):
            self.assert_upgrade_files('6.0.5','4.3.2',self.upgrade_dir_content_classical,None,r'Can\'t downgrade from \[6\.0\.5\] to \[4\.3\.2\]\. Downgrade is never allowed.')

        def test_upgrade_invalid_downgrade_6_0_8_to_6_0_5(self):
            self.assert_upgrade_files('6.0.8','6.0.5',self.upgrade_dir_content_classical,None,r'Can\'t downgrade from \[6\.0\.8\] to \[6\.0\.5\]\. Downgrade is never allowed.')

        def test_upgrade_invalid_downgrade_4_3_12_to_4_3_2(self):
            self.assert_upgrade_files('4.3.12','4.3.2',self.upgrade_dir_content_classical,None,r'Can\'t downgrade from \[4\.3\.12\] to \[4\.3\.2\]\. Downgrade is never allowed.')

        def test_upgrade_valid_4_3_2_to_4_3_2(self):
            self.assert_upgrade_files('4.3.2','4.3.2',self.upgrade_dir_content_classical,['minor-upgrade.sh'])

        def test_upgrade_valid_7_0_3_to_7_4_2(self):
            self.assert_upgrade_files('7.0.3','7.4.2',self.upgrade_dir_content_classical,[])

        def test_upgrade_valid_7_0_3_to_7_40_2(self):
            self.assert_upgrade_files('7.0.3','7.40.2',self.upgrade_dir_content_classical,['upgrade_7.0_7.8.sh','upgrade_7.8_7.12.sh','upgrade_7.12_7.33.sh'])

        def test_upgrade_valid_7_0_3_to_7_20_2(self):
            self.assert_upgrade_files('7.0.3','7.20.2',self.upgrade_dir_content_classical,['upgrade_7.0_7.8.sh','upgrade_7.8_7.12.sh'])

    suite = unittest.TestLoader().loadTestsFromTestCase(TestUpgrade)
    unittest.TextTestRunner(verbosity=1).run(suite)

if __name__ == '__main__':
    if len(sys.argv) == 1:
        test()
    else:
        main()

