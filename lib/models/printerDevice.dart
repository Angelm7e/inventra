class PrinterDevice {
  String id;
  String name;
  String type; // "network" | "bluetooth"
  String address; // IP o MAC
  int? port;

  PrinterDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    this.port = 9100,
  });

  factory PrinterDevice.fromMap(Map<String, dynamic> json) => PrinterDevice(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    address: json['address'],
    port: json['port'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'address': address,
    'port': port,
  };
}
