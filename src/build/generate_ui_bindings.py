"""Generate Qt editor wrappers with SIP 6; CMake owns compilation and linking."""

import argparse
import json
from pathlib import Path
import subprocess
import sys

if sys.version_info < (3, 11):
    sys.exit("Qt Python binding generation requires Python 3.11 or later")

import tomllib


def configuration():
    import sipbuild  # noqa: F401 -- fail early when the generator is missing
    import PyQt5
    from PyQt5 import sip

    bindings = Path(PyQt5.__path__[0]) / "bindings"
    with (bindings / "QtCore" / "QtCore.toml").open("rb") as stream:
        metadata = tomllib.load(stream)
    abi = sip.SIP_ABI_VERSION
    return bindings, metadata, f"{abi >> 16}.{(abi >> 8) & 255}"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--sip-file", type=Path)
    parser.add_argument("--build-dir", type=Path)
    args = parser.parse_args()
    try:
        bindings, metadata, abi = configuration()
    except (ImportError, OSError, KeyError) as error:
        parser.exit(1, f"Qt Python bindings require Python 3.11+, SIP 6 and PyQt5 "
                    f"in the selected Python environment: {error}\n")
    if args.check:
        print(bindings.as_posix())
        return
    if args.sip_file is None or args.build_dir is None:
        parser.error("--sip-file and --build-dir are required for generation")

    source = args.sip_file.resolve()
    output = args.build_dir.resolve()
    project = output / "project"
    project.mkdir(parents=True, exist_ok=True)
    quote = json.dumps
    (project / "pyproject.toml").write_text(
        '[build-system]\nrequires = ["sip>=6.8,<7"]\nbuild-backend = "sipbuild.api"\n'
        '\n[project]\nname = "SeExpr2"\nversion = "2.0"\n'
        '\n[tool.sip.project]\n'
        f'sip-files-dir = {quote(source.parent.as_posix())}\n'
        f'sip-include-dirs = [{quote(bindings.as_posix())}]\n'
        f'abi-version = {quote(abi)}\nsip-module = "PyQt5.sip"\n'
        '\n[tool.sip.bindings.expreditor2]\n'
        f'sip-file = {quote(source.name)}\nconcatenate = 1\n'
        f'tags = {json.dumps(metadata["module-tags"])}\n'
        f'disabled-features = {json.dumps(metadata["module-disabled-features"])}\n',
        encoding="utf-8")
    subprocess.run([sys.executable, "-m", "sipbuild.tools.build", "--no-compile",
                    "--build-dir", str(output / "generated")],
                   cwd=project, check=True)


if __name__ == "__main__":
    main()
