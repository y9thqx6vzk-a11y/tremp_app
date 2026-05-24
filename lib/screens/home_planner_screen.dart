import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'route_results_screen.dart';
import '../services/deep_link_service.dart';

class HomePlannerScreen extends StatefulWidget {
  const HomePlannerScreen({super.key});

  @override
  State<HomePlannerScreen> createState() => _HomePlannerScreenState();
}

class _HomePlannerScreenState extends State<HomePlannerScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final DeepLinkService _deepLinkService = DeepLinkService();

  static const List<String> _israeliCities = [
    'תל אביב', 'ירושלים', 'חיפה', 'באר שבע', 'ראשון לציון',
    'אשדוד', 'פתח תקווה', 'נתניה', 'אילת', 'טבריה', 'הרצליה'
  ];

  @override
  void initState() {
    super.initState();
    _deepLinkService.onRendezvousRequest = _handleIncomingRendezvous;
    _deepLinkService.init();
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  void _handleIncomingRendezvous(String origin, String destination, String driverLocation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('מחשב מסלול חבירה לנוסע...', textDirection: TextDirection.rtl),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouteResultsScreen(
            origin: origin,
            destination: destination,
            driverLocation: driverLocation,
          ),
        ),
      );
    });
  }

  void _calculateRoute() {
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אנא הזן גם נקודת מוצא וגם יעד לחישוב המסלול.', textAlign: TextAlign.right),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteResultsScreen(
          origin: origin,
          destination: destination,
        ),
      ),
    );
  }

  void _shareRendezvousLink() {
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('הזן מוצא ויעד לפני בקשת איסוף.', textAlign: TextAlign.right),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final link = 'trempapp://rendezvous?origin=${Uri.encodeComponent(origin)}&destination=${Uri.encodeComponent(destination)}';
    Share.share('היי! אשמח אם תוכל לאסוף אותי. לחץ על הקישור כדי שהאפליקציה תחשב לנו את נקודת המפגש האידיאלית:\n\n$link');
  }

  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _israeliCities.where((String option) {
          return option.contains(textEditingValue.text);
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          onChanged: (text) => controller.text = text,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: iconColor),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.alt_route_rounded, size: 48, color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'לאן ניסע היום?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'הזן יעד וגלה את הדרך המהירה (או ההרפתקנית) ביותר.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -40),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildAutocompleteField(
                        controller: _originController,
                        hintText: 'נקודת מוצא (למשל: תל אביב)',
                        icon: Icons.my_location_rounded,
                        iconColor: Colors.blue,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 12),
                        child: const Icon(Icons.swap_vert_rounded, color: Colors.grey),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      _buildAutocompleteField(
                        controller: _destinationController,
                        hintText: 'יעד (למשל: ירושלים)',
                        icon: Icons.place_rounded,
                        iconColor: Colors.red,
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateRoute,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E3192),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'חפש מסלולים',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _shareRendezvousLink,
                          icon: const Icon(Icons.share_rounded, color: Color(0xFF2E3192)),
                          label: const Text(
                            'בקש איסוף מחבר',
                            style: TextStyle(
                              color: Color(0xFF2E3192),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF2E3192), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
