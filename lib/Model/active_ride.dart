class ActiveRide {
  final String userRequest;
  final String userName;
  final String driverAccepted;
  final String pickupLocation;
  final String dropoffLocation;
  final String pickupDate;
  final String pickupTime;
  final int passengerCount;
  final int price;
  final int status;

  ActiveRide(
      {required this.userRequest,
      required this.userName,
      required this.driverAccepted,
      required this.pickupLocation,
      required this.dropoffLocation,
      required this.pickupDate,
      required this.pickupTime,
      required this.passengerCount,
      required this.price,
      required this.status});

  factory ActiveRide.fromMap(Map<String, dynamic> data, String id) {
    return ActiveRide(
      userRequest: data['UserRequest'],
      userName: data['UserName'],
      status: data['Status'],
      driverAccepted: data['DriverAccepted'],
      pickupLocation: data['Ride Details']['pickupLocation'],
      dropoffLocation: data['Ride Details']['dropoffLocation'],
      pickupDate: data['Ride Details']['pickupDate'],
      pickupTime: data['Ride Details']['pickupTime'],
      passengerCount: data['Ride Details']['passengerCount'],
      price: data['Ride Details']['price'],
    );
  }
}
