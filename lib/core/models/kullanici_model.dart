class KullaniciModel {
  final String id;
  final String isim;
  final String rol; // 'yasli' veya 'akraba'
  final String eslesmeKodu;

  KullaniciModel({
    required this.id,
    required this.isim,
    required this.rol,
    required this.eslesmeKodu,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isim': isim,
      'rol': rol,
      'eslesmeKodu': eslesmeKodu,
    };
  }

  factory KullaniciModel.fromMap(Map<String, dynamic> map) {
    return KullaniciModel(
      id: map['id'] ?? '',
      isim: map['isim'] ?? '',
      rol: map['rol'] ?? '',
      eslesmeKodu: map['eslesmeKodu'] ?? '',
    );
  }
}