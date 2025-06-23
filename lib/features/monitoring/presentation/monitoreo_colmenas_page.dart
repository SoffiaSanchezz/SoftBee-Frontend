import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sotfbee/features/monitoring/domain/entities/apiary_entity.dart';
import 'package:sotfbee/features/monitoring/domain/usecases/get_user_apiaries.dart';
import 'package:sotfbee/injection_container.dart';


class MonitoreoColmenas extends StatefulWidget {
  const MonitoreoColmenas({super.key});

  @override
  _MonitoreoColmenasState createState() => _MonitoreoColmenasState();
}

class _MonitoreoColmenasState extends State<MonitoreoColmenas> {
  List<ApiaryEntity> apiaries = [];
  ApiaryEntity? selectedApiary;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // _loadApiaries();
  }

  // Future<void> _loadApiaries() async {
  //   try {
  //     // Obtener el ID del usuario actual (ejemplo)
  //     final userId = await _getCurrentUserId();
      
  //     final getApiaries = getIt<GetUserApiaries>();
  //     final apiariesList = await getApiaries(userId);

  //     setState(() {
  //       apiaries = apiariesList;
  //       if (apiariesList.isNotEmpty) {
  //         selectedApiary = apiariesList.first;
  //       }
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = e.toString();
  //       isLoading = false;
  //     });
  //   }
  // }

  // Future<int> _getCurrentUserId() async {
  //   // TODO: Implementar lógica para obtener el ID del usuario actual
  //   // Por ahora, retornamos un ID fijo de ejemplo
  //   return 1;
  // }

  @override
  Widget build(BuildContext context) {
    // Manejar estados de carga/error
    if (isLoading) {
      return _buildLoadingState();
    }
    
    if (errorMessage != null) {
      return _buildErrorState();
    }
    
    if (apiaries.isEmpty) {
      return _buildEmptyState();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      appBar: AppBar(
        title: Text(
              'Apiario',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize:
                    isDesktop
                        ? 24
                        : isTablet
                        ? 22
                        : 20,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(
              begin: -0.2,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOutQuad,
            ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: Colors.amber[700],
                iconSize: isDesktop ? 28 : 24,
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
          IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
                color: Colors.amber[700],
                iconSize: isDesktop ? 28 : 24,
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber[50]!, Colors.orange[50]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth:
                      isDesktop
                          ? 1200
                          : isTablet
                          ? 900
                          : double.infinity,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal:
                      isDesktop
                          ? 32
                          : isTablet
                          ? 24
                          : 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height:
                          isDesktop
                              ? 32
                              : isTablet
                              ? 24
                              : 20,
                    ),
                    _buildCenteredHeader(),
                    SizedBox(
                      height:
                          isDesktop
                              ? 40
                              : isTablet
                              ? 32
                              : 24,
                    ),
                    isDesktop
                        ? _buildDesktopLayoutCentered()
                        : _buildMobileTabletLayoutCentered(),
                    SizedBox(
                      height:
                          isDesktop
                              ? 32
                              : isTablet
                              ? 24
                              : 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.amber[700],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Error al cargar los apiarios',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              style: GoogleFonts.poppins(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // ElevatedButton(
            //   onPressed: _loadApiaries,
            //   child: Text('Reintentar'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.amber[700],
            //     foregroundColor: Colors.white,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apiario',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            color: Colors.amber[700],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            color: Colors.amber[700],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber[50]!, Colors.orange[50]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hive_outlined, size: 72, color: Colors.amber[700]),
              SizedBox(height: 24),
              Text(
                'No tienes apiarios registrados',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Registra tu primer apiario para comenzar',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => GestionApiarioScreen()),
                  // );
                },
                icon: Icon(Icons.add),
                label: Text('Registrar Apiario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
                'Monitoreo de Colmenas',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize:
                      isDesktop
                          ? 36
                          : isTablet
                          ? 32
                          : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(
                begin: -0.2,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutQuad,
              ),
          SizedBox(height: 12),
          Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: Text(
                  'Gestiona y monitorea el estado de tus colmenas de manera eficiente y centralizada',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize:
                        isDesktop
                            ? 18
                            : isTablet
                            ? 16
                            : 15,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutQuad,
              ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayoutCentered() {
    return Container(
      constraints: BoxConstraints(maxWidth: 1000),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildColmenaSelectorCentered(),
                const SizedBox(height: 24),
                _buildColmenaActionsCentered(),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Columna derecha
          Expanded(flex: 1, child: _buildQuickStatsCentered()),
        ],
      ),
    );
  }

  Widget _buildMobileTabletLayoutCentered() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Container(
      constraints: BoxConstraints(maxWidth: isTablet ? 700 : 500),
      child: Column(
        children: [
          _buildColmenaSelectorCentered()
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutQuad,
              ),
          const SizedBox(height: 24),
          _buildColmenaActionsCentered()
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutQuad,
              ),
          const SizedBox(height: 24),
          _buildQuickStatsCentered()
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutQuad,
              ),
        ],
      ),
    );
  }

  Widget _buildColmenaSelectorCentered() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isDesktop
            ? 28
            : isTablet
            ? 24
            : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.amber[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                    Icons.headphones_battery_outlined,
                    size:
                        isDesktop
                            ? 32
                            : isTablet
                            ? 28
                            : 26,
                    color: Colors.amber[700],
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                  ),
              SizedBox(width: isDesktop ? 16 : 12),
              Text(
                    'Seleccionar Apiario',
                    style: GoogleFonts.poppins(
                      fontSize:
                          isDesktop
                              ? 22
                              : isTablet
                              ? 20
                              : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideX(begin: 0.2, end: 0),
            ],
          ),
          SizedBox(height: isDesktop ? 12 : 10),
          Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Text(
              'Elija un apiario para inspeccionar o ver su historial detallado',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize:
                    isDesktop
                        ? 16
                        : isTablet
                        ? 15
                        : 14,
                height: 1.4,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          SizedBox(height: isDesktop ? 24 : 20),
          Container(
                constraints: BoxConstraints(maxWidth: 350),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 20 : 16,
                  vertical: isDesktop ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber[200]!),
                  color: Colors.amber.withOpacity(0.08),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ApiaryEntity>(
                    value: selectedApiary,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.amber[700],
                      size: isDesktop ? 28 : 24,
                    ),
                    elevation: 16,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize:
                          isDesktop
                              ? 18
                              : isTablet
                              ? 17
                              : 16,
                    ),
                    onChanged: (ApiaryEntity? newValue) {
                      setState(() {
                        selectedApiary = newValue!;
                      });
                    },
                    items: apiaries.map<DropdownMenuItem<ApiaryEntity>>((ApiaryEntity apiary) {
                      return DropdownMenuItem<ApiaryEntity>(
                        value: apiary,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hive_outlined,
                              size: isDesktop ? 24 : 20,
                              color: Colors.amber[700],
                            ),
                            SizedBox(width: isDesktop ? 16 : 12),
                            Text(apiary.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutQuad,
              ),
        ],
      ),
    );
  }

  Widget _buildColmenaActionsCentered() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isDesktop
            ? 28
            : isTablet
            ? 24
            : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.amber[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                    Icons.hive,
                    size:
                        isDesktop
                            ? 32
                            : isTablet
                            ? 28
                            : 26,
                    color: Colors.amber[700],
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                  ),
              SizedBox(width: isDesktop ? 16 : 12),
              Text(
                    selectedApiary?.name ?? 'Apiario no seleccionado',
                    style: GoogleFonts.poppins(
                      fontSize:
                          isDesktop
                              ? 22
                              : isTablet
                              ? 20
                              : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideX(begin: 0.2, end: 0),
            ],
          ),
          SizedBox(height: isDesktop ? 12 : 10),
          Container(
            constraints: BoxConstraints(maxWidth: 450),
            child: Text(
              'Agrega información actual del estado del apiario y gestiona sus actividades',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize:
                    isDesktop
                        ? 16
                        : isTablet
                        ? 15
                        : 14,
                height: 1.4,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          SizedBox(height: isDesktop ? 24 : 20),

          // Botones centrados
          Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 600 : 400),
            child: Column(
              children: [
                // Primera fila de botones
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButtonCentered(
                            icon: Icons.change_circle_outlined,
                            label: 'Reemplazo de la reina',
                            onPressed: () {
                              // if (selectedApiary == null) return;
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder:
                              //         (context) => QueenReplacementScreen(
                              //           colmenaNombre: selectedApiary!.name,
                              //         ),
                              //   ),
                              // );
                            },
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 500.ms)
                          .slideX(begin: -0.2, end: 0, duration: 500.ms),
                    ),
                    SizedBox(width: isDesktop ? 16 : 12),
                    Expanded(
                      child: _buildActionButtonCentered(
                            icon: Icons.add_circle_outline,
                            label: 'Nueva Inspección',
                            onPressed: () {
                              // if (selectedApiary == null) return;
                              // Navigator.push(
                              //   context,
                              //   PageRouteBuilder(
                              //     pageBuilder:
                              //         (
                              //           context,
                              //           animation,
                              //           secondaryAnimation,
                              //         ) => MonitoreoApiarioScreen(),
                              //     transitionsBuilder: (
                              //       context,
                              //       animation,
                              //       secondaryAnimation,
                              //       child,
                              //     ) {
                              //       const begin = Offset(0.0, 1.0);
                              //       const end = Offset.zero;
                              //       const curve = Curves.easeOutExpo;

                              //       var tween = Tween(
                              //         begin: begin,
                              //         end: end,
                              //       ).chain(CurveTween(curve: curve));
                              //       var offsetAnimation = animation.drive(
                              //         tween,
                              //       );

                              //       return SlideTransition(
                              //         position: offsetAnimation,
                              //         child: FadeTransition(
                              //           opacity: animation,
                              //           child: child,
                              //         ),
                              //       );
                              //     },
                              //     transitionDuration: const Duration(
                              //       milliseconds: 800,
                              //     ),
                              //   ),
                              // );
                            },
                            isPrimary: true,
                          )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 500.ms)
                          .slideX(begin: 0.2, end: 0, duration: 500.ms),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 20 : 16),
                // Botón de información general
                SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // if (selectedApiary == null) return;
                          // Navigator.push(
                          //   context,
                          //   PageRouteBuilder(
                          //     pageBuilder:
                          //         (context, animation, secondaryAnimation) =>
                          //             GenInfo(colmenaNombre: selectedApiary!.name),
                          //     transitionsBuilder: (
                          //       context,
                          //       animation,
                          //       secondaryAnimation,
                          //       child,
                          //     ) {
                          //       const begin = Offset(1.0, 0.0);
                          //       const end = Offset.zero;
                          //       const curve = Curves.easeInOut;
                          //       var tween = Tween(
                          //         begin: begin,
                          //         end: end,
                          //       ).chain(CurveTween(curve: curve));
                          //       var offsetAnimation = animation.drive(tween);
                          //       return SlideTransition(
                          //         position: offsetAnimation,
                          //         child: child,
                          //       );
                          //     },
                          //     transitionDuration: const Duration(
                          //       milliseconds: 500,
                          //     ),
                          //   ),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical:
                                isDesktop
                                    ? 18
                                    : isTablet
                                    ? 16
                                    : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        icon: Icon(
                          Icons.info_outline,
                          size: isDesktop ? 24 : 20,
                        ),
                        label: Text(
                          'Información General',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize:
                                isDesktop
                                    ? 18
                                    : isTablet
                                    ? 17
                                    : 16,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutQuad,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonCentered({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.amber[50] : Colors.white,
        foregroundColor: Colors.amber[800],
        padding: EdgeInsets.symmetric(
          vertical:
              isDesktop
                  ? 18
                  : isTablet
                  ? 16
                  : 14,
          horizontal: isDesktop ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isPrimary ? Colors.amber[400]! : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        elevation: isPrimary ? 2 : 0,
      ),
      icon: Icon(
        icon,
        size:
            isDesktop
                ? 24
                : isTablet
                ? 22
                : 20,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
          fontSize:
              isDesktop
                  ? 16
                  : isTablet
                  ? 15
                  : 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildQuickStatsCentered() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isDesktop
            ? 28
            : isTablet
            ? 24
            : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.amber[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                    Icons.analytics_outlined,
                    size:
                        isDesktop
                            ? 32
                            : isTablet
                            ? 28
                            : 26,
                    color: Colors.amber[700],
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                  ),
              SizedBox(width: isDesktop ? 16 : 12),
              Text(
                    'Resumen Rápido',
                    style: GoogleFonts.poppins(
                      fontSize:
                          isDesktop
                              ? 22
                              : isTablet
                              ? 20
                              : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideX(begin: 0.2, end: 0),
            ],
          ),
          SizedBox(height: isDesktop ? 28 : 24),

          // Grid centrado para las estadísticas
          Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 400 : 350),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 1 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio:
                  isDesktop
                      ? 3.5
                      : isTablet
                      ? 2.8
                      : 2.5,
              children: [
                _buildStatCardCentered(
                      icon: Icons.eco_outlined,
                      label: 'Producción',
                      value: '25 Kg',
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                _buildStatCardCentered(
                      icon: Icons.calendar_today_outlined,
                      label: 'Última Inspección',
                      value: '19-09-2024',
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                _buildStatCardCentered(
                      icon: Icons.groups_outlined,
                      label: 'Población',
                      value: 'Alta',
                    )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                _buildStatCardCentered(
                      icon: Icons.favorite_outline,
                      label: 'Estado Reina',
                      value: 'Saludable',
                    )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardCentered({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Container(
      padding: EdgeInsets.all(
        isDesktop
            ? 6
            : isTablet
            ? 3
            : 2,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                    icon,
                    size:
                        isDesktop
                            ? 20
                            : isTablet
                            ? 18
                            : 17,
                    color: Colors.amber[700],
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 1500.ms,
                  ),
              SizedBox(width: isDesktop ? 8 : 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize:
                        isDesktop
                            ? 16
                            : isTablet
                            ? 15
                            : 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 8 : 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize:
                  isDesktop
                      ? 17
                      : isTablet
                      ? 16
                      : 15,
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }
}