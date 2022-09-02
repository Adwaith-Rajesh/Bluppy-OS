# import argparse
import codecs

from const import LOGO


def main() -> int:
    print(codecs.decode(LOGO, 'unicode-escape'))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
