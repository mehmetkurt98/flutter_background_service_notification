import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'model.dart';




class FrappeDataList extends StatefulWidget {
  @override
  _FrappeDataListState createState() => _FrappeDataListState();
}

class _FrappeDataListState extends State<FrappeDataList> {
  StreamController<List<String>> plakaStreamController = StreamController<List<String>>.broadcast();


  /*
  final String dataApiUrl =
      'http://10.150.3.192/api/resource/Arac%20Talep%20Formu?fields=["name", "employee_name","request_date","delivery_date","car_type","request_reason","mail","designation","phone_number","plate"]&limit_page_length=none';
   */
  String dataApiUrl ='http://10.150.3.192/api/resource/Arac%20Talep%20Formu?fields=["name", "employee_name","request_date","delivery_date","car_type","request_reason","mail","designation","phone_number","plate"]&limit_page_length=none&filters=[["plate","=",""]]';

  //final String plakaApiUrl = 'http://10.150.3.192/api/method/arac_takip.api.get_plates_based_on_events';
  final String plakaApiUrl = 'http://10.150.3.192/api/resource/Asset?fields=["plaka"]&filters=[["custom_arac_durumu","=","Müsait"]]';


  // plaka tablo end point http://10.150.3.192/api/resource/Asset?fields=["plaka","custom_arac_takip_alani","custom_arac_durumu","asset_category"]&filters=[["custom_arac_durumu","=","Müsait"]]



  final String apiKey = '85a59e5b34ea388';
  final String apiSecret = '1adb799b673b287';

  Stream<List<FrappeData>>? dataStream;
  List<String> plakaList = [];

  @override
  void initState() {
    super.initState();
    dataStream = fetchDataStream();
    fetchPlakaList();
  }

  Stream<List<FrappeData>> fetchDataStream() async* {

    while (true) {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
      };
      final response = await http.get(Uri.parse(dataApiUrl), headers: headers);

      if (response.statusCode == 200) {

        final jsonData = json.decode(response.body)['data'] as List<dynamic>;
        final dataListFromAPI =
        jsonData.map((json) => FrappeData.fromJson(json)).toList();

        yield dataListFromAPI;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }
  Future<void> fetchPlakaList() async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
    };

    final plakaResponse = await http.get(Uri.parse(plakaApiUrl), headers: headers);

    if (plakaResponse.statusCode == 200) {
      final jsonData = json.decode(plakaResponse.body) as Map<String, dynamic>;
      final data = jsonData['data'] as List<dynamic>;

      final plakaListFromAPI = data
          .whereType<Map<String, dynamic>>() // Verify the type of data
          .where((json) => json['custom_arac_durumu'] != "Dolu") // Exclude plates marked as "Dolu"
          .map((json) => json['plaka'] as String) // Get the plate information
          .toList();

      setState(() {
        plakaList = plakaListFromAPI;
        plakaStreamController.add(plakaList);

      });
    } else {
      // Handle the error situation
      print('Error code: ${plakaResponse.statusCode}');
      print('Error message: ${plakaResponse.reasonPhrase}');
    }
  }
  Future<void> saveSelectedPlaka(FrappeData data) async {
    final String saveApiUrl =
        'http://10.150.3.192/api/resource/Arac%20Talep%20Formu/${data.name}';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
    };

    final requestBody = {
      'plate': data.selectedPlaka,
    };

    final response = await http.put(
      Uri.parse(saveApiUrl),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      await updatePlakaDurumu(data.selectedPlaka.toString(), "Dolu");
      // Plaka atandıktan sonra plakaList'i güncelle
      await fetchPlakaList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Center(
            child: Text(
              'Plaka Ataması Başarılı.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      );
      setState(() {
        data.plate2 = data.selectedPlaka;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Center(
            child: Text(
              'Plaka güncellenirken bir hata oluştu. Hata: ${response.statusCode} ${response.reasonPhrase}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      );
    }
  }
  Future<void> updatePlakaDurumu(String plaka, String yeniDurum) async {
    final String apiUrl =
        'http://10.150.3.192/api/resource/Asset?fields=["name","plaka","custom_arac_takip_alani","custom_arac_durumu","asset_category"]&filters=[["plaka","=","$plaka"]]';

    final String apiKey = '85a59e5b34ea388';
    final String apiSecret = '1adb799b673b287';

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
            // Find the entry with the matching "plaka" value
            final Map<String, dynamic>? plakaEntry = data.firstWhere(
                  (entry) => entry['plaka'] == plaka,
            );

            if (plakaEntry != null) {
              // Update the "custom_arac_durumu" field
              plakaEntry['custom_arac_durumu'] = yeniDurum;

              // Prepare the updated request body
              final requestBody = {
                'plaka': plakaEntry['plaka'],
                'custom_arac_durumu': yeniDurum,
              };

              // Güncellenmiş veriye ait URL oluştur
              final updateUrl = 'http://10.150.3.192/api/resource/Asset/${plakaEntry['name']}';

              // Perform the update request
              final updateResponse = await http.put(
                Uri.parse(updateUrl),
                headers: headers,
                body: jsonEncode(requestBody),
              );

              if (updateResponse.statusCode == 200) {
                print('Plaka durumu başarıyla güncellendi.');
              } else {
                print('Plaka durumu güncellenirken bir hata oluştu. Hata: ${updateResponse.statusCode} ${updateResponse.reasonPhrase}');
              }
            }
          }
        }
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
  }





  Future<void> _refreshData() async {
    await fetchDataStream();
    await fetchPlakaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('FRAPPE ARAÇ TALEP LİSTESİ'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: StreamBuilder<List<FrappeData>>(
          stream: dataStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final dataList = snapshot.data!;

            return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (BuildContext context, int index) {
                final FrappeData data = dataList[index];
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
                    color: Colors.grey.shade600,
                    child: ExpansionTile(
                      title: ListTile(
                          title: Text(
                            'Document No: ${data.name}',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),

                          subtitle: Text("Çalışan Adı: ${data.employeeName}",style: TextStyle(color: Colors.white, fontSize: 15),)
                      ),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 5,),
                            Text('         Talep Tarihi: ${data.requestDate}', style: TextStyle(color: Colors.white, fontSize: 15),),
                            SizedBox(height: 5,),
                            Text('         Teslim Tarihi: ${data.deliveryDate}', style: TextStyle(color: Colors.white, fontSize: 15),),
                            SizedBox(height: 5,),
                            Text('         Araç Türü: ${data.carType}', style: TextStyle(color: Colors.white, fontSize: 15),),
                            SizedBox(height: 5,),
                            Text('         Mail: ${data.mail}', style: TextStyle(color: Colors.white, fontSize: 15,),),
                            SizedBox(height: 5,),
                            Text('         Ünvan: ${data.designation}', style: TextStyle(color: Colors.white, fontSize: 15),),
                            SizedBox(height: 5,),
                            Text('         Telefon Numarası: ${data.phoneNumber}', style: TextStyle(color: Colors.white, fontSize: 15),),
                            SizedBox(height: 5,),
                            Text('         Taleb Nedeni: ${data.requestReason}', style: TextStyle(color: Colors.white, fontSize: 15),),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Center(child: Text('Lütfen Plaka Seçin')),
                                          content: StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setState) {
                                              return DropdownButton<String>(
                                                value: data.selectedPlaka ?? null,
                                                hint: Text('Plaka Listesi', style: TextStyle(fontWeight: FontWeight.bold)),
                                                items: plakaList.map((String plaka) {
                                                  return DropdownMenuItem<String>(
                                                    value: plaka,
                                                    child: Text(plaka),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    data.selectedPlaka = newValue;
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                if (data.selectedPlaka != null) {
                                                  data.plate2 = data.selectedPlaka;
                                                  saveSelectedPlaka(data);
                                                  // Bu satırdaki setState, StatefulBuilder içindeki setState'i çağırarak tüm builder'ı günceller.
                                                  Navigator.of(context).pop();
                                                } else {
                                                  // Show a warning message here
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor: Colors.red,
                                                      content: Center(
                                                        child: Text(
                                                          'Plaka seçilmedi! Lütfen bir plaka seçin.',
                                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Text('Tamam'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(primary: Colors.green),
                                  child: Text('Kabul Et', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),),
                                ),
                                SizedBox(width: 40,),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      dataList.removeAt(index);
                                    });
                                    // You can add additional logic here for rejecting the request if needed
                                  },
                                  style: ElevatedButton.styleFrom(primary: Colors.red),
                                  child: Text('Reddet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white,),),
                                ),
                              ],
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
    );
  }
}

