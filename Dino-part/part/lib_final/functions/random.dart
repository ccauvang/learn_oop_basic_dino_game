import 'dart:math';

double randominRange(double min, double max) {
  if (min > max) {
    throw ArgumentError('min cannot be greater than max');
  }
  return min + (Random().nextDouble() * (max - min));
}

int randomInt(int min, int max) {
  if (min > max) {
    throw ArgumentError('min cannot be greater than max');
  }
  return min + Random().nextInt(max - min + 1);
}
