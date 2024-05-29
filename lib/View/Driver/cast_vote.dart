import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:projectcar/Utils/message.dart';
import 'package:provider/provider.dart';
import 'package:projectcar/Providers/get_poll_db_provider.dart';
import 'package:projectcar/Providers/poll_db_provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/Model/driver.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  bool _isFetched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Active Voting Session'),
        ),
        body: Consumer<FetchPollsProvider>(
          builder: (context, polls, child) {
            if (!_isFetched) {
              polls.fetchPolls();
              Future.delayed(const Duration(microseconds: 1), () {
                setState(() {
                  _isFetched = true;
                });
              });
            }

            return SingleChildScrollView(
              child: SafeArea(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: List.generate(polls.pollsList.length, (index) {
                      final data = polls.pollsList[index];

                      log(data.data().toString());

                      Map poll = data["poll"];

                      List<dynamic> options = poll["options"];
                      Timestamp endDate = poll["endDate"];
                      List voters = poll["voters"];

                      return Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromARGB(255, 111, 112, 112)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              title: Center(
                                child: Text(
                                  "Active Voting Session",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              subtitle: Center(
                                child: Text(
                                  "Ends in ${DateFormat().add_yMEd().format(endDate.toDate())}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Text(poll["question"]),
                            const SizedBox(height: 8),
                            ...List.generate(options.length, (index) {
                              final dataOption = options[index];
                              return Consumer<PollDbProvider>(
                                  builder: (context, vote, child) {
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) {
                                    if (vote.message != "") {
                                      if (vote.message
                                          .contains("Vote Recorded")) {
                                        success(context, message: vote.message);
                                        polls.fetchPolls();
                                        vote.clear();
                                      } else {
                                        error(context, message: vote.message);
                                        vote.clear();
                                      }
                                    }
                                  },
                                );
                                return GestureDetector(
                                  onTap: () {
                                    final driver = Provider.of<DriverProvider>(
                                            context,
                                            listen: false)
                                        .driver;

                                    if (driver == null ||
                                        driver.matricStaffNumber.isEmpty) {
                                      log("Driver or matricStaffNumber is null");
                                      return;
                                    }

                                    log(driver.matricStaffNumber);

                                    if (voters.isEmpty) {
                                      log("No vote");
                                      vote.votePoll(
                                          pollId: data.id,
                                          pollData: data,
                                          previousTotalVotes:
                                              poll["total_votes"],
                                          driverMatricStaffNumber:
                                              driver.matricStaffNumber,
                                          seletedOptions: dataOption["answer"]);
                                    } else {
                                      final isExists = voters.firstWhere(
                                        (element) =>
                                            element["matricStaffNumber"] ==
                                            driver.matricStaffNumber,
                                        orElse: () => null,
                                      );
                                      if (isExists == null) {
                                        log("Driver does not exist");
                                        vote.votePoll(
                                            pollId: data.id,
                                            pollData: data,
                                            previousTotalVotes:
                                                poll["total_votes"],
                                            driverMatricStaffNumber:
                                                driver.matricStaffNumber,
                                            seletedOptions:
                                                dataOption["answer"]);
                                      } else {
                                        error(context,
                                            message: "You have already voted!");
                                      }
                                      print(isExists.toString());
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              LinearProgressIndicator(
                                                minHeight: 30,
                                                value:
                                                    dataOption["percent"] / 100,
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 255, 255, 255),
                                              ),
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                height: 30,
                                                child:
                                                    Text(dataOption["answer"]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Text("${dataOption["percent"]}%"),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            }),
                            Text("Total Votes: ${poll["total_votes"]}"),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16.0),
                ],
              )),
            );
          },
        ));
  }
}
