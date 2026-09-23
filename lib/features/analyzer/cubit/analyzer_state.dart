import 'package:equatable/equatable.dart';

abstract class AnalyzerState extends Equatable {
  const AnalyzerState();

  @override
  List<Object?> get props => [];
}

class AnalyzerInitial extends AnalyzerState {
  const AnalyzerInitial();
}

class AnalyzerLoading extends AnalyzerState {
  const AnalyzerLoading();
}

class AnalyzerSuccess extends AnalyzerState {
  final String imagePath;
  final String description;

  const AnalyzerSuccess({
    required this.imagePath,
    required this.description,
  });

  @override
  List<Object?> get props => [imagePath, description];
}

class AnalyzerError extends AnalyzerState {
  final String message;

  const AnalyzerError(this.message);

  @override
  List<Object?> get props => [message];
}
