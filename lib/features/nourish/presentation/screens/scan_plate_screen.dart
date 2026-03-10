import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/app_colors.dart';
import '../../../../providers/ai_provider.dart';
import '../../../../providers/nutrition_provider.dart';

class ScanPlateScreen extends ConsumerStatefulWidget {
  const ScanPlateScreen({super.key});

  @override
  ConsumerState<ScanPlateScreen> createState() => _ScanPlateScreenState();
}

class _ScanPlateScreenState extends ConsumerState<ScanPlateScreen> {
  File? _image;
  bool _isAnalyzing = false;
  String? _error;

  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _error = null;
        });
        _analyzePlate();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = "Failed to pick image: $e");
      }
    }
  }

  Future<void> _analyzePlate() async {
    if (_image == null) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final bytes = await _image!.readAsBytes();
      final aiService = ref.read(aiServiceProvider);

      const prompt = """
      Analyze this food plate for a PCOS-focused nutrition app. 
      Identify the food items and estimate the nutritional information.
      Return ONLY a raw JSON object in this format (no markdown formatting):
      {
        "itemName": "Description of the meal",
        "calories": 450,
        "protein": 25.5,
        "carbs": 40.0,
        "fats": 15.0,
        "explanation": "Why this is good or bad for PCOS"
      }
      """;

      final response = await aiService.analyzeImage(bytes, prompt);
      
      // Clean up response if it has markdown code blocks
      String jsonStr = response.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7, jsonStr.length - 3);
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3, jsonStr.length - 3);
      } else if (jsonStr.contains('{') && jsonStr.contains('}')) {
        // Fallback: extract the JSON part if there's other text
        final start = jsonStr.indexOf('{');
        final end = jsonStr.lastIndexOf('}');
        if (start != -1 && end != -1) {
          jsonStr = jsonStr.substring(start, end + 1);
        }
      }

      final data = jsonDecode(jsonStr);
      
      if (!mounted) return;

      // Show results and confirm
      _showResultDialog(data);
    } catch (e) {
      if (mounted) {
        setState(() => _error = "Analysis failed. Please try again or log manually. Error: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showResultDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Analysis Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detected: ${data['itemName']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildMacroRow('Calories', '${data['calories']} kcal'),
            _buildMacroRow('Protein', '${data['protein']}g'),
            _buildMacroRow('Carbs', '${data['carbs']}g'),
            _buildMacroRow('Fats', '${data['fats']}g'),
            const SizedBox(height: 16),
            const Text('PCOS Insight:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(data['explanation'] ?? '', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(nutritionProvider.notifier).addCustomEntry(
                data['itemName'],
                (data['calories'] as num).toInt(),
                (data['protein'] as num).toDouble(),
                (data['carbs'] as num).toDouble(),
                (data['fats'] as num).toDouble(),
              );
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meal logged successfully!'), backgroundColor: AppColors.fertileGreen),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.nudeRose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm & Log'),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Plate', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Snap a photo of your meal for instant PCOS-context analysis.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: AppColors.mistySage.withOpacity(0.2)),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.nudeRose.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 48, color: AppColors.nudeRose),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Capture your plate',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'AI will identify the nutrients for you',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
              ),
            ),
            if (_isAnalyzing) ...[
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: AppColors.nudeRose),
              const SizedBox(height: 16),
              const Text('Zaya AI is analyzing your plate...', style: TextStyle(fontWeight: FontWeight.w500)),
              const Text('Identifying ingredients & macros', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
            if (_error != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!, 
                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (!_isAnalyzing)
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_rounded,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.mistySage.withOpacity(0.3)),
        ),
      ),
    );
  }
}
