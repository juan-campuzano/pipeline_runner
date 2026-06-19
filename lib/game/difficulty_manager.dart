import 'package:flame/components.dart';

class DifficultyManager extends Component {
  static const _baseSpeed = 150.0;
  static const _maxSpeed = 400.0;
  static const _baseInterval = 2.5;
  static const _minInterval = 0.8;

  double elapsedSeconds = 0;
  double worldSpeed = _baseSpeed;
  double spawnInterval = _baseInterval;

  @override
  void update(double dt) {
    elapsedSeconds += dt;
    worldSpeed = (_baseSpeed + (elapsedSeconds / 60) * (_maxSpeed - _baseSpeed))
        .clamp(_baseSpeed, _maxSpeed);
    spawnInterval = (_baseInterval - (elapsedSeconds / 60) * (_baseInterval - _minInterval))
        .clamp(_minInterval, _baseInterval);
  }

  void reset() {
    elapsedSeconds = 0;
    worldSpeed = _baseSpeed;
    spawnInterval = _baseInterval;
  }
}
