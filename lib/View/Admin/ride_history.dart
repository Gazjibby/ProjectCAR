import 'package:flutter/material.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:provider/provider.dart';
import 'package:projectcar/Providers/ride_history_provider.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (context) => RideHistoryProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ride History'),
        ),
        body: Consumer<RideHistoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Container(
                  color: AppColors.uniMaroon,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Driver',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Passenger',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Status',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'More Details',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.rideHistoryList.length,
                    itemBuilder: (context, index) {
                      final rideHistory = provider.rideHistoryList[index];

                      return Container(
                        color:
                            index % 2 == 0 ? AppColors.uniPeach : Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(rideHistory.driverAccepted),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(rideHistory.userRequest),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(rideHistory.status),
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                alignment: Alignment.topLeft,
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                ),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Driver Details:',
                                                            style: theme
                                                                .textTheme
                                                                .titleLarge),
                                                        Text(
                                                            'Name: ${rideHistory.driver.fullName}'),
                                                        Text(
                                                            'Email: ${rideHistory.driver.email}'),
                                                        Text(
                                                            'Matric/Staff Number: ${rideHistory.driver.matricStaffNumber}'),
                                                        Text(
                                                            'IC Number: ${rideHistory.driver.icNumber}'),
                                                        Text(
                                                            'Phone: ${rideHistory.driver.telephoneNumber}'),
                                                        Text(
                                                            'College: ${rideHistory.driver.college}'),
                                                        Text(
                                                            'Car Brand: ${rideHistory.driver.carBrand}'),
                                                        Text(
                                                            'Model: ${rideHistory.driver.carModel}'),
                                                        Text(
                                                            'Color: ${rideHistory.driver.carColor}'),
                                                        Text(
                                                            'Plate No: ${rideHistory.driver.carPlate}'),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            'User Request Details:',
                                                            style: theme
                                                                .textTheme
                                                                .titleLarge),
                                                        Text(
                                                            'Name: ${rideHistory.user.fullName}'),
                                                        Text(
                                                            'Email: ${rideHistory.user.email}'),
                                                        Text(
                                                            'Matric/Staff Number: ${rideHistory.user.matricStaffNumber}'),
                                                        Text(
                                                            'IC Number: ${rideHistory.user.icNumber}'),
                                                        Text(
                                                            'Phone: ${rideHistory.user.telephoneNumber}'),
                                                        Text(
                                                            'College: ${rideHistory.user.college}'),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Ride Details:',
                                                            style: theme
                                                                .textTheme
                                                                .titleLarge),
                                                        Text(
                                                            'Pick-up: ${rideHistory.pickupLocation}'),
                                                        Text(
                                                            'Drop-off: ${rideHistory.dropoffLocation}'),
                                                        Text(
                                                            'Date: ${rideHistory.pickupDate}'),
                                                        Text(
                                                            'Passengers: ${rideHistory.passengerCount}'),
                                                        Text(
                                                            'Price: RM ${rideHistory.price}'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme
                                                      .surfaceContainerHighest,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Wrap(
                                                  spacing: 8.0,
                                                  runSpacing: 8.0,
                                                  children: rideHistory
                                                      .statusHistory
                                                      .map((status) =>
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: theme
                                                                  .colorScheme
                                                                  .primary
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  status['Status'] ??
                                                                      '',
                                                                  style: theme
                                                                      .textTheme
                                                                      .bodyMedium,
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        4.0),
                                                                Text(
                                                                  status['UpTime'] ??
                                                                      '',
                                                                  style: theme
                                                                      .textTheme
                                                                      .bodySmall,
                                                                ),
                                                              ],
                                                            ),
                                                          ))
                                                      .toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
