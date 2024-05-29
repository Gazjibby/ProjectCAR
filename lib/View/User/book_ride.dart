import 'package:flutter/material.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:projectcar/ViewModel/book_ride_viewmodel.dart';
import 'package:provider/provider.dart';

class BookRide extends StatefulWidget {
  const BookRide({Key? key}) : super(key: key);

  @override
  State<BookRide> createState() => _BookRideState();
}

class _BookRideState extends State<BookRide> {
  late BookRideViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BookRideViewModel(context);
    _viewModel.fetchRideStatus();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _viewModel,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Consumer<BookRideViewModel>(
            builder: (context, viewModel, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (viewModel.rideStatusMessage.isNotEmpty)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.uniPeach,
                            child: SizedBox(
                              width: 370,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      viewModel.rideStatusMessage,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        viewModel.cancelRide();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.uniMaroon,
                                      ),
                                      child: Text(
                                        'Cancel Ride',
                                        style: TextStyle(
                                          color: AppColors.uniGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0, right: 10.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () async {
                            bool hasActiveRide =
                                await viewModel.hasActiveRide();
                            if (hasActiveRide) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You already have an active ride. Please complete it before booking a new one.',
                                  ),
                                ),
                              );
                            } else {
                              // ignore: use_build_context_synchronously
                              _showBookingForm(context, viewModel);
                            }
                          },
                          backgroundColor: AppColors.uniMaroon,
                          foregroundColor: AppColors.uniGold,
                          child: const Icon(Icons.directions_car),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void _showConfirmation(BuildContext context, BookRideViewModel viewModel) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (viewModel.selectedPickup != null &&
                  viewModel.selectedDropoff != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pickup Location: ${viewModel.selectedPickup}'),
                    Text('Dropoff Location: ${viewModel.selectedDropoff}'),
                    Text(
                        'Pickup Date: ${viewModel.selectedDate!.day}/${viewModel.selectedDate!.month}/${viewModel.selectedDate!.year}'),
                    Text(
                        'Pickup Time: ${viewModel.selectedTime!.format(context)}'),
                    Text('Passenger Count: ${viewModel.numOfPax}'),
                    if (viewModel.price != null)
                      Text(
                        'Price: RM${viewModel.price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.postRideBooking();
              Navigator.of(context).pop();
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      );
    },
  );
}

void _showBookingForm(BuildContext context, BookRideViewModel viewModel) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Book Ride'),
        content: SizedBox(
          height: 370,
          child: Form(
            key: viewModel.formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Pickup Location'),
                    items: viewModel.getPickupItems(),
                    value: viewModel.selectedPickup,
                    onChanged: (value) {
                      viewModel.selectedPickup = value;
                      viewModel.updatePrice();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a pickup location';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Dropoff Location'),
                    items: viewModel.getDropOffItems(),
                    value: viewModel.selectedDropoff,
                    onChanged: (value) {
                      viewModel.selectedDropoff = value;
                      viewModel.updatePrice();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a dropoff location';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Number of Passengers'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of passengers';
                      }
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Please enter a valid number of passengers';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      viewModel.numOfPax = int.tryParse(value);
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Select Date'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        viewModel.selectedDate = pickedDate;
                      }
                    },
                    validator: (value) {
                      if (viewModel.selectedDate == null) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                    controller: TextEditingController(
                        text: viewModel.selectedDate != null
                            ? '${viewModel.selectedDate!.day}/${viewModel.selectedDate!.month}/${viewModel.selectedDate!.year}'
                            : ''),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Select Time'),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        viewModel.selectedTime = pickedTime;
                      }
                    },
                    validator: (value) {
                      if (viewModel.selectedTime == null) {
                        return 'Please select a time';
                      }
                      return null;
                    },
                    controller: TextEditingController(
                        text: viewModel.selectedTime != null
                            ? viewModel.selectedTime!.format(context)
                            : ''),
                  ),
                  if (viewModel.price != null)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Price: RM${viewModel.price}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Book'),
            onPressed: () async {
              if (viewModel.formKey.currentState!.validate()) {
                bool hasActiveRide = await viewModel.hasActiveRide();
                if (hasActiveRide) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'You already have an active ride. Please complete it before booking a new one.'),
                    ),
                  );
                } else {
                  viewModel.selectedPickup = viewModel.selectedPickup;
                  viewModel.selectedDropoff = viewModel.selectedDropoff;
                  viewModel.price = viewModel.price;
                  Navigator.of(context).pop();
                  _showConfirmation(context, viewModel);
                }
              }
            },
          ),
        ],
      );
    },
  );
}
