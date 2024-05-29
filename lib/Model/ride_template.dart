class RideTemplate {
  final String pickup;
  final String dropoff;
  final int price;

  RideTemplate(
      {required this.pickup, required this.dropoff, required this.price});

  factory RideTemplate.fromMap(Map<String, dynamic> data) {
    return RideTemplate(
      pickup: data['Pickup'],
      dropoff: data['DropOff'],
      price: data['Price'],
    );
  }
}
