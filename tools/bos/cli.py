import argparse
import codecs

from const import LOGO
from core import exit_with_cmd


def main() -> int:
    parser = argparse.ArgumentParser(
        prog='bos',
        description=codecs.decode(LOGO, 'unicode-escape'),
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = parser.add_subparsers(dest='sub')

    fat = sub.add_parser('fat', help='Tools to deal with FAT FS')
    fat.add_argument('img', help='The FAT image')
    fat.add_argument('--read-file', '-rf', help='Read a file')

    argv = parser.parse_args()

    if argv.sub == 'fat':
        if argv.read_file:
            cmd = ['build/fat_file', argv.img, argv.read_file]
            exit_with_cmd(cmd[0], cmd[1:])

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
