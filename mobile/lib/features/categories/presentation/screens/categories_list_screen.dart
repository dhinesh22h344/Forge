import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../providers/categories_controller.dart';
import '../widgets/category_card.dart';
import 'create_category_screen.dart';

class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateCategoryScreen())),
        child: const Icon(Icons.add_rounded),
      ),
      body: categoriesAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: const UnknownFailure('Could not load categories'),
          onRetry: () => ref.invalidate(categoriesControllerProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyState(
              icon: Icons.category_rounded,
              title: 'No categories yet',
              message: 'Create your first category to start organizing habits — Fitness, Learning, Finance, anything.',
              actionLabel: 'Create Category',
              onAction: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateCategoryScreen())),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final category = categories[i];
              return CategoryCard(
                category: category,
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => CreateCategoryScreen(editing: category))),
              );
            },
          );
        },
      ),
    );
  }
}
