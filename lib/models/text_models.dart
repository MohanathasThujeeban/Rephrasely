class TextRequest {
  final String text;
  final int? maxLength;
  final int? minLength;
  final int? variations;

  const TextRequest({
    required this.text,
    this.maxLength,
    this.minLength,
    this.variations,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (maxLength != null) 'max_length': maxLength,
      if (minLength != null) 'min_length': minLength,
      if (variations != null) 'variations': variations,
    };
  }

  factory TextRequest.fromJson(Map<String, dynamic> json) {
    return TextRequest(
      text: json['text'] ?? '',
      maxLength: json['max_length'],
      minLength: json['min_length'],
      variations: json['variations'],
    );
  }
}

class TextResponse {
  final bool success;
  final String? originalText;
  final String? processedText;
  final double? processingTime;
  final int? wordCountOriginal;
  final int? wordCountProcessed;
  final double? compressionRatio;
  final List<String>? variations;
  final String? error;

  const TextResponse({
    required this.success,
    this.originalText,
    this.processedText,
    this.processingTime,
    this.wordCountOriginal,
    this.wordCountProcessed,
    this.compressionRatio,
    this.variations,
    this.error,
  });

  factory TextResponse.fromJson(Map<String, dynamic> json) {
    return TextResponse(
      success: json['success'] ?? false,
      originalText: json['original_text'],
      processedText: json['processed_text'],
      processingTime: json['processing_time']?.toDouble(),
      wordCountOriginal: json['word_count_original'],
      wordCountProcessed: json['word_count_processed'],
      compressionRatio: json['compression_ratio']?.toDouble(),
      variations: json['variations'] != null 
          ? List<String>.from(json['variations'])
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (originalText != null) 'original_text': originalText,
      if (processedText != null) 'processed_text': processedText,
      if (processingTime != null) 'processing_time': processingTime,
      if (wordCountOriginal != null) 'word_count_original': wordCountOriginal,
      if (wordCountProcessed != null) 'word_count_processed': wordCountProcessed,
      if (compressionRatio != null) 'compression_ratio': compressionRatio,
      if (variations != null) 'variations': variations,
      if (error != null) 'error': error,
    };
  }
}