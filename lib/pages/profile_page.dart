import 'package:flutter/material.dart';
import 'package:projeto/services/database_service.dart';
import 'package:projeto/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  final String email;

  ProfilePage({required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late DatabaseService _databaseService;
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final info = await _databaseService.getUserInfo(widget.email);
    setState(() {
      userInfo = info;
    });
  }

  Future<void> _logout(BuildContext context) async {
    // Aqui você pode adicionar lógica de logout, como limpar tokens, etc.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false, // Remove todas as rotas anteriores
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    if (userInfo == null) return;

    final TextEditingController nameController =
        TextEditingController(text: userInfo!['usrName']);
    final TextEditingController emailController =
        TextEditingController(text: userInfo!['usrEmail']);
    final TextEditingController bioController =
        TextEditingController(text: userInfo!['biografia']);

    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // O usuário deve tocar em "Salvar" ou "Cancelar"
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'E-mail'),
                ),
                TextField(
                  controller: bioController,
                  decoration: InputDecoration(labelText: 'Sobre'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () async {
                await _databaseService.updateUserInfo(
                  nameController.text,
                  emailController.text,
                  bioController.text,
                );
                Navigator.of(context).pop(); // Fecha o diálogo
                _loadUserInfo(); // Recarrega as informações do usuário
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove a seta de voltar
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Color(0xFFBF0603),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: userInfo == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60.0,
                    backgroundImage: NetworkImage(
                        'https://i.pinimg.com/originals/ce/52/dc/ce52dc35b8f45ac6375170994814dc88.jpg'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    userInfo!['usrName'] ?? 'Nome não disponível',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    userInfo!['usrEmail'] ?? 'E-mail não disponível',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 221, 228),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sobre',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          userInfo!['biografia'] ?? 'Descrição não disponível',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () => _showEditDialog(context),
                    child: Text('Editar Perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFFBF0603), // Cor de fundo do botão
                      foregroundColor: Colors.white, // Cor do texto do botão
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      textStyle: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
