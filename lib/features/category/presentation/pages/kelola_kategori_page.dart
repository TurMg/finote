// features/category/presentation/pages/kelola_kategori_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/top_snackbar.dart';
import '../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../widgets/category_grid_item.dart';
import '../widgets/category_type_tab_bar.dart';
import '../widgets/form_kategori_bottom_sheet.dart';

class KelolaKategoriPage extends StatelessWidget {
  const KelolaKategoriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const KelolaKategoriView();
  }
}

class KelolaKategoriView extends StatefulWidget {
  const KelolaKategoriView({super.key});

  @override
  State<KelolaKategoriView> createState() => _KelolaKategoriViewState();
}

class _KelolaKategoriViewState extends State<KelolaKategoriView> {
  String _selectedType = 'EXPENSE'; // 'EXPENSE' or 'INCOME'
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Kelola Kategori',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          // Toggle Edit Mode Button
          TextButton(
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
            child: Text(
              _isEditMode ? 'Selesai' : 'Edit',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CategoryError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          if (state is CategoryLoaded) {
            final allCategories = state.categories;

            // Filter kategori berdasarkan tipe yang dipilih (EXPENSE atau INCOME)
            final filteredCategories = allCategories
                .where(
                    (cat) => cat.type == _selectedType || cat.type == 'BOTH')
                .toList();

            return Column(
              children: [
                // Tab Bar Switcher (Pengeluaran | Pemasukan)
                CategoryTypeTabBar(
                  selectedType: _selectedType,
                  onTypeChanged: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                ),

                // Info Bar kecil
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kategori Aktif (${filteredCategories.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_isEditMode)
                        const Text(
                          'Tap - untuk menghapus',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const Text(
                          'Tahan & geser untuk urutkan',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Grid View Kategori
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: filteredCategories.length + 1,
                    itemBuilder: (context, index) {
                      // Item terakhir adalah Tile "+ Tambah"
                      if (index == filteredCategories.length) {
                        return CategoryAddGridTile(
                          onTap: () => _showAddSheet(
                            context,
                            allCategories,
                            defaultType: _selectedType,
                          ),
                        );
                      }

                      final category = filteredCategories[index];
                      return DragTarget<int>(
                        onWillAcceptWithDetails: (details) => details.data != index,
                        onAcceptWithDetails: (details) {
                          final oldIndexInFiltered = details.data;
                          final newIndexInFiltered = index;

                          if (oldIndexInFiltered == newIndexInFiltered) return;

                          final oldCat = filteredCategories[oldIndexInFiltered];
                          final newCat = filteredCategories[newIndexInFiltered];

                          final oldIndexInAll = allCategories.indexWhere((c) => c.id == oldCat.id);
                          final newIndexInAll = allCategories.indexWhere((c) => c.id == newCat.id);

                          if (oldIndexInAll != -1 && newIndexInAll != -1) {
                            final targetNewIdx = newIndexInAll > oldIndexInAll ? newIndexInAll + 1 : newIndexInAll;
                            context.read<CategoryBloc>().add(
                                  ReorderCategory(
                                    oldIndex: oldIndexInAll,
                                    newIndex: targetNewIdx,
                                  ),
                                );
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return LongPressDraggable<int>(
                            data: index,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Transform.scale(
                                scale: 1.12,
                                child: Opacity(
                                  opacity: 0.9,
                                  child: SizedBox(
                                    width: 70,
                                    height: 90,
                                    child: CategoryGridItem(
                                      category: category,
                                      isEditMode: false,
                                      onTap: () {},
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: CategoryGridItem(
                                category: category,
                                isEditMode: _isEditMode,
                                onTap: () {},
                              ),
                            ),
                            child: CategoryGridItem(
                              key: ValueKey(category.id),
                              category: category,
                              isEditMode: _isEditMode,
                              onTap: () {
                                if (_isEditMode) {
                                  _confirmDelete(context, category);
                                } else {
                                  _showEditSheet(context, category, allCategories);
                                }
                              },
                              onDelete: () => _confirmDelete(context, category),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Hapus Kategori?'),
        content: Text(
          'Kategori "${category.name}" akan dihapus dari daftar input.\n\n'
          'Transaksi terdahulu yang menggunakan kategori ini tetap tersimpan di riwayat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CategoryBloc>().add(DeleteCategory(category.id));
      TopSnackBar.show(
        context,
        message: '"${category.name}" telah dihapus',
        type: TopSnackBarType.info,
      );
    }
  }

  void _showAddSheet(
    BuildContext context,
    List<Category> allCategories, {
    required String defaultType,
  }) async {
    final result = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormKategoriBottomSheet(
        allCategories: allCategories,
        defaultType: defaultType,
      ),
    );

    if (result != null && context.mounted) {
      context.read<CategoryBloc>().add(AddCategory(result));
    }
  }

  void _showEditSheet(
    BuildContext context,
    Category category,
    List<Category> allCategories,
  ) async {
    final result = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormKategoriBottomSheet(
        existingCategory: category,
        allCategories: allCategories,
      ),
    );

    if (result != null && context.mounted) {
      context.read<CategoryBloc>().add(UpdateCategory(result));
    }
  }
}
