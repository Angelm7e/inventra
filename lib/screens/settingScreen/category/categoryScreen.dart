import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inventra/models/category.dart';
import 'package:inventra/provider/categoryProvider.dart';
import 'package:inventra/utils/colors.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  static const String routeName = '/categoryScreen';

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  CategoryProvider get _categoryService =>
      Provider.of<CategoryProvider>(context, listen: false);
  final TextEditingController _categoryNameController = TextEditingController();

  bool hasError = false;
  String errorMessage = '';

  needToAddcategory() {
    if (_categoryService.categories.isEmpty) {
      _showAddCategoryDialog(null);
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      needToAddcategory();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Categorías')),
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {});
          return Future.delayed(Duration(seconds: 1));
        },
        child: Center(
          child: FutureBuilder<List<Category>>(
            future: _categoryService.loadCategories(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error cargando categorías.'),
                    );
                  }

                  return snapshot.data!.isEmpty
                      ? const Center(child: Text('No categories in List.'))
                      : ListView(
                          children: snapshot.data!.map((Category) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Slidable(
                                  startActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: [
                                      CustomSlidableAction(
                                        padding: EdgeInsets.zero,
                                        onPressed: (context) =>
                                            _showAddCategoryDialog(Category),
                                        backgroundColor: AppColors.lightSuccess,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              size: 26,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 5),

                                      CustomSlidableAction(
                                        padding: EdgeInsets.zero,
                                        onPressed: (context) =>
                                            _onDelete(Category),

                                        backgroundColor: AppColors.lightError,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 26,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 5),
                                    ],
                                  ),

                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              Category.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  //Modal para agregar o editar categoría
  void _showAddCategoryDialog(Category? category) {
    _categoryNameController.text = category?.name ?? '';

    // resetear errores al abrir
    hasError = false;
    errorMessage = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                category == null ? 'Agregar Categoría' : 'Editar Categoría',
              ),
              content: TextField(
                controller: _categoryNameController,
                onChanged: (_) {
                  if (hasError) {
                    setStateDialog(() {
                      hasError = false;
                      errorMessage = '';
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Nombre de la categoría',
                  errorText: hasError ? errorMessage : null,
                  errorMaxLines: 2,
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (category == null) {
                          _onAddCategory(setStateDialog);
                        } else {
                          _onEdit(category, setStateDialog);
                        }
                      },
                      child: Text(
                        category == null ? 'Agregar' : 'Guardar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  //Funcion para agregar categoría
  void _onAddCategory(Function setStateDialog) {
    String name = _categoryNameController.text.trim();
    FocusScope.of(context).unfocus();

    if (name.isEmpty) {
      setStateDialog(() {
        hasError = true;
        errorMessage = 'El nombre de la categoría no puede estar vacío.';
      });
      return;
    }

    Category newCategory = Category(name: name);

    _categoryService.addCategory(newCategory).then((result) {
      if (result == -2) {
        setStateDialog(() {
          hasError = true;
          errorMessage = 'La categoría ya existe.';
        });
      } else {
        setState(() {});
        Navigator.pop(context);
      }
    });
  }

  //Función para editar categoría
  void _onEdit(Category category, Function setStateDialog) {
    _categoryNameController.text = category.name;
    _categoryService.updateCategory(category).then((result) {
      if (result > 0) {
        setState(() {});
      }
      if (result == -2) {
        setStateDialog(() {
          hasError = true;
          errorMessage = 'La categoría ya existe.';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al editar la categoría.')),
        );
      }
    });
  }

  //Función para eliminar categoría
  void _onDelete(Category category) {
    _categoryService.removeCategory(category.id!).then((result) {
      if (result > 0) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Categoría eliminada exitosamente.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.lightSuccess,
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar la categoría.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    });
  }
}
