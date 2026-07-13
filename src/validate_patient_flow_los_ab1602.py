from pathlib import Path
import sys


SCREENSHOT_PATHS = [
    Path("powerbi/screenshots/patient_flow.png"),
    Path("powerbi/screenshots/length_of_stay.png"),
]

MIN_FILE_SIZE_BYTES = 50_000
MIN_WIDTH = 1000
MIN_HEIGHT = 600


def read_png_dimensions(path: Path) -> tuple[int | None, int | None]:
    """
    Read PNG width/height from the IHDR chunk without external dependencies.
    Compatible with Python 3.13+.
    """
    with path.open("rb") as f:
        header = f.read(24)

    png_signature = b"\x89PNG\r\n\x1a\n"
    if len(header) < 24 or not header.startswith(png_signature):
        return None, None

    width = int.from_bytes(header[16:20], byteorder="big")
    height = int.from_bytes(header[20:24], byteorder="big")
    return width, height


def validate_png(path: Path) -> list[str]:
    failures: list[str] = []

    if not path.exists():
        return [f"Required screenshot not found: {path}"]

    if path.suffix.lower() != ".png":
        failures.append(f"{path} must be saved as a .png file.")

    width, height = read_png_dimensions(path)
    if width is None or height is None:
        failures.append(f"{path} is not a valid PNG file or PNG dimensions could not be read.")
    else:
        if width < MIN_WIDTH or height < MIN_HEIGHT:
            failures.append(
                f"{path} dimensions are too small: {width}x{height}. "
                f"Expected at least {MIN_WIDTH}x{MIN_HEIGHT}."
            )

    file_size = path.stat().st_size
    if file_size < MIN_FILE_SIZE_BYTES:
        failures.append(
            f"{path} is unexpectedly small: {file_size} bytes. "
            f"Expected at least {MIN_FILE_SIZE_BYTES} bytes."
        )

    return failures


def main() -> int:
    failures: list[str] = []

    for screenshot_path in SCREENSHOT_PATHS:
        failures.extend(validate_png(screenshot_path))

    if failures:
        print("FAIL: Patient Flow and LOS screenshot validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: Patient Flow and LOS screenshots satisfy AB#1600 acceptance criteria.")
    for screenshot_path in SCREENSHOT_PATHS:
        width, height = read_png_dimensions(screenshot_path)
        file_size = screenshot_path.stat().st_size
        print(f"Validated screenshot file: {screenshot_path}")
        print(f"Validated PNG dimensions: {width}x{height}")
        print(f"Validated file size: {file_size} bytes")
    print("Validated committed artifact paths for Patient Flow and Length of Stay dashboard screenshots.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
