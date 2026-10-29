/// The progress of one load or action. Each independent operation in a state
/// gets its own [RequestStatus] field.
sealed class RequestStatus {
  const RequestStatus();

  bool get isLoading => this is Loading;
  bool get isSuccess => this is Succeeded;
  bool get isFailure => this is Failed;

  String? get errorMessage {
    final status = this;
    return status is Failed ? status.message : null;
  }

  @override
  bool operator ==(Object other) =>
      other is RequestStatus &&
      other.runtimeType == runtimeType &&
      other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(runtimeType, errorMessage);
}

final class Idle extends RequestStatus {
  const Idle();
}

final class Loading extends RequestStatus {
  const Loading();
}

final class Succeeded extends RequestStatus {
  const Succeeded();
}

final class Failed extends RequestStatus {
  const Failed(this.message);

  final String message;
}
