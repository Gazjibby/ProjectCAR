import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/Model/admin.dart';
import 'package:projectcar/Utils/colours.dart';
import 'package:projectcar/Utils/message.dart';
import 'package:projectcar/Utils/router.dart';
import 'package:projectcar/View/Admin/create_ride_template.dart';
import 'package:projectcar/View/Admin/driverApp_view.dart';
import 'package:projectcar/View/Admin/manageDriver_view.dart';
import 'package:projectcar/View/Admin/manageUser_view.dart';
import 'package:projectcar/View/Admin/createVote_view.dart';
import 'package:projectcar/View/Admin/ride_history.dart';
import 'package:projectcar/View/Admin/vote_result.dart';
import 'package:provider/provider.dart';
import 'package:projectcar/Providers/get_poll_db_provider.dart';
import 'package:projectcar/Providers/poll_db_provider.dart';
import 'package:intl/intl.dart';
import 'package:projectcar/ViewModel/admin_home_viewmodel.dart';

class AdminHome extends StatelessWidget {
  final AdminModel admin;
  const AdminHome({Key? key, required this.admin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminHomeViewModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.uniMaroon,
          foregroundColor: AppColors.uniGold,
          title: const Text('Admin Home'),
        ),
        body: Consumer<AdminHomeViewModel>(
          builder: (context, viewModel, child) {
            if (!viewModel.isFetched) {
              Future.microtask(() {
                context.read<FetchPollsProvider>().fetchPolls();
                viewModel.setFetched(true);
              });
            }

            return SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    PollsSection(),
                    const SizedBox(height: 16.0),
                    ButtonRow(),
                    const SizedBox(height: 30.0),
                    StatisticsSection(),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: SizedBox(
          width: 200,
          height: 50,
          child: FloatingActionButton(
            onPressed: () {
              nextPage(context, const CreateVote());
            },
            child: const Text("Create Polling Session"),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class PollsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FetchPollsProvider>(
      builder: (context, polls, child) {
        return Column(
          children: List.generate(polls.pollsList.length, (index) {
            final data = polls.pollsList[index];

            Map poll = data["poll"];
            List<dynamic> options = poll["options"];
            Timestamp endDate = poll["endDate"];

            return Container(
              width: 400,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.uniPeach,
                border:
                    Border.all(color: const Color.fromARGB(255, 111, 112, 112)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Center(
                          child: Text(
                            "Active Voting Session",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Consumer<PollDbProvider>(
                          builder: (context, delete, child) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (delete.message != "") {
                                if (delete.message.contains("Poll Deleted")) {
                                  success(context, message: delete.message);
                                  polls.fetchPolls();
                                  delete.clear();
                                } else {
                                  error(context, message: delete.message);
                                  delete.clear();
                                }
                              }
                            });

                            return IconButton(
                              onPressed: delete.deleteStatus == true
                                  ? null
                                  : () {
                                      delete.endPoll(pollId: data.id);
                                    },
                              icon: delete.deleteStatus == true
                                  ? const CircularProgressIndicator()
                                  : const Icon(Icons.stop_circle_outlined),
                            );
                          },
                        ),
                      ],
                    ),
                    subtitle: Center(
                      child: Text(
                        "Ends in ${DateFormat().add_yMEd().format(endDate.toDate())}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Text(
                    poll["question"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(options.length, (index) {
                    final dataOption = options[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                LinearProgressIndicator(
                                  minHeight: 30,
                                  value: dataOption["percent"] / 100,
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  height: 30,
                                  child: Text(dataOption["answer"]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text("${dataOption["percent"]}%"),
                        ],
                      ),
                    );
                  }),
                  Text("Total Votes: ${poll["total_votes"]}"),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class ButtonRow extends StatelessWidget {
  const ButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  nextPage(context, const DriverApplication());
                },
                child: const Text('Manage Driver Applications'),
              ),
              ElevatedButton(
                onPressed: () {
                  nextPage(context, const ManageUser());
                },
                child: const Text('Manage Users'),
              ),
              ElevatedButton(
                onPressed: () {
                  nextPage(context, const ManageDriver());
                },
                child: const Text('Manage Drivers'),
              ),
              ElevatedButton(
                onPressed: () {
                  nextPage(context, const CreateRideTemplate());
                },
                child: const Text('Create New Ride Template'),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  nextPage(context, const RideHistory());
                },
                child: const Text('Ride History'),
              ),
              ElevatedButton(
                onPressed: () {
                  nextPage(context, const PollResultsPage());
                },
                child: const Text('Vote History'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<int>(
                  future: context
                      .watch<AdminHomeViewModel>()
                      .getDriverApplicantsCount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Text(
                      'Number of Driver Applicants:\n${snapshot.data}',
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<int>(
                  future: context
                      .watch<AdminHomeViewModel>()
                      .getActiveDriversCount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Text(
                      'Number of Active Drivers:\n${snapshot.data}',
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<int>(
                  future: context.watch<AdminHomeViewModel>().getUsersCount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Text(
                      'Number of Users:\n${snapshot.data}',
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<int>(
                  future:
                      context.watch<AdminHomeViewModel>().getPostedRideReq(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Text(
                      'Number of Posted Ride Requests:\n${snapshot.data}',
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<int>(
                  future:
                      context.watch<AdminHomeViewModel>().getOngoingRideReq(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Text(
                      'Number of Ongoing Ride Requests:\n${snapshot.data}',
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<int>(
                  future:
                      context.watch<AdminHomeViewModel>().getCompleteRideReq(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Text(
                      'Number of Completed Ride Requests:\n${snapshot.data}',
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
