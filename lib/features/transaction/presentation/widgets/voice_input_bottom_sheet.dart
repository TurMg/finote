import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/top_snackbar.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_event.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../../category/presentation/widgets/form_kategori_bottom_sheet.dart';
import '../../domain/entities/voice_parsed_data.dart';
import '../../domain/usecases/parse_voice_input.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import 'voice_stages/voice_recording_stage_view.dart';
import 'voice_stages/voice_confirmation_stage_view.dart';

class VoiceInputBottomSheet extends StatefulWidget {
  const VoiceInputBottomSheet({super.key});

  @override
  State<VoiceInputBottomSheet> createState() => _VoiceInputBottomSheetState();
}

class _VoiceInputBottomSheetState extends State<VoiceInputBottomSheet> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isProcessing = false;
  String _text = 'Ketuk mic untuk mulai merekam';
  bool _isInitialized = false;
  String _localeId = '';

  // Data hasil parsing jika sudah selesai diproses
  VoiceParsedData? _parsedData;

  // Controllers untuk tahap konfirmasi
  late TextEditingController _nominalController;
  late FocusNode _nominalFocusNode;
  late TextEditingController _noteController;
  late String _selectedType;
  late String _selectedCategory;

  final _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);

  // Controller untuk resize DraggableScrollableSheet secara programatik
  final _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _nominalController = TextEditingController();
    _nominalFocusNode = FocusNode();
    _noteController = TextEditingController();
    _selectedType = 'EXPENSE';
    _selectedCategory = '';

    _speech = stt.SpeechToText();
    _initSpeech();
  }

  @override
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
    _nominalController.dispose();
    _nominalFocusNode.dispose();
    _noteController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _stopListeningAndProcess();
        }
      },
      onError: (errorNotification) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _text = 'Gagal mendengar: ${errorNotification.errorMsg}';
          });
        }
      },
    );

    if (_isInitialized && mounted) {
      var systemLocales = await _speech.locales();
      try {
        var indoLocale = systemLocales.firstWhere(
          (loc) =>
              loc.localeId.toLowerCase() == 'id_id' ||
              loc.localeId.toLowerCase() == 'id-id',
        );
        _localeId = indoLocale.localeId;
      } catch (e) {
        debugPrint("🚨 [WARNING]: HP ini tidak memiliki kamus Bahasa Indonesia!");
      }

      // Menghapus auto-listen untuk mencegah race condition dan cold start
    }
  }

  void _listen() async {
    if (!_isInitialized) {
      if (mounted) {
        TopSnackBar.show(
          context,
          message: 'Sistem pengenal suara belum siap atau izin ditolak.',
          type: TopSnackBarType.error,
        );
      }
      return;
    }

    if (!_isListening) {
      if (mounted) {
        setState(() {
          _isListening = true;
          _isProcessing = false;
          _parsedData = null;
          _text = 'Mendengarkan...';
        });
      }
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _text = result.recognizedWords;
            });
          }
        },
        localeId: _localeId.isNotEmpty ? _localeId : null,
        pauseFor: const Duration(seconds: 5), // Menunggu jeda 5 detik
        listenFor: const Duration(seconds: 30), // Max durasi rekaman 30 detik
        listenMode: stt.ListenMode.dictation,
      );
    } else {
      _stopListeningAndProcess();
    }
  }

  void _stopListeningAndProcess() async {
    if (_isProcessing || _parsedData != null) return;

    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
    }

    // Jeda 800ms agar onResult sempat memberikan hasil akhir string yang terpotong
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    if (_text.trim().isEmpty ||
        _text == 'Mendengarkan...' ||
        _text.contains('Tekan tombol') ||
        _text == 'Ketuk mic untuk mulai merekam') {
      TopSnackBar.show(
        context,
        message: 'Suara belum terdengar jelas. Silakan ketuk mic dan bicara lagi.',
        type: TopSnackBarType.info,
      );
      return;
    }

    setState(() => _isProcessing = true);

    List<Category> categories = [];
    final catState = context.read<CategoryBloc>().state;
    if (catState is CategoryLoaded) {
      categories = catState.categories;
    }

    final parser = ParseVoiceInput();
    final result = await parser.execute(_text, categories: categories);

    if (!mounted) return;

    // Masuk ke fase konfirmasi
    setState(() {
      _isProcessing = false;
      _parsedData = result;
      _selectedType = result.type;
      _selectedCategory = result.category;
      _noteController.text = result.note;

      final initialNominalInt = result.nominal.toInt();
      _nominalController.text =
          initialNominalInt > 0 ? _currencyFormat.format(initialNominalInt) : '';
    });

    // Animasikan sheet naik ke 75% layar saat masuk konfirmasi
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.75,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  double _getCleanNominal() {
    final cleanStr = _nominalController.text.replaceAll('.', '').trim();
    return double.tryParse(cleanStr) ?? 0.0;
  }

  void _onNominalChanged(String val) {
    final cleanStr = val.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanStr.isEmpty) {
      _nominalController.value = const TextEditingValue(text: '');
      return;
    }

    final doubleVal = double.tryParse(cleanStr) ?? 0.0;
    final formatted = _currencyFormat.format(doubleVal.toInt());

    _nominalController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _onSaveTransaction() {
    final nominal = _getCleanNominal();
    if (nominal <= 0) {
      TopSnackBar.show(
        context,
        message: 'Nominal transaksi tidak boleh kosong atau 0',
        type: TopSnackBarType.error,
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      TopSnackBar.show(
        context,
        message: 'Pilih kategori transaksi terlebih dahulu',
        type: TopSnackBarType.error,
      );
      return;
    }

    context.read<TransactionBloc>().add(
          ManualInputSaved(
            nominal: nominal,
            category: _selectedCategory,
            date: DateTime.now(),
            note: _noteController.text.trim().isEmpty ? _text : _noteController.text.trim(),
            inputSource: 'VOICE',
            type: _selectedType,
          ),
        );
    context.read<HistoryBloc>().add(LoadHistory());

    TopSnackBar.show(
      context,
      message: 'Transaksi dari suara berhasil disimpan!',
      type: TopSnackBarType.success,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isConfirmation = _parsedData != null;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: isConfirmation ? 0.78 : 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 12,
                left: 24,
                right: 24,
              ),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                if (!isConfirmation)
                  VoiceRecordingStageView(
                    isListening: _isListening,
                    isProcessing: _isProcessing,
                    text: _text,
                    onListenTap: _listen,
                  )
                else
                  VoiceConfirmationStageView(
                    text: _text,
                    selectedType: _selectedType,
                    onTypeChanged: (newType) {
                      if (_selectedType != newType) {
                        setState(() {
                          _selectedType = newType;
                          _selectedCategory = '';
                        });
                      }
                    },
                    nominalController: _nominalController,
                    nominalFocusNode: _nominalFocusNode,
                    onNominalChanged: _onNominalChanged,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    onAddCategory: _showAddCategorySheet,
                    noteController: _noteController,
                    onSaveTransaction: _onSaveTransaction,
                    onRetryVoice: _listen,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Buka FormKategoriBottomSheet dan auto-select kategori baru.
  void _showAddCategorySheet() async {
    final catState = context.read<CategoryBloc>().state;
    final allCategories = catState is CategoryLoaded ? catState.categories : <Category>[];

    final result = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormKategoriBottomSheet(
        allCategories: allCategories,
        defaultType: _selectedType,
      ),
    );

    if (result != null && mounted) {
      context.read<CategoryBloc>().add(AddCategory(result));
      setState(() {
        _selectedCategory = result.name;
      });
    }
  }
}
