class RideTemplate {
  final String pickupPointName;
  final double pickupLat;
  final double pickupLng;
  final String dropoffPointName;
  final double dropoffLat;
  final double dropoffLng;
  final int price;

  RideTemplate({
    required this.pickupPointName,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffPointName,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.price,
  });

  factory RideTemplate.fromMap(Map<String, dynamic> data) {
    return RideTemplate(
      pickupPointName: data['pickup']['pickupPointName'],
      pickupLat: data['pickup']['latitude'],
      pickupLng: data['pickup']['longitude'],
      dropoffPointName: data['dropoff']['dropOffPointName'],
      dropoffLat: data['dropoff']['latitude'],
      dropoffLng: data['dropoff']['longitude'],
      price: data['price'],
    );
  }
}
