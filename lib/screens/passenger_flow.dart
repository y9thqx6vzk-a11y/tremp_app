import 'package:flutter/material.dart';
import '../models/ride.dart';
import '../services/supabase_service.dart';
import 'package:intl/intl.dart' hide TextDirection;

class PassengerFlow extends StatefulWidget {
  final String userName;

  const PassengerFlow({super.key, required this.userName});

  @override
  State<PassengerFlow> createState() => _PassengerFlowState();
}

class _PassengerFlowState extends State<PassengerFlow> {
  final SupabaseService _supabaseService = SupabaseService();
  final _originSearchController = TextEditingController();
  final _destinationSearchController = TextEditingController();

  List<Ride> _rides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    final origin = _originSearchController.text.trim();
    final destination = _destinationSearchController.text.trim();
    
    final results = await _supabaseService.searchRides(origin, destination);
    setState(() {
      _rides = results;
      _isLoading = false;
    });
  }

  void _joinRide(Ride ride) async {
    if (ride.passengers.contains(widget.userName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אתה כבר רשום לטרמפ הזה!', textAlign: TextAlign.right),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _supabaseService.joinRide(ride.id, widget.userName);
    
    Navigator.pop(context); // Close loading dialog

    if (success) {
      _performSearch(); // Refresh list
      _showSuccessDialog(ride);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('לא ניתן להצטרף לטרמפ (ייתכן ואין מקומות פנויים).', textAlign: TextAlign.right),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(Ride ride) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('איזה כיף! 🎉', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 72),
              const SizedBox(height: 16),
              Text(
                'נרשמת בהצלחה לטרמפ של ${ride.driverName}!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'מ-${ride.origin} ל-${ride.destination}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('מעולה, תודה!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('חיפוש טרמפ', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: Container(
          color: const Color(0xFFF5F7FA),
          child: Column(
            children: [
              _buildSearchHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _performSearch,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _rides.isEmpty
                          ? _buildEmptyState()
                          : _buildRidesList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _originSearchController,
                  onChanged: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'מאיפה? (למשל: תל אביב)',
                    prefixIcon: const Icon(Icons.location_on, color: Colors.blue, size: 20),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _destinationSearchController,
                  onChanged: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'לאן? (למשל: ירושלים)',
                    prefixIcon: const Icon(Icons.flag, color: Colors.red, size: 20),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80.0),
      children: [
        Icon(Icons.search_off_rounded, size: 100, color: Colors.grey[400]),
        const SizedBox(height: 24),
        const Text(
          'לא נמצאו טרמפים מתאימים',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Text(
          'נסה לשנות את סינוני החיפוש למעלה או בדוק שוב מאוחר יותר.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRidesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _rides.length,
      itemBuilder: (context, index) {
        final ride = _rides[index];
        final formattedDate = DateFormat('dd.MM.yyyy').format(ride.departureTime);
        final formattedTime = DateFormat('HH:mm').format(ride.departureTime);
        final isUserRegistered = ride.passengers.contains(widget.userName);

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFFFE0B2),
                          foregroundColor: const Color(0xFFE65100),
                          child: Text(ride.driverName.isNotEmpty ? ride.driverName[0] : 'נ'),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.driverName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'נהג/ת',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '$formattedDate | $formattedTime',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'מקור: ${ride.origin}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                  child: Icon(Icons.arrow_downward, size: 14, color: Colors.grey),
                ),
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'יעד: ${ride.destination}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_seat, color: Colors.orange, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'מקומות פנויים: ${ride.availableSeats}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ride.availableSeats > 0 ? Colors.green[800] : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: ride.availableSeats > 0 || isUserRegistered
                          ? () => _joinRide(ride)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUserRegistered ? Colors.green : const Color(0xFFFF9800),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        isUserRegistered ? 'רשום/ה לטרמפ' : 'בקש להצטרף',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (ride.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      '📝 ${ride.notes}',
                      style: TextStyle(color: Colors.grey[800], fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
