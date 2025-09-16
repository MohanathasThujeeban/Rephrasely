import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/text_models.dart';
import '../services/text_processing_service.dart';

class SummarizeScreen extends StatefulWidget {
  const SummarizeScreen({super.key});

  @override
  State<SummarizeScreen> createState() => _SummarizeScreenState();
}

class _SummarizeScreenState extends State<SummarizeScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextProcessingService _textService = TextProcessingService();
  
  bool _isLoading = false;
  TextResponse? _result;
  String? _error;
  
  // Summary options
  int _maxLength = 150;
  int _minLength = 50;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _summarizeText() async {
    if (_textController.text.trim().isEmpty) {
      _showError('Please enter some text to summarize');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    final request = TextRequest(
      text: _textController.text.trim(),
      maxLength: _maxLength,
      minLength: _minLength,
    );

    final response = await _textService.summarizeText(request);

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
        title: const Text('Summarize Text'),
        backgroundColor: AppColors.primary,
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
                              Icon(Icons.edit_note, color: AppColors.primary),
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
                                hintText: 'Enter the text you want to summarize...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                                  borderSide: BorderSide(color: AppColors.primary, width: 2),
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
                              'Summary Options',
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
                                  Text('Min Length: $_minLength words', style: AppTextStyles.bodySmall),
                                  Slider(
                                    value: _minLength.toDouble(),
                                    min: 20,
                                    max: 100,
                                    divisions: 8,
                                    onChanged: (value) {
                                      setState(() {
                                        _minLength = value.round();
                                        if (_minLength >= _maxLength) {
                                          _maxLength = _minLength + 50;
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Max Length: $_maxLength words', style: AppTextStyles.bodySmall),
                                  Slider(
                                    value: _maxLength.toDouble(),
                                    min: 50,
                                    max: 300,
                                    divisions: 10,
                                    onChanged: (value) {
                                      setState(() {
                                        _maxLength = value.round();
                                        if (_maxLength <= _minLength) {
                                          _minLength = _maxLength - 30;
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                    onPressed: _isLoading ? null : _summarizeText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                              const Icon(Icons.summarize),
                              const SizedBox(width: AppSizes.sm),
                              const Text('Summarize Text'),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Result Section
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
                                  'Summary Result',
                                  style: AppTextStyles.heading3,
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => _copyToClipboard(_result!.processedText!),
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'Copy summary',
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSizes.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    _result!.processedText!,
                                    style: AppTextStyles.bodyMedium,
                                  ),
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
                                  'Summary',
                                  '${_result!.wordCountProcessed} words',
                                  Icons.summarize,
                                ),
                                _buildStatCard(
                                  'Compression',
                                  '${(_result!.compressionRatio! * 100).toStringAsFixed(1)}%',
                                  Icons.compress,
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
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
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