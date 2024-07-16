class ReportModel {
  final String reportAuthor;
  final String reportType;
  final String description;
  final String rideID;
  final String driverAccepted;
  final String userRequest;
  final DateTime timestamp;

  ReportModel({
    required this.reportAuthor,
    required this.reportType,
    required this.description,
    required this.rideID,
    required this.driverAccepted,
    required this.userRequest,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportBy': reportAuthor,
      'reportType': reportType,
      'description': description,
      'RideID': rideID,
      'driverAccepted': driverAccepted,
      'userRequest': userRequest,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
