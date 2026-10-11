#!/usr/bin/env python3

# Populates src/fonts with the open source (SIL OFL 1.1) fonts that CsoundQt
# bundles for the widget panel, together with their license files.
#
# The fonts are vendored in the repository; this script only exists to make
# that reproducible and to verify the checked-in files (--check).
#
# Only the Regular face of each family is needed: widget text is always plain
# (QLabel with Qt::PlainText), so there is no bold/italic/rich text.
#
# Usage:
#   util/fetch_fonts.py            # download/refresh src/fonts
#   util/fetch_fonts.py --check    # verify existing files against the sha256s

import argparse
import hashlib
import io
import os
import sys
import tarfile
import urllib.request

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONTS_DIR = os.path.join(REPO_ROOT, "src", "fonts")

# Pinned upstream sources (do not use a moving branch).
GOOGLE_COMMIT = "51303ca9e8ac9dcea7b12d307ba568fd0e6fcfca"
GOOGLE_RAW = "https://raw.githubusercontent.com/google/fonts/%s/ofl" % GOOGLE_COMMIT
LIBERATION_TARBALL = ("https://github.com/liberationfonts/liberation-fonts/"
                      "files/7261482/liberation-fonts-ttf-2.1.5.tar.gz")

# Each family: category, directory, font files and license file.
# A "source" is either "google" (path relative to ofl/) or "liberation"
# (member name inside the release tarball).
FAMILIES = [
    # ---- Sans ----
    {
        "category": "Sans", "family": "LiberationSans",
        "files": [{
            "name": "LiberationSans-Regular.ttf",
            "source": "liberation",
            "path": "liberation-fonts-ttf-2.1.5/LiberationSans-Regular.ttf",
            "sha256": "76d04c18ea243f426b7de1f3ad208e927008f961dc5945e5aad352d0dfde8ee8",
        }],
        "license": {"name": "LICENSE", "source": "liberation",
                    "path": "liberation-fonts-ttf-2.1.5/LICENSE",
                    "sha256": "93fed46019c38bbe566b479d22148e2e8a1e85ada614accb0211c37b2c61c19b"},
    },
    {
        "category": "Sans", "family": "NotoSans",
        "files": [{
            "name": "NotoSans[wdth,wght].ttf",
            "source": "google",
            "path": "notosans/NotoSans%5Bwdth,wght%5D.ttf",
            "sha256": "bfb7bb691513f12e734dc346c03a03f784912432d7e3fa8e56efcf906fe86b3d",
        }],
        "license": {"name": "OFL.txt", "source": "google",
                    "path": "notosans/OFL.txt",
                    "sha256": "cee9892f9f0cc8fe882c9e9537ee6a89621d86ee7ceaf70b02e2b2b1c25c061a"},
    },
    {
        "category": "Sans", "family": "Inter",
        "files": [{
            "name": "Inter[opsz,wght].ttf",
            "source": "google",
            "path": "inter/Inter%5Bopsz,wght%5D.ttf",
            "sha256": "29160a80ff49ddcab2c97711247e08b1fab27a484a329ce8b813d820dc559031",
        }],
        "license": {"name": "OFL.txt", "source": "google",
                    "path": "inter/OFL.txt",
                    "sha256": "5b9321a4298cfeb6b34354164a1c3afc3db114569984c502b9b35d988fd58c57"},
    },
    {
        "category": "Sans", "family": "SourceSans3",
        "files": [{
            "name": "SourceSans3[wght].ttf",
            "source": "google",
            "path": "sourcesans3/SourceSans3%5Bwght%5D.ttf",
            "sha256": "042fe2cc0b933e328410d7acbd0aa6a1873dca5aef81875f4bc214b08825c7b9",
        }],
        "license": {"name": "OFL.txt", "source": "google",
                    "path": "sourcesans3/OFL.txt",
                    "sha256": "09746787287a289323b0ec3cff4d1a4a801331b82b7207c1e186f5d26619a392"},
    },
    {
        "category": "Sans", "family": "IBMPlexSans",
        "files": [{
            "name": "IBMPlexSans[wdth,wght].ttf",
            "source": "google",
            "path": "ibmplexsans/IBMPlexSans%5Bwdth,wght%5D.ttf",
            "sha256": "3b031aa4216174205bd8471f88a49b91f093169e9e87bd5262242bc5967fe2e3",
        }],
        "license": {"name": "OFL.txt", "source": "google",
                    "path": "ibmplexsans/OFL.txt",
                    "sha256": "7e6b2818edbd8f6a01ae80641cc8f16a51080d08fb4e532be3a0b6f74adb07da"},
    },
    # ---- Serif ----
    {
        "category": "Serif", "family": "IBMPlexSerif",
        "files": [{
            "name": "IBMPlexSerif-Regular.ttf",
            "source": "google",
            "path": "ibmplexserif/IBMPlexSerif-Regular.ttf",
            "sha256": "e882efa9c41949a528ac2369079ec5ef050c1c996bbd0bacce3c3326d44cf80d",
        }],
        "license": {"name": "OFL.txt", "source": "google",
                    "path": "ibmplexserif/OFL.txt",
                    "sha256": "7e6b2818edbd8f6a01ae80641cc8f16a51080d08fb4e532be3a0b6f74adb07da"},
    },
    {
        "category": "Serif", "family": "SourceSerif4",
        "files": [{
            "name": "SourceSerif4[opsz,wght].ttf",
            "source": "google",
            "path": "sourceserif4/SourceSerif4%5Bopsz,wght%5D.ttf",
            "sha256": "97b2d4da6e3cb494b5a1e66ae176914d852ccabef49e0c02c0df25f3e39aca0b",
        }],
        "license": {"name": "OFL.txt", "source": "google",
                    "path": "sourceserif4/OFL.txt",
                    "sha256": "5f94c3fd3a23131a417ab5a0c8452de57e70c3cfb9f604d88241f7065ebf9fd9"},
    },
    {
        "category": "Serif", "family": "LiberationSerif",
        "files": [{
            "name": "LiberationSerif-Regular.ttf",
            "source": "liberation",
            "path": "liberation-fonts-ttf-2.1.5/LiberationSerif-Regular.ttf",
            "sha256": "058ea80864aef09a23f45cbec2bb5400bc3dfbdea01c3f10538a21fcb497fb74",
        }],
        "license": {"name": "LICENSE", "source": "liberation",
                    "path": "liberation-fonts-ttf-2.1.5/LICENSE",
                    "sha256": "93fed46019c38bbe566b479d22148e2e8a1e85ada614accb0211c37b2c61c19b"},
    },
    # ---- Mono ----
    {
        "category": "Mono", "family": "JetBrainsMono",
        "files": [{
            "name": "JetBrainsMono[wght].ttf",
            "source": "google",
            "path": "jetbrainsmono/JetBrainsMono%5Bwght%5D.ttf",
            "sha256": "48715a42ec242c21e9f02692891e147d022299a52e48d5e413e1a942193ffeda",
        }],
        "license": {"name": "OFL.txt", "source": "google",
                    "path": "jetbrainsmono/OFL.txt",
                    "sha256": "b2fe5e8987594e9ffd1d2ca52a2f5d73eb8335243893c5d6254b5ad69269591d"},
    },
    {
        "category": "Mono", "family": "IBMPlexMono",
        "files": [{
            "name": "IBMPlexMono-Regular.ttf",
            "source": "google",
            "path": "ibmplexmono/IBMPlexMono-Regular.ttf",
            "sha256": "6a3412f058c7d8dfd9170c41e85ade48e5156ecb89356110ca57a0a27734af46",
        }],
        "license": {"name": "OFL.txt", "source": "google",
                    "path": "ibmplexmono/OFL.txt",
                    "sha256": "7e6b2818edbd8f6a01ae80641cc8f16a51080d08fb4e532be3a0b6f74adb07da"},
    },
    {
        "category": "Mono", "family": "LiberationMono",
        "files": [{
            "name": "LiberationMono-Regular.ttf",
            "source": "liberation",
            "path": "liberation-fonts-ttf-2.1.5/LiberationMono-Regular.ttf",
            "sha256": "f2b83c763e8afd21709333370bed4774337fae82267937e2b5aea7e2fbd922c1",
        }],
        "license": {"name": "LICENSE", "source": "liberation",
                    "path": "liberation-fonts-ttf-2.1.5/LICENSE",
                    "sha256": "93fed46019c38bbe566b479d22148e2e8a1e85ada614accb0211c37b2c61c19b"},
    },
]


def fetch(url):
    request = urllib.request.Request(url, headers={"User-Agent": "csoundqt-fetch-fonts"})
    with urllib.request.urlopen(request, timeout=120) as response:
        return response.read()


class Sources:
    """Lazily downloads and caches the upstream sources."""

    def __init__(self):
        self._google_tarball = None
        self._liberation_tarball = None

    def _liberation(self):
        if self._liberation_tarball is None:
            print("Downloading Liberation fonts tarball ...")
            data = fetch(LIBERATION_TARBALL)
            self._liberation_tarball = tarfile.open(fileobj=io.BytesIO(data), mode="r:gz")
        return self._liberation_tarball

    def get(self, source, path):
        if source == "google":
            return fetch("%s/%s" % (GOOGLE_RAW, path))
        if source == "liberation":
            member = self._liberation().extractfile(path)
            if member is None:
                raise RuntimeError("member not found in tarball: %s" % path)
            return member.read()
        raise RuntimeError("unknown source: %s" % source)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def target_path(category, family, name):
    return os.path.join(FONTS_DIR, category, family, name)


def verify_repo():
    errors = 0
    checked = 0
    for family in FAMILIES:
        entries = list(family["files"]) + [family["license"]]
        for entry in entries:
            path = target_path(family["category"], family["family"], entry["name"])
            if not os.path.isfile(path):
                print("MISSING %s" % path)
                errors += 1
                continue
            with open(path, "rb") as handle:
                digest = sha256(handle.read())
            checked += 1
            expected = entry["sha256"]
            if expected and digest != expected:
                print("MISMATCH %s\n  expected %s\n  actual   %s" % (path, expected, digest))
                errors += 1
    print("Checked %d file(s), %d error(s)." % (checked, errors))
    return 1 if errors else 0


def download_repo():
    sources = Sources()
    hashes = []
    for family in FAMILIES:
        directory = os.path.join(FONTS_DIR, family["category"], family["family"])
        os.makedirs(directory, exist_ok=True)
        entries = list(family["files"]) + [family["license"]]
        for entry in entries:
            data = sources.get(entry["source"], entry["path"])
            path = os.path.join(directory, entry["name"])
            with open(path, "wb") as handle:
                handle.write(data)
            digest = sha256(data)
            hashes.append((path, digest))
            print("Wrote %s (%d bytes)" % (os.path.relpath(path, REPO_ROOT), len(data)))

    # Print the sha256s so they can be pinned in this script.
    print("\nsha256 of the downloaded files (paste into the manifest):")
    for path, digest in hashes:
        print("  %s  %s" % (digest, os.path.relpath(path, REPO_ROOT)))
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--check", action="store_true",
                        help="verify the existing src/fonts files, do not download")
    args = parser.parse_args()
    if args.check:
        return verify_repo()
    return download_repo()


if __name__ == "__main__":
    sys.exit(main())
