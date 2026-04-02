import 'package:flutter/material.dart';
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
              CircleAvatar(
                radius: 100,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('assets/profilePicture.png'),
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
                        print("object");
                      },
                      icon: Icons.edit,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: CustomSettingsButtom(
                        label: "Editar Categorias",
                        onTap: () {},
                        icon: Icons.category,
                      ),
                    ),
                    CustomSettingsButtom(
                      label: "Impresoras",
                      onTap: () {
                        print("object");
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
}
