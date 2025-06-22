import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:sotfbee/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:sotfbee/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sotfbee/features/auth/data/models/user_model.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserProfile? _userProfile; // Cambiado a nullable
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isPasswordEditing = false;
  bool _showPassword = false;
  String? _errorMessage;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Para gestión de imágenes
  File? _selectedImage;
  String? _newImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con valores vacíos
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthStorage.getToken();
      if (token == null) throw Exception('No autenticado');

      final profile = await AuthService.getUserProfile(token);
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _phoneController.text = profile.phone;
        });
      } else {
        throw Exception('No se pudo cargar el perfil de usuario');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && _userProfile != null) {
      setState(() {
        _selectedImage = File(image.path);
        _newImagePath =
            'user_${_userProfile!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      });
    }
  }

  Future<void> _updateProfilePicture() async {
    if (_selectedImage == null || _newImagePath == null || _userProfile == null)
      return;

    final token = await AuthStorage.getToken();
    if (token == null) return;

    // 1. Subir la imagen al servidor
    final uploadResult = await _uploadImage(_selectedImage!, _newImagePath!);
    if (!uploadResult['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error subiendo imagen: ${uploadResult['message']}'),
        ),
      );
      return;
    }

    // 2. Actualizar la referencia en el perfil
    final updateResult = await AuthService.updateProfilePicture(
      token,
      _userProfile!.id,
      _newImagePath!,
    );

    if (updateResult['success'] == true) {
      await _loadUserProfile();
      setState(() => _selectedImage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto de perfil actualizada correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error actualizando perfil: ${updateResult['message']}',
          ),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _uploadImage(File image, String filename) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://softbee-back-end.onrender.com/api/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> _updateProfile() async {
    if (_userProfile == null) return;

    setState(() => _isLoading = true);
    try {
      final token = await AuthStorage.getToken();
      if (token == null) throw Exception('No autenticado');

      final response = await http.put(
        Uri.parse(
          'https://softbee-back-end.onrender.com/api/users/${_userProfile!.id}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nombre': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        await _loadUserProfile();
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = await AuthStorage.getToken();
      if (token == null) throw Exception('No autenticado');

      final result = await AuthService.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
        token,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contraseña cambiada correctamente')),
        );
        setState(() {
          _isPasswordEditing = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      } else {
        throw Exception(result['message'] ?? 'Error cambiando contraseña');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
        actions: [
          if (_isEditing)
            IconButton(icon: Icon(Icons.save), onPressed: _updateProfile),
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing && _userProfile != null) {
                  _nameController.text = _userProfile!.name;
                  _emailController.text = _userProfile!.email;
                  _phoneController.text = _userProfile!.phone;
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _userProfile == null
          ? Center(child: Text('Perfil no disponible'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: 20),
                  _buildUserInfoSection(),
                  SizedBox(height: 20),
                  if (_isPasswordEditing) _buildChangePasswordForm(),
                  if (!_isPasswordEditing)
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _isPasswordEditing = true),
                      child: Text('Cambiar Contraseña'),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await AuthStorage.deleteToken();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Cerrar Sesión'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_userProfile!.profilePicture != 'default_profile.jpg'
                              ? NetworkImage(
                                  'https://softbee-back-end.onrender.com/api/uploads/${_userProfile!.profilePicture}',
                                )
                              : AssetImage('images/userSoftbee.png'))
                          as ImageProvider,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: _pickImage,
                ),
              ),
            ],
          ),
          if (_selectedImage != null) ...[
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateProfilePicture,
              child: Text('Guardar imagen'),
            ),
          ],
          SizedBox(height: 10),
          Text(
            _userProfile!.name,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Miembro desde ${_userProfile!.createdAt.year}',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Nombre', _nameController, _isEditing),
            _buildInfoRow('Correo', _emailController, _isEditing),
            _buildInfoRow('Teléfono', _phoneController, _isEditing),
            _buildReadOnlyInfo(
              'Fecha de Registro',
              '${_userProfile!.createdAt.day}/${_userProfile!.createdAt.month}/${_userProfile!.createdAt.year}',
            ),
            if (_userProfile!.apiaries.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Apiarios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ..._userProfile!.apiaries
                  .map((apiary) => _buildApiaryCard(apiary))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    TextEditingController controller,
    bool isEditable,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: isEditable
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  )
                : Text(controller.text, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildApiaryCard(Apiary apiary) {
    return Card(
      margin: EdgeInsets.only(top: 10),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              apiary.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Dirección: ${apiary.address}'),
            Text('Colmenas: ${apiary.hiveCount}'),
            Text('Tratamientos: ${apiary.appliesTreatments ? 'Sí' : 'No'}'),
            Text(
              'Registrado: ${apiary.createdAt.day}/${apiary.createdAt.month}/${apiary.createdAt.year}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Cambiar Contraseña',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _currentPasswordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Contraseña Actual',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Confirmar Nueva Contraseña',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordEditing = false;
                      _currentPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
                  child: Text('Cancelar'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _changePassword,
                  child: Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
