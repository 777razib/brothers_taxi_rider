import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../confirm_pickup/controler/driver_infor_api_controller.dart';
import '../../confirm_pickup/widget/bottom_sheet6.dart';
import '../../end_ride/screen/end_ride.dart';
import '../controler/pickup_accept_controller.dart';

class PickupAcceptScreen extends StatefulWidget {
  const PickupAcceptScreen({super.key});

  @override
  _PickupAcceptScreenState createState() => _PickupAcceptScreenState();
}

class _PickupAcceptScreenState extends State<PickupAcceptScreen> {
  // ───── Controllers (same instances used everywhere) ─────
  final DriverInfoApiController driverInfoApiController =
  Get.put(DriverInfoApiController());

  final PickupAcceptController controller =
  Get.put(PickupAcceptController(), tag: 'pickupAccept');

  // ───── Map helpers ─────
  GoogleMapController? _mapController;
  Timer? _cameraTimer;
  StreamSubscription? _markersSub;
  StreamSubscription? _polylinesSub;
  StreamSubscription? _driverSub;

  // ────────────────────────────────────────
  // Init
  // ────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    controller.isBottomSheetOpen.value = true;

    // Load ride data from navigation arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      final pLat = double.tryParse(args['pickupLat']?.toString() ?? '') ?? 23.749341;
      final pLng = double.tryParse(args['pickupLng']?.toString() ?? '') ?? 90.437213;
      final dLat = double.tryParse(args['dropoffLat']?.toString() ?? '');
      final dLng = double.tryParse(args['dropoffLng']?.toString() ?? '');

      controller.loadAndDisplayRideData(
        initialPickupLat: pLat,
        initialPickupLng: pLng,
        initialDropoffLat: dLat,
        initialDropoffLng: dLng,
      );
    });

    // Listen for map changes
    _markersSub = controller.markers.listen((_) => _scheduleCameraUpdate());
    _polylinesSub = controller.polylines.listen((_) => _scheduleCameraUpdate());
    _driverSub = controller.driverPosition.listen((_) {
      _scheduleCameraUpdate();
      if (controller.driverPosition.value != null) {
        Get.snackbar(
          'Driver Located',
          'Driver is on the way',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    });
  }

  // ────────────────────────────────────────
  // Camera auto-fit
  // ────────────────────────────────────────
  void _scheduleCameraUpdate() {
    _cameraTimer?.cancel();
    _cameraTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) _updateCamera();
    });
  }

  void _updateCamera() {
    if (_mapController == null || !mounted) return;

    final positions = <LatLng>[];
    if (controller.driverPosition.value != null) {
      positions.add(controller.driverPosition.value!);
    }
    if (controller.markerPosition.value != null) {
      positions.add(controller.markerPosition.value!);
    }
    if (controller.dropOffPosition.value != null) {
      positions.add(controller.dropOffPosition.value!);
    }

    if (positions.isEmpty) return;

    if (positions.length == 1) {
      _mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(positions.first, 16));
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        positions.map((p) => p.latitude).reduce(math.min) - 0.01,
        positions.map((p) => p.longitude).reduce(math.min) - 0.01,
      ),
      northeast: LatLng(
        positions.map((p) => p.latitude).reduce(math.max) + 0.01,
        positions.map((p) => p.longitude).reduce(math.max) + 0.01,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  // ────────────────────────────────────────
  // UI
  // ────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ───── Google Map ─────
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (driverInfoApiController.errorMessage.value.isNotEmpty) {
              return Center(
                child: Text(driverInfoApiController.errorMessage.value),
              );
            }

            return GoogleMap(
              onMapCreated: (c) {
                _mapController = c;
                _scheduleCameraUpdate();
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(23.749341, 90.437213),
                zoom: 15,
              ),
              markers: controller.markers.toSet(),
              polylines: controller.polylines.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
            );
          }),

          // ───── WebSocket status badge ─────
          Positioned(
            top: 50,
            left: 10,
            child: Obx(() {
              final status = controller.webSocketService.connectionStatus;
              final color = status == 'connected'
                  ? Colors.green
                  : status == 'connecting'
                  ? Colors.orange
                  : Colors.red;
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }),
          ),

          // ───── Bottom sheet (always open) ─────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child:  Column(
                children: [
                  // drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // content – switches automatically
                  SizedBox(
                    height: (MediaQuery.of(context).size.height * 0.4) - 20, // Adjust height to account for drag handle
                    child: Obx(() {
                      final ride = driverInfoApiController.rideData.value;
                      return ExpandedBottomSheet6(
                        driverDistance: controller.driverDistance.value,
                        etaMinutes: controller.etaMinutes.value,
                      );
                    }),
                  ),
                ],
              ),
            ),

         /* Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: (MediaQuery.of(context).size.height * 0.4) - 20, // Adjust height to account for drag handle
              child: Obx(() {
                final ride = driverInfoApiController.rideData.value;
                return ExpandedBottomSheet6(
                  driverDistance: controller.driverDistance.value,
                  etaMinutes: controller.etaMinutes.value,
                );
              }),
            ),
          ),*/
          // ───── Loading overlay ─────
          Obx(() => controller.isLoading.value
              ? Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // ────────────────────────────────────────
  // Cleanup
  // ────────────────────────────────────────
  @override
  void dispose() {
    _cameraTimer?.cancel();
    _markersSub?.cancel();
    _polylinesSub?.cancel();
    _driverSub?.cancel();
    _mapController?.dispose();

    if (Get.isRegistered<PickupAcceptController>(tag: 'pickupAccept')) {
      Get.delete<PickupAcceptController>(tag: 'pickupAccept');
    }
    super.dispose();
  }
}