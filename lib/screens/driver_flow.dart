import 'package:flutter/material.dart';
import '../models/ride.dart';
import '../services/supabase_service.dart';
import 'package:intl/intl.dart' hide TextDirection;

class DriverFlow extends StatefulWidget {
  final String userName;

  const DriverFlow({super.key, required this.userName});

  @override
  State<DriverFlow> createState() => _DriverFlowState();
}

class _DriverFlowState extends State<DriverFlow> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Ride> _myRides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyRides();
  }

  Future<void> _loadMyRides() async {
    setState(() => _isLoading = true);
    final allRides = await _supabaseService.getRides();
    // Filter rides offered by this driver
    setState(() {
      _myRides = allRides.where((ride) => ride.driverName == widget.userName).toList();
      _isLoading = false;
    });
  }

  void _openOfferRideSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OfferRideSheet(
        userName: widget.userName,
        onRideCreated: () {
          _loadMyRides();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('הנסיעה פורסמה בהצלחה! 🚗', textAlign: TextAlign.right),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('אזור הנהג - מציע נסיעה', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: Container(
          color: const Color(0xFFF5F7FA),
          child: RefreshIndicator(
            onRefresh: _loadMyRides,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _myRides.isEmpty
                    ? _buildEmptyState()
                    : _buildRidesList(),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openOfferRideSheet,
          backgroundColor: const Color(0xFF4CAF50),
          icon: const Icon(Icons.add_road_rounded, color: Colors.white),
          label: const Text('הצע נסיעה חדשה', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80.0),
      children: [
        Icon(Icons.directions_car_outlined, size: 100, color: Colors.grey[400]),
        const SizedBox(height: 24),
        const Text(
          'עדיין לא פרסמת נסיעות!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Text(
          'לחץ על הכפתור למטה כדי להציע את הטרמפ הראשון שלך ולעזור לחבר׳ה להגיע ליעד.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRidesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _myRides.length,
      itemBuilder: (context, index) {
        final ride = _myRides[index];
        final formattedDate = DateFormat('dd.MM.yyyy').format(ride.departureTime);
        final formattedTime = DateFormat('HH:mm').format(ride.departureTime);

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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'פעיל',
                        style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Text(
                      '$formattedDate | $formattedTime',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'מקור: ${ride.origin}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 4.0),
                  child: Icon(Icons.arrow_downward, size: 16, color: Colors.grey),
                ),
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'יעד: ${ride.destination}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                        const Icon(Icons.event_seat, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          'מקומות פנויים: ${ride.availableSeats}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      'נוסעים: ${ride.passengers.isEmpty ? 'אין נוסעים רשומים' : ride.passengers.join(', ')}',
                      style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                if (ride.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '📝 ${ride.notes}',
                      style: TextStyle(color: Colors.grey[800], fontSize: 14),
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

class OfferRideSheet extends StatefulWidget {
  final String userName;
  final VoidCallback onRideCreated;

  const OfferRideSheet({super.key, required this.userName, required this.onRideCreated});

  @override
  State<OfferRideSheet> createState() => _OfferRideSheetState();
}

class _OfferRideSheetState extends State<OfferRideSheet> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _seats = 3;
  bool _isSubmitting = false;

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final departureDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final newRide = Ride(
      id: '',
      driverName: widget.userName,
      origin: _originController.text.trim(),
      destination: _destinationController.text.trim(),
      departureTime: departureDateTime,
      availableSeats: _seats,
      notes: _notesController.text.trim(),
      passengers: [],
    );

    final success = await SupabaseService().createRide(newRide);

    setState(() => _isSubmitting = false);

    if (success) {
      widget.onRideCreated();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('חלה שגיאה בפרסום הנסיעה. נסה שנית.', textAlign: TextAlign.right),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd.MM.yyyy').format(_selectedDate);
    final formattedTime = _selectedTime.format(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'הצעת נסיעה חדשה 🚗',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _originController,
                  decoration: InputDecoration(
                    labelText: 'נקודת מוצא',
                    prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'נא להזין נקודת מוצא' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: 'יעד נסיעה',
                    prefixIcon: const Icon(Icons.flag, color: Colors.red),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'נא להזין יעד' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDateTime,
                        icon: const Icon(Icons.calendar_month),
                        label: Text('$formattedDate ב-$formattedTime'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('מספר מקומות פנויים:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _seats > 1 ? () => setState(() => _seats--) : null,
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                        ),
                        Text('$_seats', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: _seats < 7 ? () => setState(() => _seats++) : null,
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'הערות (למשל: מקום לציוד, כביש 6 וכדו׳)',
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'פרסם נסיעה',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
