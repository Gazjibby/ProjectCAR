import 'package:flutter/material.dart';
import 'package:projectcar/Model/user_ride_history.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/ViewModel/user_ride_history_viewmodel.dart';
import 'package:provider/provider.dart';

class PersonalRideHistory extends StatefulWidget {
  const PersonalRideHistory({Key? key}) : super(key: key);

  @override
  State<PersonalRideHistory> createState() => _PersonalRideHistoryState();
}

class _PersonalRideHistoryState extends State<PersonalRideHistory> {
  late UserRideHistoryViewmodel _viewModel;
  late String matricStaffNumber;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    matricStaffNumber = userProvider.user?.matricStaffNumber ?? '';
    print('${matricStaffNumber}');
    if (matricStaffNumber.isNotEmpty) {
      _viewModel = UserRideHistoryViewmodel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Ride History'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _viewModel.fetchUserRideHistory(matricStaffNumber),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching ride history.'));
                } else {
                  final List<RideHistoryModel> rideHistoryList =
                      _viewModel.rideHistoryList;

                  if (rideHistoryList.isEmpty) {
                    return const Center(child: Text('No ride history found.'));
                  }

                  return ListView.builder(
                    itemCount: rideHistoryList.length,
                    itemBuilder: (context, index) {
                      RideHistoryModel rideHistory = rideHistoryList[index];
                      return ListTile(
                        title: Text('Ride Date: ${rideHistory.pickupDate}'),
                        subtitle: Text('Status: ${rideHistory.status}'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Status History'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        rideHistory.statusHistory.map((status) {
                                      return ListTile(
                                        title: Text(status['Status'] ?? ''),
                                        subtitle: Text(status['UpTime'] ?? ''),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
