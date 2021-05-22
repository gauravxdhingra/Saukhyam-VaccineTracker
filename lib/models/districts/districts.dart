/// districts : [{"district_id":141,"district_name":"Central Delhi"},{"district_id":145,"district_name":"East Delhi"},{"district_id":140,"district_name":"New Delhi"},{"district_id":146,"district_name":"North Delhi"},{"district_id":147,"district_name":"North East Delhi"},{"district_id":143,"district_name":"North West Delhi"},{"district_id":148,"district_name":"Shahdara"},{"district_id":149,"district_name":"South Delhi"},{"district_id":144,"district_name":"South East Delhi"},{"district_id":150,"district_name":"South West Delhi"},{"district_id":142,"district_name":"West Delhi"}]
/// ttl : 24

class Districts {
  List<District>? _districts;
  int? _ttl;

  List<District>? get districts => _districts;
  int? get ttl => _ttl;

  Districts({List<District>? districts, int? ttl}) {
    _districts = districts;
    _ttl = ttl;
  }

  Districts.fromJson(dynamic json) {
    if (json["districts"] != null) {
      _districts = [];
      json["districts"].forEach((v) {
        _districts?.add(District.fromJson(v));
      });
    }
    _ttl = json["ttl"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_districts != null) {
      map["districts"] = _districts?.map((v) => v.toJson()).toList();
    }
    map["ttl"] = _ttl;
    return map;
  }
}

/// district_id : 141
/// district_name : "Central Delhi"

class District {
  int? _districtId;
  String? _districtName;

  int? get districtId => _districtId;
  String? get districtName => _districtName;

  District({int? districtId, String? districtName}) {
    _districtId = districtId;
    _districtName = districtName;
  }

  District.fromJson(dynamic json) {
    _districtId = json["district_id"];
    _districtName = json["district_name"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["district_id"] = _districtId;
    map["district_name"] = _districtName;
    return map;
  }
}

//
// {
// "districts": [
// {
// "district_id": 141,
// "district_name": "Central Delhi"
// },
// {
// "district_id": 145,
// "district_name": "East Delhi"
// },
// {
// "district_id": 140,
// "district_name": "New Delhi"
// },
// {
// "district_id": 146,
// "district_name": "North Delhi"
// },
// {
// "district_id": 147,
// "district_name": "North East Delhi"
// },
// {
// "district_id": 143,
// "district_name": "North West Delhi"
// },
// {
// "district_id": 148,
// "district_name": "Shahdara"
// },
// {
// "district_id": 149,
// "district_name": "South Delhi"
// },
// {
// "district_id": 144,
// "district_name": "South East Delhi"
// },
// {
// "district_id": 150,
// "district_name": "South West Delhi"
// },
// {
// "district_id": 142,
// "district_name": "West Delhi"
// }
// ],
// "ttl": 24
// }
