/// * 2022-01
class Placement {
  int offsetX, offsetY;
  int width, height;

  bool get isValid {
    return (width > 0 && height > 0) &&
        (offsetX >= 0 && offsetX < width) &&
        (offsetY >= 0 && offsetY < height);
  }

  Placement({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });
}
