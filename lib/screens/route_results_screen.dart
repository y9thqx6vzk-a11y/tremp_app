import 'package:flutter/material.dart';
import '../models/trip_route.dart';
import '../services/routing_engine.dart';
import '../widgets/mapbox_placeholder.dart';

class RouteResultsScreen extends StatefulWidget {
  final String origin;
  final String destination;

  const RouteResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  State<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  final RoutingEngine _routingEngine = RoutingEngine();
  List<TripRoute> _routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    final routes = await _routingEngine.calculateRoutes(widget.origin, widget.destination);
    setState(() {
      _routes = routes;
      _isLoading = false;
    });
  }

  TripRoute? _getRouteByType(String type) {
    if (_routes.isEmpty) return null;
    return _routes.firstWhere(
      (r) => r.routeType == type,
      orElse: () => _routes.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.origin} ➔ ${widget.destination}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            backgroundColor: const Color(0xFF2E3192),
            foregroundColor: Colors.white,
            elevation: 0,
            bottom: const TabBar(
              isScrollable: true,
              indicatorColor: Color(0xFF1BFFFF),
              indicatorWeight: 4,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(icon: Icon(Icons.star_rounded), text: 'מומלץ'),
                Tab(icon: Icon(Icons.alt_route_rounded), text: 'משולב'),
                Tab(icon: Icon(Icons.directions_bus_rounded), text: 'רק תחב״צ'),
                Tab(icon: Icon(Icons.thumb_up_rounded), text: 'רק טרמפים'),
              ],
            ),
          ),
          body: _isLoading
              ? _buildLoadingState()
              : Column(
                  children: [
                    // The Mapbox Infrastructure Placeholder
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: MapboxPlaceholder(height: 200),
                    ),
                    
                    // The Tabs Content
                    Expanded(
                      child: TabBarView(
                        children: [
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
            'מחשב את הדרכים הטובות ביותר...',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTab(TripRoute? route) {
    if (route == null) return const Center(child: Text('לא נמצא מסלול'));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Route Summary Card
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

        // Route Segments Timeline
        ...route.segments.map((segment) => _buildSegmentItem(segment)),
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
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
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
          // Segment Details
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
