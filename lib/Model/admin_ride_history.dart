import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Model/driver.dart';

class AdminRideHistoryModel {
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
  final String status;
  final List<Map<String, String>> statusHistory;
  final UserModel user;
  final DriverModel driver;

  AdminRideHistoryModel({
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
    required this.status,
    required this.statusHistory,
    required this.user,
    required this.driver,
  });

  factory AdminRideHistoryModel.fromMap(
    Map<String, dynamic> data,
    List<Map<String, String>> statusHistory,
    UserModel user,
    DriverModel driver,
  ) {
    return AdminRideHistoryModel(
      rideReqID: data['rideReqID'] ?? '',
      userRequest: data['UserRequest'] ?? '',
      userName: data['UserName'] ?? '',
      driverAccepted: data['DriverAccepted'] ?? '',
      pickupLocation: data['Ride Details']['pickupLocation'] ?? '',
      dropoffLocation: data['Ride Details']['dropoffLocation'] ?? '',
      pickupDate: data['Ride Details']['pickupDate'] ?? '',
      pickupTime: data['Ride Details']['pickupTime'] ?? '',
      passengerCount: data['Ride Details']['passengerCount'] ?? 0,
      price: data['Ride Details']['price'] ?? 0,
      status: data['Status'] ?? '',
      statusHistory: statusHistory,
      user: user,
      driver: driver,
    );
  }
}
