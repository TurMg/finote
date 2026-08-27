// features/category/presentation/widgets/form_kategori_bottom_sheet.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/category_keyword_helper.dart';
import '../../../../core/utils/color_history_manager.dart';
import '../../../../core/utils/icon_resolver.dart';
import '../../../../core/widgets/category_icon_widget.dart';
import '../../../../core/widgets/shake_widget.dart';
import '../../domain/entities/category.dart';

/// Bottom sheet untuk tambah atau edit kategori dengan dukungan Vector, Emoji, & Gambar Custom
class FormKategoriBottomSheet extends StatefulWidget {
  final Category? existingCategory; // null = tambah baru, non-null = edit
  final List<Category> allCategories;
  final String? defaultType;

  const FormKategoriBottomSheet({
    super.key,
    this.existingCategory,
    required this.allCategories,
    this.defaultType,
  });

  @override
  State<FormKategoriBottomSheet> createState() =>
      _FormKategoriBottomSheetState();
}

class _FormKategoriBottomSheetState extends State<FormKategoriBottomSheet> {
  final _nameController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _emojiController = TextEditingController();

  late final ValueNotifier<String> _selectedIconNotifier;
  Color? _selectedColor;
  late String _selectedType; // 'EXPENSE' or 'INCOME'

  // Tab Mode Pemilihan Icon: 0 = Vector Icon, 1 = Emoji, 2 = Upload Gambar
  int _iconTabMode = 0;
  String? _customImagePath;

  List<int> _colorHistory = [];
  bool _isLoadingHistory = true;

  bool _shakeName = false;
  String? _nameError;

  bool _shakeKeywords = false;
  String? _keywordsError;
  bool _isKeywordsManuallyEdited = false;

  // Presets Emoji Populer
  static const List<String> _emojiPresets = [
    '🍕', '🍔', '☕', '🎮', '🚗', '✈️', '🎁', '💰', '💼', '🎓',
    '💊', '⚽', '🐱', '📱', '🛒', '🍿', '📚', '🏠', '💵', '🎟️',
    '🩺', '💄', '⚡', '🏋️', '🎨', '✈️', '🐾', '🏖️', '🍺', '🛍️'
  ];

  bool get isEditing => widget.existingCategory != null;

  @override
  void initState() {
    super.initState();
    String initialIcon = 'shopping_bag_rounded';

    if (isEditing) {
      final cat = widget.existingCategory!;
      _nameController.text = cat.name;
      _keywordsController.text = cat.keywords.join(', ');
      _isKeywordsManuallyEdited = true;
      initialIcon = cat.iconName;
      _selectedType = cat.type == 'BOTH' ? 'EXPENSE' : cat.type;
      _selectedColor = Color(cat.colorValue);

      if (initialIcon.startsWith('emoji:')) {
        _iconTabMode = 1;
        _emojiController.text = initialIcon.substring(6);
      } else if (initialIcon.startsWith('image:')) {
        _iconTabMode = 2;
        _customImagePath = initialIcon.substring(6);
      } else {
        _iconTabMode = 0;
      }
    } else {
      _selectedType = widget.defaultType ?? 'EXPENSE';
    }

    _nameController.addListener(_onNameChanged);
    _selectedIconNotifier = ValueNotifier<String>(initialIcon);
    _loadHistory();
  }

  void _onNameChanged() {
    if (!_isKeywordsManuallyEdited) {
      final suggested =
          CategoryKeywordHelper.getSuggestedKeywords(_nameController.text);
      _keywordsController.text = suggested;
    }
  }

  Future<void> _loadHistory() async {
    final history = await ColorHistoryManager.getHistory();
    if (mounted) {
      setState(() {
        _colorHistory = history;
        _isLoadingHistory = false;
        if (!isEditing && _selectedColor == null) {
          _selectedColor = Color(history.first);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _keywordsController.dispose();
    _emojiController.dispose();
    _selectedIconNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/category_images');
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        final fileName = 'cat_${DateTime.now().millisecondsSinceEpoch}.png';
        final savedImage =
            await File(pickedFile.path).copy('${imagesDir.path}/$fileName');

        setState(() {
          _customImagePath = savedImage.path;
        });
        _selectedIconNotifier.value = 'image:${savedImage.path}';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                isEditing ? 'Edit Kategori' : 'Tambah Kategori',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Peruntukan Tipe Kategori
              const Text(
                'Tipe Kategori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeOption(
                    label: 'Pengeluaran',
                    typeKey: 'EXPENSE',
                    activeColor: AppColors.expenseRed,
                  ),
                  const SizedBox(width: 8),
                  _buildTypeOption(
                    label: 'Pemasukan',
                    typeKey: 'INCOME',
                    activeColor: AppColors.incomeGreen,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Nama Kategori
              const Text(
                'Nama Kategori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ShakeWidget(
                shake: _shakeName,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (val) {
                        if (_nameError != null) {
                          setState(() {
                            _nameError = null;
                            _shakeName = false;
                          });
                        }
                      },
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: _selectedType == 'INCOME'
                            ? 'Contoh: Gaji, Bonus, Dividen'
                            : 'Contoh: Belanja, Makanan, Transport',
                        hintStyle: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSubtle,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.cardBorder.withOpacity(0.5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.cardBorder.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    if (_nameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          _nameError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Preview Icon & Warna
              Center(
                child: ValueListenableBuilder<String>(
                  valueListenable: _selectedIconNotifier,
                  builder: (context, currentIcon, _) {
                    final activeColor = _selectedColor ?? AppColors.primary;
                    final activeBgColor =
                        Color.lerp(Colors.white, activeColor, 0.15)!;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: activeBgColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activeColor,
                          width: 2.5,
                        ),
                      ),
                      child: CategoryIconWidget(
                        iconName: currentIcon,
                        color: activeColor,
                        size: 28,
                        imageBorderRadius: 32,
                        useFullBox: true,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // SECTION: Pilih Tipe Icon (Vector / Emoji / Gambar)
              const Text(
                'Pilih Tipe Icon',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // 3-Segmented Switcher Tab
              Container(
                height: 42,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildIconTabButton(title: 'Standard', modeIndex: 0),
                    _buildIconTabButton(title: 'Emoji 😃', modeIndex: 1),
                    _buildIconTabButton(title: 'Gambar 🖼️', modeIndex: 2),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Konten Tab Icon
              if (_iconTabMode == 0) _buildVectorIconPicker(),
              if (_iconTabMode == 1) _buildEmojiPicker(),
              if (_iconTabMode == 2) _buildImagePickerView(),

              const SizedBox(height: 20),

              // SECTION: Pilih Warna
              const Text(
                'Pilih Warna',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              if (_isLoadingHistory)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    // Color Picker Button
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textSecondary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),

                    // History Colors
                    ..._colorHistory.map((colorInt) {
                      final isSelected = _selectedColor != null &&
                          _selectedColor!.value == colorInt;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedColor = Color(colorInt)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(colorInt),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.textPrimary,
                                    width: 3,
                                  )
                                : Border.all(
                                    color: Colors.transparent,
                                    width: 3,
                                  ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }),
                  ],
                ),
              const SizedBox(height: 20),

              // Keywords untuk Voice Input
              const Text(
                'Kata Kunci Voice (opsional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pisahkan dengan koma. Contoh: gaji, bonus, dividen',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ShakeWidget(
                shake: _shakeKeywords,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _keywordsController,
                      onChanged: (val) {
                        _isKeywordsManuallyEdited = true;
                        if (_keywordsError != null) {
                          setState(() {
                            _keywordsError = null;
                            _shakeKeywords = false;
                          });
                        }
                      },
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'kata1, kata2, kata3',
                        hintStyle: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSubtle,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.cardBorder.withOpacity(0.5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.cardBorder.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    if (_keywordsError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          _keywordsError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah Kategori',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets untuk Icon Picker ---

  Widget _buildIconTabButton({required String title, required int modeIndex}) {
    final isSelected = _iconTabMode == modeIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _iconTabMode = modeIndex;
            if (modeIndex == 0 &&
                (_selectedIconNotifier.value.startsWith('emoji:') ||
                    _selectedIconNotifier.value.startsWith('image:'))) {
              _selectedIconNotifier.value = 'shopping_bag_rounded';
            } else if (modeIndex == 1 && _emojiController.text.isNotEmpty) {
              _selectedIconNotifier.value = 'emoji:${_emojiController.text}';
            } else if (modeIndex == 2 && _customImagePath != null) {
              _selectedIconNotifier.value = 'image:$_customImagePath';
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVectorIconPicker() {
    return ValueListenableBuilder<String>(
      valueListenable: _selectedIconNotifier,
      builder: (context, currentIcon, _) {
        return SizedBox(
          height: 140,
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: IconResolver.allIconNames.length,
            itemBuilder: (context, index) {
              final iconName = IconResolver.allIconNames[index];
              final isSelected = currentIcon == iconName;
              return GestureDetector(
                onTap: () => _selectedIconNotifier.value = iconName,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.12)
                        : AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(
                            color: AppColors.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    IconResolver.resolve(iconName),
                    size: 22,
                    color:
                        isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmojiPicker() {
    return ValueListenableBuilder<String>(
      valueListenable: _selectedIconNotifier,
      builder: (context, currentIcon, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Emoji Custom
            TextField(
              controller: _emojiController,
              maxLength: 2,
              onChanged: (val) {
                final trimmed = val.trim();
                if (trimmed.isNotEmpty) {
                  _selectedIconNotifier.value = 'emoji:$trimmed';
                }
              },
              decoration: InputDecoration(
                hintText: 'Ketik emoji dari keyboard (misal 🍔)...',
                counterText: '',
                hintStyle:
                    const TextStyle(color: AppColors.textHint, fontSize: 13),
                filled: true,
                fillColor: AppColors.surfaceSubtle,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Grid Presets Emoji
            SizedBox(
              height: 100,
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: _emojiPresets.length,
                itemBuilder: (context, index) {
                  final emoji = _emojiPresets[index];
                  final isSelected = currentIcon == 'emoji:$emoji';
                  return GestureDetector(
                    onTap: () {
                      _emojiController.text = emoji;
                      _selectedIconNotifier.value = 'emoji:$emoji';
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.surfaceSubtle.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePickerView() {
    final hasImage =
        _customImagePath != null && File(_customImagePath!).existsSync();

    return InkWell(
      onTap: _pickImageFromGallery,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage
                ? AppColors.primary
                : AppColors.cardBorder.withOpacity(0.6),
            width: hasImage ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(_customImagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.add_photo_alternate_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasImage ? 'Gambar Terpilih' : 'Upload Foto Galeri',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasImage
                        ? 'Ketuk untuk mengganti foto'
                        : 'Ketuk di sini untuk memilih foto dari HP',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasImage ? Icons.refresh_rounded : Icons.file_upload_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required String typeKey,
    required Color activeColor,
  }) {
    final isSelected = _selectedType == typeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = typeKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : AppColors.cardBorder.withOpacity(0.5),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    Color tempColor = _selectedColor ?? AppColors.primary;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Warna'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Pilih'),
              onPressed: () {
                setState(() {
                  _selectedColor = tempColor;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onSave() {
    setState(() {
      _shakeName = false;
      _nameError = null;
      _shakeKeywords = false;
      _keywordsError = null;
    });

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _shakeName = true;
        _nameError = 'Nama kategori tidak boleh kosong';
      });
      return;
    }

    if (_selectedColor == null) return;

    final colorValue = _selectedColor!.value;

    // Generate background color (15% opacity over white background gives a soft pastel look)
    final bgColor = Color.lerp(Colors.white, _selectedColor!, 0.15)!;
    final bgColorValue = bgColor.value;

    final keywords = _keywordsController.text
        .split(',')
        .map((k) => k.trim().toLowerCase())
        .where((k) => k.isNotEmpty)
        .toList();

    // Validasi duplikasi keyword lintas kategori
    for (final kw in keywords) {
      for (final otherCat in widget.allCategories) {
        if (isEditing && otherCat.id == widget.existingCategory!.id) continue;

        if (otherCat.keywords.contains(kw)) {
          setState(() {
            _shakeKeywords = true;
            _keywordsError =
                'Kata "$kw" sudah dipakai di kategori "${otherCat.name}"';
          });
          return;
        }
      }
    }

    // Save to history asynchronously (fire and forget)
    ColorHistoryManager.addColor(colorValue);

    final category = Category(
      id: isEditing
          ? widget.existingCategory!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      iconName: _selectedIconNotifier.value,
      colorValue: colorValue,
      bgColorValue: bgColorValue,
      sortOrder: isEditing ? widget.existingCategory!.sortOrder : 999,
      keywords: keywords,
      type: _selectedType,
      isDefault: isEditing ? widget.existingCategory!.isDefault : false,
      isDeleted: false,
    );

    Navigator.of(context).pop(category);
  }
}
