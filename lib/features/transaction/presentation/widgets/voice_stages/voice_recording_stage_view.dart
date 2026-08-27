import 'package:flutter/material.dart';
import '../../../../../../core/constants/colors.dart';

class VoiceRecordingStageView extends StatelessWidget {
  final bool isListening;
  final bool isProcessing;
  final String text;
  final VoidCallback onListenTap;

  const VoiceRecordingStageView({
    super.key,
    required this.isListening,
    required this.isProcessing,
    required this.text,
    required this.onListenTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            isProcessing ? 'Memproses suaramu...' : 'Voice Assistant',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 100,
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isListening ? accentColor : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        isProcessing
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Center(
                child: GestureDetector(
                  onTap: onListenTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isListening ? 90 : 70,
                    height: isListening ? 90 : 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening ? Colors.redAccent : accentColor,
                      boxShadow: [
                        if (isListening)
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                      ],
                    ),
                    child: Icon(
                      isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: isListening ? 40 : 32,
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            isListening
                ? 'Ketuk untuk berhenti manual'
                : 'Contoh: "Beli bakso 20 ribu" atau "Dapat gaji 5 juta"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
