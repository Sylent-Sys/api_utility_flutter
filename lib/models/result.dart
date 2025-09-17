class ApiResult {
  final String status;
  final Map<String, dynamic>? response;
  final Map<String, dynamic>? dataGagal;
  final String? pesanErrorSistem;
  final String? pesanErrorAPI;

  const ApiResult({
    required this.status,
    this.response,
    this.dataGagal,
    this.pesanErrorSistem,
    this.pesanErrorAPI,
  });

  factory ApiResult.success(Map<String, dynamic> response) {
    return ApiResult(
      status: 'success',
      response: response,
    );
  }

  factory ApiResult.error({
    required Map<String, dynamic> dataGagal,
    required String pesanErrorSistem,
    String? pesanErrorAPI,
  }) {
    return ApiResult(
      status: 'error',
      dataGagal: dataGagal,
      pesanErrorSistem: pesanErrorSistem,
      pesanErrorAPI: pesanErrorAPI,
    );
  }

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (response != null) 'response': response,
      if (dataGagal != null) 'data_gagal': dataGagal,
      if (pesanErrorSistem != null) 'pesan_error_sistem': pesanErrorSistem,
      if (pesanErrorAPI != null) 'pesan_error_api': pesanErrorAPI,
    };
  }

  factory ApiResult.fromJson(Map<String, dynamic> json) {
    return ApiResult(
      status: json['status'] ?? '',
      response: json['response'] as Map<String, dynamic>?,
      dataGagal: json['data_gagal'] as Map<String, dynamic>?,
      pesanErrorSistem: json['pesan_error_sistem'] as String?,
      pesanErrorAPI: json['pesan_error_api'] as String?,
    );
  }
}
