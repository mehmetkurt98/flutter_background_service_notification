class FrappeData { //bu model yeterli diğeri plakanın modeli o yüzden sildim tamamdır
  final String employeeName;
  final String requestDate;
  final String deliveryDate;
  final String carType;
  final String mail;
  final String designation;
  final String phoneNumber;
  final String name;
  final String plate;
  final String requestReason;
  String? selectedPlaka;
  String? plate2;

  FrappeData({
    required this.employeeName,
    required this.requestDate,
    required this.requestReason,

    required this.deliveryDate,
    required this.carType,
    required this.mail,
    required this.designation,
    required this.phoneNumber,
    required this.name,
    required this.plate,
    this.selectedPlaka,
    this.plate2,
  });

  factory FrappeData.fromJson(Map<String, dynamic> json) {
    return FrappeData(
      employeeName: json['employee_name'] ?? 'Bilinmiyor',
      requestDate: json['request_date'] ?? 'Bilinmiyor',
      deliveryDate: json['delivery_date'] ?? 'Bilinmiyor',
      carType: json['car_type'] ?? 'Bilinmiyor',
      mail: json['mail'] ?? 'Bilinmiyor',
      designation: json['designation'] ?? 'Bilinmiyor',
      phoneNumber: json['phone_number'] ?? 'Bilinmiyor',
      name: json['name'] ?? 'Bilinmiyor',
      plate: json['plate'] ?? 'Atama Yapılmadı',
      requestReason: json['request_reason'] ?? 'Atama Yapılmadı',

    );
  }
}
class CarData {
  final String plate;
  final String status;
  final String assetName;


  CarData({required this.plate, required this.status,required this.assetName});

  factory CarData.fromJson(Map<String, dynamic> json) {
    return CarData(
      plate: json['plaka'] ?? 'Bilinmiyor',
      status: json['custom_arac_durumu'] ?? 'Bilinmiyor',
      assetName: json["asset_name"] ??'Bilinmiyor',
    );
  }
}


