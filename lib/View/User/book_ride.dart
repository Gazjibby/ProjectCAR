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
    return ChangeNotifierProvider<BookRideViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Consumer<BookRideViewModel>(
            builder: (context, viewModel, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                                      if (viewModel.rideStatusMessage ==
                                          "Confirm Ride Completion") {
                                        viewModel.confirmcompleteRide();
                                      } else {
                                        viewModel.cancelRide();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.uniMaroon,
                                    ),
                                    child: Text(
                                      viewModel.rideStatusMessage.isEmpty
                                          ? 'End Ride'
                                          : 'Cancel Ride',
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You already have an active ride. Please complete it before booking a new one.',
                                  ),
                                ),
                              );
                            } else {
                              viewModel.showBookingForm(context);
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
