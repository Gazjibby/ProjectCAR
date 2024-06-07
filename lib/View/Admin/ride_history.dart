import 'package:flutter/material.dart';
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

            return ListView.builder(
              itemCount: provider.rideHistoryList.length,
              itemBuilder: (context, index) {
                final rideHistory = provider.rideHistoryList[index];

                return ListTile(
                  title: Text(rideHistory.rideReqID),
                  subtitle: Text(
                      'Driver: ${rideHistory.driverAccepted}, Passenger: ${rideHistory.userName}'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ListView.builder(
                          itemCount: rideHistory.statusHistory.length,
                          itemBuilder: (context, index) {
                            final status = rideHistory.statusHistory[index];
                            return ListTile(
                              title: Text(status['Status'] ?? ''),
                              subtitle: Text(status['UpTime'] ?? ''),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
