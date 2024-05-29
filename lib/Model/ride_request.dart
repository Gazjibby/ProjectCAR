class RideRequest {
  final String rideReqID;
  final String userRequest;
  final String userName;
  final String driverAccepted;
  final String pickupLocation;
  final String dropoffLocation;
  final String pickupDate;
  final String pickupTime;
  final int passengerCount;
  final int price;

  RideRequest({
    required this.rideReqID,
    required this.userRequest,
    required this.userName,
    required this.driverAccepted,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupDate,
    required this.pickupTime,
    required this.passengerCount,
    required this.price,
  });
}
