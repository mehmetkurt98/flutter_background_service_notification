import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'model.dart';





class LateRezervationPage extends StatefulWidget {
  @override
  _LateRezervationPageState createState() => _LateRezervationPageState();
}
class _LateRezervationPageState extends State<LateRezervationPage> {
  String dataApiUrl =
      'http://10.150.3.192/api/resource/Arac%20Talep%20Formu?fields=["name", "employee_name","request_date","delivery_date","car_type","request_reason","mail","designation","phone_number","plate"]&limit_page_length=none&filters=[["plate","!=",""]]';
  final String plakaApiUrl =
      'http://10.150.3.192/api/resource/Asset?fields=["plaka"]&filters=[["custom_arac_durumu","=","Müsait"]]';

  final String apiKey = '85a59e5b34ea388';
  final String apiSecret = '1adb799b673b287';

  Stream<List<FrappeData>>? dataStream;
  List<String> plakaList = [];
  String searchText = '';

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
      await Future.delayed(const Duration(seconds: 1));
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
          .whereType<Map<String, dynamic>>() // Verilerin tipini doğrula
          .map((json) => json['plaka'] as String) // Plaka bilgisini al
          .toList();

      setState(() {
        plakaList = plakaListFromAPI;
      });
    } else {
      // Hata durumunu işleyin
      print('Hata kodu: ${plakaResponse.statusCode}');
      print('Hata mesajı: ${plakaResponse.reasonPhrase}');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Center(
            child: Text(
              'Plaka başarıyla güncellendi.',
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
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      );
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
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Ara...',
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: StreamBuilder<List<FrappeData>>(
          stream: dataStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final dataList = snapshot.data!;

            return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (BuildContext context, int index) {
                final FrappeData data = dataList[index];

                // Arama kriterlerini kontrol et
                final bool isSearchMatch = data.employeeName.toLowerCase().contains(searchText.toLowerCase()) ||
                    data.requestDate.toLowerCase().contains(searchText.toLowerCase()) ||
                    data.deliveryDate.toLowerCase().contains(searchText.toLowerCase()) ||
                    data.carType.toLowerCase().contains(searchText.toLowerCase()) ||
                    data.mail.toLowerCase().contains(searchText.toLowerCase()) ||
                    data.designation.toLowerCase().contains(searchText.toLowerCase()) ||
                    data.phoneNumber.toLowerCase().contains(searchText.toLowerCase()) ||
                    data.name.toLowerCase().contains(searchText.toLowerCase()) ||
                    data.plate.toLowerCase().contains(searchText.toLowerCase());

                // Eğer arama kriterlerini karşılamıyorsa bu öğeyi gösterme
                if (!isSearchMatch) {
                  return Container();
                }



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
                            Text('         Plaka: ${data.plate}', style: TextStyle(color: Colors.white, fontSize: 15),),
                            SizedBox(height: 10),

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