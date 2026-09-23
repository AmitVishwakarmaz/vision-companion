import 'package:equatable/equatable.dart';

abstract class DetectorState extends Equatable {
  const DetectorState();

  @override
  List<Object?> get props => [];
}

class DetectorInitial extends DetectorState {
  const DetectorInitial();
}

class DetectorRunning extends DetectorState {
  final List<String> detectedObjects;

  const DetectorRunning({this.detectedObjects = const []});

  @override
  List<Object?> get props => [detectedObjects];
}

class DetectorStopped extends DetectorState {
  const DetectorStopped();
}
