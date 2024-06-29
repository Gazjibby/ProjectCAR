import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projectcar/Providers/get_poll_db_provider.dart';

class PollResultsPage extends StatefulWidget {
  const PollResultsPage({Key? key}) : super(key: key);

  @override
  _PollResultsPageState createState() => _PollResultsPageState();
}

class _PollResultsPageState extends State<PollResultsPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<FetchPollsProvider>(context, listen: false).fetchAllPolls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Results'),
      ),
      body: Consumer<FetchPollsProvider>(
        builder: (context, pollsProvider, child) {
          if (pollsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pollsProvider.pollsList.isEmpty) {
            return const Center(child: Text('No polls found.'));
          }

          return ListView.builder(
            itemCount: pollsProvider.pollsList.length,
            itemBuilder: (context, index) {
              final pollDoc = pollsProvider.pollsList[index];
              final pollData = pollDoc.data() as Map<String, dynamic>;
              final poll = pollData['poll'] as Map<String, dynamic>;
              final options = poll['options'] as List<dynamic>;
              final voters = poll['voters'] as List<dynamic>;

              return Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            poll['question'] ?? 'No Question',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...options.map((option) {
                            final optionMap = option as Map<String, dynamic>;
                            final optionText = optionMap['answer'] as String;
                            final percent = optionMap['percent'] as int;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(optionText),
                                  Text('$percent%'),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 10),
                          Text('Total Votes: ${poll['total_votes']}'),
                          const SizedBox(height: 10),
                          const Text(
                            'Voters:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 150.0,
                              maxWidth: 1000,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: voters.map((voter) {
                                  final voterMap =
                                      voter as Map<String, dynamic>;
                                  final matricNumber =
                                      voterMap['driverMatricStaffNumber']
                                          as String;
                                  final selectedOption =
                                      voterMap['selected_option'] as String;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0),
                                    child: Text(
                                        '$matricNumber: $selectedOption                   '),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
