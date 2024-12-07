class CameraModel {
  final String id;
  final String lat;
  final String lng;
  final String name;
  final String url;

  CameraModel(this.id, this.lat, this.lng, this.name, this.url);

  //source: https://docs.flutter.dev/data-and-backend/serialization/json#serializing-json-inside-model-classes
  CameraModel.fromJSON(Map<String, dynamic> json)
      : id = json['id'] as String,
        lat = json['lat'] as String,
        lng = json['lng'] as String,
        name = json['name'] as String,
        url = json['url'] as String;
}
