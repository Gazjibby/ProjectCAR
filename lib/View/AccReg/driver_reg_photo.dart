import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projectcar/ViewModel/driver_reg_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projectcar/View/login_view.dart';
import 'package:flutter/services.dart' show rootBundle;

class DriverRegPhotoView extends StatefulWidget {
  final DriverRegViewModel viewModel;
  final String matricStaffNumber;

  const DriverRegPhotoView({
    Key? key,
    required this.viewModel,
    required this.matricStaffNumber,
  }) : super(key: key);

  @override
  _DriverRegPhotoViewState createState() => _DriverRegPhotoViewState();
}

class _DriverRegPhotoViewState extends State<DriverRegPhotoView> {
  String? _photoUrl;
  String? _selectedBrand;
  String? _selectedModel;
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  List<Map<String, dynamic>> carList = [];

  @override
  void initState() {
    super.initState();
    loadCarList();
  }

  Future<void> loadCarList() async {
    final String response =
        await rootBundle.loadString('lib/Asset/car_list.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      carList = data.cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photo & Car Details'),
      ),
      body: carList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedBrand,
                    hint: const Text('Select Brand'),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedBrand = value;
                        _selectedModel = null;
                      });
                    },
                    items: carList.map<DropdownMenuItem<String>>((car) {
                      return DropdownMenuItem<String>(
                        value: car['brand'],
                        child: Text(car['brand']),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Car Brand',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (_selectedBrand != null)
                    DropdownButtonFormField<String>(
                      value: _selectedModel,
                      hint: const Text('Select Model'),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedModel = value;
                        });
                      },
                      items: carList
                          .firstWhere(
                              (car) => car['brand'] == _selectedBrand)['models']
                          .map<DropdownMenuItem<String>>((model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Car Model',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _plateController,
                    decoration: const InputDecoration(
                      labelText: 'Plate Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _colorController,
                    decoration: const InputDecoration(
                      labelText: 'Car Color',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                      "Upload a photo of the vehicle with the brand and plate number visible"),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image != null) {
                        String? photoUrl = await widget.viewModel.uploadPhoto(
                          image.path,
                          widget.matricStaffNumber,
                        );

                        if (photoUrl != null) {
                          setState(() {
                            _photoUrl = photoUrl;
                          });
                          print('Photo uploaded successfully. URL: $photoUrl');
                        } else {
                          print('Failed to upload photo.');
                        }
                      }
                    },
                    child: const Text('Upload Photo'),
                  ),
                  const SizedBox(height: 16.0),
                  if (_photoUrl != null)
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await widget.viewModel.registerDriver(
                            photoUrl: _photoUrl!,
                            carBrand: _selectedBrand!,
                            carModel: _selectedModel!,
                            carColor: _colorController.text,
                            plateNumber: _plateController.text,
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginView()),
                          );
                        } catch (e) {
                          print('Error registering: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Registration failed. Please try again.'),
                            ),
                          );
                        }
                      },
                      child: const Text('Register'),
                    ),
                ],
              ),
            ),
    );
  }
}
