import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/text_models.dart';
import '../services/text_processing_service.dart';

class ParaphraseScreen extends StatefulWidget {
  const ParaphraseScreen({super.key});

  @override
  State<ParaphraseScreen> createState() => _ParaphraseScreenState();
}

class _ParaphraseScreenState extends State<ParaphraseScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextProcessingService _textService = TextProcessingService();
  
  bool _isLoading = false;
  TextResponse? _result;
  String? _error;
  
  // Paraphrase options
  int _variations = 1;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _paraphraseText() async {
    if (_textController.text.trim().isEmpty) {
      _showError('Please enter some text to paraphrase');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    final request = TextRequest(
      text: _textController.text.trim(),
      variations: _variations,
    );

    final response = await _textService.paraphraseText(request);

    setState(() {
      _isLoading = false;
      if (response.success) {
        _result = response;
      } else {
        _error = response.error;
      }
    });
  }

  void _showError(String message) {
    setState(() {
      _error = message;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _clearAll() {
    setState(() {
      _textController.clear();
      _result = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paraphrase Text'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                // Input Section
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.largeBorderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.edit_note, color: AppColors.secondary),
                              const SizedBox(width: AppSizes.sm),
                              Text(
                                'Input Text',
                                style: AppTextStyles.heading3,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: 'Enter the text you want to paraphrase...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                                  borderSide: BorderSide(color: AppColors.secondary, width: 2),
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            'Characters: ${_textController.text.length} | Words: ${_textController.text.split(' ').where((word) => word.isNotEmpty).length}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Options Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.largeBorderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings, color: AppColors.secondary),
                            const SizedBox(width: AppSizes.sm),
                            Text(
                              'Paraphrase Options',
                              style: AppTextStyles.heading3,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Number of Variations: $_variations', style: AppTextStyles.bodySmall),
                                  Slider(
                                    value: _variations.toDouble(),
                                    min: 1,
                                    max: 3,
                                    divisions: 2,
                                    onChanged: (value) {
                                      setState(() {
                                        _variations = value.round();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'More variations will provide different ways to express the same content.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _paraphraseText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.largeBorderRadius),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.edit_note),
                              const SizedBox(width: AppSizes.sm),
                              const Text('Paraphrase Text'),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Error Section
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            _error!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Result Section
                if (_result != null && _result!.success)
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.largeBorderRadius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: AppSizes.sm),
                                Text(
                                  'Paraphrase Result',
                                  style: AppTextStyles.heading3,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Main paraphrase
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(AppSizes.sm),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Primary Paraphrase',
                                                style: AppTextStyles.bodyMedium.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () => _copyToClipboard(_result!.processedText!),
                                                icon: const Icon(Icons.copy, size: 20),
                                                tooltip: 'Copy paraphrase',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: AppSizes.sm),
                                          Text(
                                            _result!.processedText!,
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Variations if available
                                    if (_result!.variations != null && _result!.variations!.isNotEmpty) ...[
                                      const SizedBox(height: AppSizes.md),
                                      Text(
                                        'Alternative Variations',
                                        style: AppTextStyles.heading3.copyWith(fontSize: 16),
                                      ),
                                      const SizedBox(height: AppSizes.sm),
                                      ..._result!.variations!.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final variation = entry.value;
                                        return Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: AppSizes.sm),
                                          padding: const EdgeInsets.all(AppSizes.sm),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                                            border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Variation ${index + 1}',
                                                    style: AppTextStyles.bodySmall.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.secondary,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  IconButton(
                                                    onPressed: () => _copyToClipboard(variation),
                                                    icon: const Icon(Icons.copy, size: 18),
                                                    tooltip: 'Copy variation',
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                variation,
                                                style: AppTextStyles.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCard(
                                  'Original',
                                  '${_result!.wordCountOriginal} words',
                                  Icons.article,
                                ),
                                _buildStatCard(
                                  'Paraphrase',
                                  '${_result!.wordCountProcessed} words',
                                  Icons.edit_note,
                                ),
                                _buildStatCard(
                                  'Time',
                                  '${_result!.processingTime?.toStringAsFixed(2)}s',
                                  Icons.timer,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}