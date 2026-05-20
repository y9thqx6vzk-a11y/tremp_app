import 'package:flutter/material.dart';
import '../models/trip_route.dart';
import '../services/routing_engine.dart';
import '../widgets/mapbox_placeholder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../main.dart';

class RouteResultsScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final String? driverLocation;

  const RouteResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    this.driverLocation,
  });

  @override
  State<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  final RoutingEngine _routingEngine = getIt<RoutingEngine>();
  List<TripRoute> _routes = [];
  bool _isLoading = true;
  late int _tabsCount;

  @override
  void initState() {
    super.initState();
    _tabsCount = widget.driverLocation != null ? 5 : 4;
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    final routes = await _routingEngine.calculateRoutes(widget.origin, widget.destination);
    
    if (widget.driverLocation != null) {
      final rendezvous = await _routingEngine.calculateRendezvousRoute(
        widget.origin, 
        widget.destination, 
        widget.driverLocation!
      );
      // Insert at the beginning so it's the first tab shown
      routes.insert(0, rendezvous);
    }

    setState(() {
      _routes = routes;
      _isLoading = false;
    });
  }

  TripRoute? _getRouteByType(String type) {
    if (_routes.isEmpty) return null;
    try {
      return _routes.firstWhere((r) => r.routeType == type);
    } catch (e) {
      return null; // Return null if not found (e.g. rendezvous is not requested)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: _tabsCount,
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.origin} ➔ ${widget.destination}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            backgroundColor: const Color(0xFF2E3192),
            foregroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: const Color(0xFF1BFFFF),
              indicatorWeight: 4,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                if (widget.driverLocation != null)
                  const Tab(icon: Icon(Icons.handshake_rounded), text: 'איסוף משולב'),
                const Tab(icon: Icon(Icons.star_rounded), text: 'מומלץ'),
                const Tab(icon: Icon(Icons.alt_route_rounded), text: 'משולב'),
                const Tab(icon: Icon(Icons.directions_bus_rounded), text: 'רק תחב״צ'),
                const Tab(icon: Icon(Icons.thumb_up_rounded), text: 'רק טרמפים'),
              ],
            ),
          ),
          body: _isLoading
              ? _buildLoadingState()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: (dotenv.env['MAPBOX_ACCESS_TOKEN']?.isNotEmpty ?? false)
                          ? Container(
                              height: 180,
                              color: Colors.blueGrey,
                              alignment: Alignment.center,
                              child: const Text('Real Mapbox View Active', style: TextStyle(color: Colors.white)),
                            )
                          : const MapboxPlaceholder(height: 180),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          if (widget.driverLocation != null)
                            _buildYGraphTab(_getRouteByType('rendezvous')),
                          _buildRouteTab(_getRouteByType('recommended')),
                          _buildRouteTab(_getRouteByType('hybrid')),
                          _buildRouteTab(_getRouteByType('only_transit')),
                          _buildRouteTab(_getRouteByType('only_hitchhike')),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFF2E3192)),
          SizedBox(height: 16),
          Text(
            'מחשב מסלולים ומיקומים...',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildYGraphTab(TripRoute? route) {
    if (route == null) return const Center(child: Text('שגיאה בטעינת החבירה'));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Card(
          elevation: 0,
          color: Colors.green[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.green[200]!)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green[600], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'נמצאה נקודת חבירה אופטימלית עם זמן המתנה משוער של כ-${route.driverSegments?.first.description.split(': ').last.split(' ').first ?? '0'} דקות!',
                    style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // The Y-Graph Visualization
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passenger side
            Expanded(
              child: Column(
                children: [
                  const Text('מסלול הנוסע', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 12),
                  ...?route.passengerSegments?.map((s) => _buildCompactSegment(s, Colors.blue)),
                ],
              ),
            ),
            
            // Middle Divider
            Container(width: 2, height: 100, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
            
            // Driver side
            Expanded(
              child: Column(
                children: [
                  const Text('מסלול הנהג', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                  const SizedBox(height: 12),
                  ...?route.driverSegments?.map((s) => _buildCompactSegment(s, Colors.purple)),
                ],
              ),
            ),
          ],
        ),
        
        // Rendezvous Point
        Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3192),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.handshake_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('נקודת החבירה', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(width: 2, height: 20, color: Colors.grey[400]),
            ],
          ),
        ),

        // Shared Path
        const Center(child: Text('המסלול המשותף', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
        const SizedBox(height: 12),
        ...route.sharedSegments.map((s) => _buildSegmentItem(s)),
      ],
    );
  }

  Widget _buildCompactSegment(RouteSegment segment, Color color) {
    return Column(
      children: [
        Icon(Icons.location_on, color: color, size: 16),
        Text(segment.origin, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Container(width: 2, height: 20, color: color.withValues(alpha: 0.3)),
        Text('${segment.duration.inMinutes} דק׳', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        Container(width: 2, height: 20, color: color.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildRouteTab(TripRoute? route) {
    if (route == null) return const Center(child: Text('לא נמצא מסלול'));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Card(
          elevation: 0,
          color: Colors.blueGrey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(Icons.timer_rounded, '${route.totalDuration.inMinutes} דק׳'),
                _buildSummaryItem(Icons.payments_rounded, '₪${route.totalCost}'),
                _buildSummaryItem(Icons.shield_rounded, '${route.averageReliabilityScore}/100\nאמינות'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('פירוט המסלול:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        
        // Render all existing passenger/driver segments if any, then shared segments
        ...?route.passengerSegments?.map((s) => _buildSegmentItem(s)),
        ...?route.driverSegments?.map((s) => _buildSegmentItem(s)),
        ...route.sharedSegments.map((s) => _buildSegmentItem(s)),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2E3192), size: 28),
        const SizedBox(height: 8),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSegmentItem(RouteSegment segment) {
    IconData typeIcon;
    Color typeColor;

    switch (segment.type) {
      case TransitType.bus:
        typeIcon = Icons.directions_bus_rounded;
        typeColor = Colors.orange;
        break;
      case TransitType.train:
        typeIcon = Icons.train_rounded;
        typeColor = Colors.red;
        break;
      case TransitType.walk:
        typeIcon = Icons.directions_walk_rounded;
        typeColor = Colors.grey;
        break;
      case TransitType.hitchhike:
        typeIcon = Icons.thumb_up_rounded;
        typeColor = Colors.green;
        break;
      case TransitType.car:
        typeIcon = Icons.directions_car_rounded;
        typeColor = Colors.purple;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeIcon, color: typeColor, size: 24),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${segment.typeName} מ-${segment.origin}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  segment.description,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${segment.duration.inMinutes} דק׳',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    if (segment.type == TransitType.hitchhike && segment.reliabilityScore != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.shield_outlined, size: 14, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        'ציון צומת: ${segment.reliabilityScore}',
                        style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
