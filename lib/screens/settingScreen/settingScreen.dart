import 'package:flutter/material.dart';
import 'package:inventra/screens/settingScreen/bussinesInfo/editBussinesInfoScreen.dart';
import 'package:inventra/screens/settingScreen/category/categoryScreen.dart';
import 'package:inventra/screens/settingScreen/printers/printerScreen.dart';
import 'package:inventra/utils/colors.dart';
import 'package:inventra/widgets/bottomNavBar.dart';
import 'package:inventra/widgets/customSettingsButtom.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  static const String routeName = '/settingScreen';

  @override
  Widget build(BuildContext context) {
    Size base = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(leading: SizedBox(), title: const Text('Configuraciones')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _onProfilePictureTapped(context);
                },
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage: AssetImage('assets/profilePicture.png'),
                ),
              ),
              buildPersonalInfo(base),
              SizedBox(height: base.height * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    CustomSettingsButtom(
                      label: "Editar informacion",
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          EditBussinesInfoScreen.routeName,
                        );
                      },
                      icon: Icons.edit,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: CustomSettingsButtom(
                        label: "Editar Categorias",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            CategoryScreen.routeName,
                          );
                        },
                        icon: Icons.category,
                      ),
                    ),
                    CustomSettingsButtom(
                      label: "Impresoras",
                      onTap: () {
                        Navigator.pushNamed(context, PrintersScreen.routeName);
                      },
                      icon: Icons.print,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: CustomSettingsButtom(
                        label: "Editar factura",
                        onTap: () {
                          // Navigator.pushNamed(
                          //   context,
                          //   ItinerariesScreen.routeName,
                          // );
                        },
                        icon: Icons.receipt_long,
                      ),
                    ),
                    CustomSettingsButtom(
                      label: "Exportar datos",
                      onTap: () {
                        // Navigator.pushNamed(
                        //   context,
                        //   ItinerariesScreen.routeName,
                        // );
                      },
                      icon: Icons.file_download,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        // onTabSelected: (index) {},
      ),
    );
  }

  buildPersonalInfo(Size base) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            "John Doe",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text("john.doe@example.com", style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Text("123 Main St, Anytown, USA", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  _onProfilePictureTapped(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // isDismissible: false,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Stack(
          children: [
            DraggableScrollableSheet(
              initialChildSize: 0.27,
              minChildSize: 0.27,
              maxChildSize: 0.27,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Indicador draggable
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            spacing: 12,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
