import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:stadium_food/src/data/models/category.dart';
import 'package:stadium_food/src/data/repositories/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository = CategoryRepository();

  CategoryBloc() : super(CategoryInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await _repository.fetchCategories();
        emit(CategoryLoaded(categories: categories));
      } catch (e, s) {
        debugPrint('Category load error: $e');
        debugPrint(s.toString());
        emit(CategoryError(message: e.toString()));
      }
    });
  }
}
