import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification/toast_helper.dart';
import 'package:http/http.dart' as http;

import 'model.dart';

class PlatePageView extends StatefulWidget {
  const PlatePageView({Key? key}) : super(key: key);

  @override
  State<PlatePageView> createState() => _PlatePageViewState();
}

class _PlatePageViewState extends State<PlatePageView> {
  final String plakaStateEndPoint =
      'http://10.150.3.192/api/resource/Asset?fields=["plaka","custom_arac_durumu","asset_name"]';
  final String apiKey = '85a59e5b34ea388';
  final String apiSecret = '1adb799b673b287';
  late List<CarData> carDataList;
  late List<CarData> filteredCarDataList;
  late StreamController<List<CarData>> carDataStreamController;
  TextEditingController searchController = TextEditingController();
  bool isSearchBarOpen = false;
  String selectedStatus = ''; // Added to keep track of the selected status

  @override
  void initState() {
    super.initState();
    carDataList = [];
    filteredCarDataList = [];
    carDataStreamController = StreamController<List<CarData>>.broadcast();
    fetchData();
    searchController.addListener(onSearchChanged);
  }

  void onSearchChanged() {
    String searchTerm = searchController.text.toLowerCase();
    List<CarData> searchResults = [];

    if (searchTerm.isEmpty) {
      searchResults = List.from(carDataList);
    } else {
      for (var carData in carDataList) {
        if (carData.plate.toLowerCase().contains(searchTerm)) {
          searchResults.add(carData);
        }
      }
    }

    carDataStreamController.add(searchResults);
  }

  Future<void> fetchData() async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
    };

    final response = await http.get(
      Uri.parse(plakaStateEndPoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body)['data'] as List<dynamic>;
      final List<CarData> newDataList =
      jsonData.map((json) => CarData.fromJson(json)).toList();

      setState(() {
        carDataList = newDataList;
        // Filtering is done here
        filteredCarDataList = carDataList.where((carData) {
          return carData.plate.toLowerCase().contains(searchController.text.toLowerCase());
        }).toList();
      });

      carDataStreamController.add(filteredCarDataList);
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  Future<void> updatePlakaDurumu(String plaka, String yeniDurum) async {
    final String apiUrl =
        'http://10.150.3.192/api/resource/Asset?fields=["name","plaka","custom_arac_takip_alani","custom_arac_durumu","asset_category"]&filters=[["plaka","=","$plaka"]]';

    const String apiKey = '85a59e5b34ea388';
    const String apiSecret = '1adb799b673b287';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
    };

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(responseData['data']);

          if (data.isNotEmpty) {
            final Map<String, dynamic>? plakaEntry = data.firstWhere(
                  (entry) => entry['plaka'] == plaka,
            );

            if (plakaEntry != null) {
              plakaEntry['custom_arac_durumu'] = yeniDurum;
              final requestBody = {
                'plaka': plakaEntry['plaka'],
                'custom_arac_durumu': yeniDurum,
              };

              final updateUrl = 'http://10.150.3.192/api/resource/Asset/${plakaEntry['name']}';

              final updateResponse = await http.put(
                Uri.parse(updateUrl),
                headers: headers,
                body: jsonEncode(requestBody),
              );

              if (updateResponse.statusCode == 200) {
                BaseToastMessage.ToastSuccessMessage();
                print('Plaka durumu başarıyla güncellendi.');
                fetchData(); // Fetch data again and update the UI
              } else {
                BaseToastMessage.ToastFailedMessage();
                print('An error occurred while updating the plate status. Error: ${updateResponse.statusCode} ${updateResponse.reasonPhrase}');
              }
            }
          }
        }
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  void dispose() {
    carDataStreamController.close();
    searchController.dispose();
    super.dispose();
  }

  void updateStatusFilter(String newStatus) {
    setState(() {
      selectedStatus = newStatus;
    });

    fetchData(); // Fetch data based on the selected status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearchBarOpen
            ? TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Plaka girin...',
            hintStyle: TextStyle(color: Colors.black),
          ),
          style: TextStyle(color: Colors.black),
        )
            : Text('Car Data'),

        actions: [
          IconButton(
            icon: Icon(isSearchBarOpen ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearchBarOpen = !isSearchBarOpen;

                if (!isSearchBarOpen) {
                  onSearchChanged();
                  searchController.clear();
                }
              });
            },
          ),

          // Add the status filter buttons

          /*
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  onPressed: () {
                    updateStatusFilter('Müsait');
                  },
                  child: Text('Müsait'),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  onPressed: () {
                    updateStatusFilter('Dolu');
                  },
                  child: Text('Dolu'),
                ),
              ),
            ],
          ),


           */

        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CarData>>(
              stream: carDataStreamController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final carDataList = snapshot.data!;

                return ListView.builder(
                  itemCount: carDataList.length,
                  itemBuilder: (context, index) {
                    final CarData data = carDataList[index];

                    // Check if the status matches the selected filter
                    if (selectedStatus.isNotEmpty && data.status != selectedStatus) {
                      return Container(); // Skip rendering this item
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.grey.shade600,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('Plaka: ${data.assetName}', style: TextStyle(color: Colors.white)),
                              subtitle: Text('Durum: ${data.status}', style: TextStyle(color: Colors.white)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    updatePlakaDurumu(data.plate.toString(), "Müsait");
                                  },
                                  child: Text('Müsait', style: TextStyle(color: Colors.blue)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    updatePlakaDurumu(data.plate.toString(), "Dolu");
                                  },
                                  child: Text('Dolu', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
