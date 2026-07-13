from pathlib import Path
import sys


SCREENSHOT_PATH = Path("powerbi/screenshots/executive_overview.png")

MIN_FILE_SIZE_BYTES = 50_000
MIN_WIDTH = 1000
MIN_HEIGHT = 600


def read_png_dimensions(path: Path) -> tuple[int | None, int | None]:
    """
    Read PNG width/height from the IHDR chunk without external dependencies.
    Works on Python 3.13+ without imghdr.
    """
    with path.open("rb") as f:
        header = f.read(24)

    png_signature = b"\x89PNG\r\n\x1a\n"
    if len(header) < 24 or not header.startswith(png_signature):
        return None, None

    width = int.from_bytes(header[16:20], byteorder="big")
    height = int.from_bytes(header[20:24], byteorder="big")
    return width, height


def main() -> int:
    failures: list[str] = []

    if not SCREENSHOT_PATH.exists():
        print(f"FAIL: Required screenshot not found: {SCREENSHOT_PATH}")
        return 1

    if SCREENSHOT_PATH.suffix.lower() != ".png":
        failures.append("Screenshot must be saved as a .png file.")

    width, height = read_png_dimensions(SCREENSHOT_PATH)
    if width is None or height is None:
        failures.append("Screenshot is not a valid PNG file or PNG dimensions could not be read.")

    file_size = SCREENSHOT_PATH.stat().st_size
    if file_size < MIN_FILE_SIZE_BYTES:
        failures.append(
            f"Screenshot file is unexpectedly small: {file_size} bytes. "
            f"Expected at least {MIN_FILE_SIZE_BYTES} bytes."
        )

    if width is not None and height is not None:
        if width < MIN_WIDTH or height < MIN_HEIGHT:
            failures.append(
                f"Screenshot dimensions are too small: {width}x{height}. "
                f"Expected at least {MIN_WIDTH}x{MIN_HEIGHT}."
            )

    if failures:
        print("FAIL: Executive Overview screenshot validation failed.")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("PASS: powerbi/screenshots/executive_overview.png exists and satisfies AB#1597 acceptance criteria.")
    print(f"Validated screenshot file: {SCREENSHOT_PATH}")
    print(f"Validated PNG dimensions: {width}x{height}")
    print(f"Validated file size: {file_size} bytes")
    print("Validated committed artifact path for Executive Overview dashboard screenshot.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
