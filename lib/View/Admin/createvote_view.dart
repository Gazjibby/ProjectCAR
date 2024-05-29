import 'package:flutter/material.dart';
import 'package:projectcar/Utils/message.dart';
import 'package:provider/provider.dart';
import 'package:projectcar/Providers/poll_db_provider.dart';

class CreateVote extends StatefulWidget {
  const CreateVote({super.key});

  @override
  State<CreateVote> createState() => _CreateVoteState();
}

class _CreateVoteState extends State<CreateVote> {
  TextEditingController question = TextEditingController();
  TextEditingController reason = TextEditingController();
  TextEditingController option1 = TextEditingController();
  TextEditingController option2 = TextEditingController();
  TextEditingController endDate = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Poll"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    formWidget(question, label: "Question"),
                    formWidget(reason, label: "reason"),
                    formWidget(option1, label: "Option 1"),
                    formWidget(option2, label: "Option 2"),
                    formWidget(endDate, label: "EndDate", onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.utc(2027))
                          .then((value) {
                        if (value == null) {
                          endDate.clear();
                        } else {
                          endDate.text = value.toString();
                        }
                      });
                    }),
                    Consumer<PollDbProvider>(builder: (context, db, child) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) {
                          if (db.message != "") {
                            if (db.message.contains("Poll Created")) {
                              success(context, message: db.message);
                              db.clear();
                            } else {
                              error(context, message: db.message);
                              db.clear();
                            }
                          }
                        },
                      );
                      return GestureDetector(
                        onTap: db.status == true
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  List<Map> options = [
                                    {
                                      "answer": option1.text.trim(),
                                      "percent": 0,
                                    },
                                    {
                                      "answer": option2.text.trim(),
                                      "percent": 0,
                                    },
                                  ];
                                  DateTime endDateValue =
                                      DateTime.parse(endDate.text);
                                  db.addPoll(
                                      question: question.text.trim(),
                                      reason: reason.text.trim(),
                                      endDate: endDateValue,
                                      options: options);
                                }
                              },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width - 100,
                          decoration: BoxDecoration(
                              color: db.status == true
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : const Color.fromARGB(255, 153, 11, 46),
                              borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: Text(db.status == true
                              ? "Please wait..."
                              : "Post Poll"),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget formWidget(TextEditingController controller,
      {String? label, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        onTap: onTap,
        readOnly: onTap == null ? false : true,
        controller: controller,
        validator: (value) {
          if (value!.isEmpty) {
            return "Input is required";
          }
          return null;
        },
        decoration: InputDecoration(
            errorBorder: const OutlineInputBorder(),
            labelText: label!,
            border: const OutlineInputBorder()),
      ),
    );
  }
}
