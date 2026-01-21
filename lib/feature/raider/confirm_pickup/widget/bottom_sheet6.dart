import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Added for phone call functionality
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../../../../core/style/global_text_style.dart';
import '../../../friends/screen/chat_screen.dart';
import '../../chat/screen/chat_screen.dart';
import '../../pickup_accept/controler/pickup_accept_controller.dart';
// TODO: Replace with actual ChatScreen import
// import '../path_to_chat_screen.dart';

class ExpandedBottomSheet6 extends StatelessWidget {
  final String driverDistance;
  final String etaMinutes;

  const ExpandedBottomSheet6({
    super.key,
    required this.driverDistance,
    required this.etaMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final PickupAcceptController controller = Get.find<PickupAcceptController>(tag: 'pickupAccept');

    debugPrint("🧱 ExpandedBottomSheet6 build: driverDistance=$driverDistance, etaMinutes=$etaMinutes");

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            final rideData = controller.driverInfoApiController.rideData.value;
            debugPrint("📡 [Obx] BottomSheet rebuild: driverDistance=${controller.driverDistance.value}, etaMinutes=${controller.etaMinutes.value}");

            final pickupTime = rideData?.pickupTime != null
                ? "Pickup at ${_formatPickupTime(rideData!.pickupTime!)}"
                : "Pickup time not available";

            final imageUrl = (rideData?.vehicle?.driver?.profileImage != null && rideData!.vehicle!.driver!.profileImage!.isNotEmpty)
                ? (rideData.vehicle!.driver!.profileImage!.startsWith('http')
                ? rideData.vehicle!.driver!.profileImage!
                : 'https://brother-taxi.onrender.com${rideData.vehicle!.driver!.profileImage!}')
                : null;

            if (controller.driverInfoApiController.isLoading.value && rideData == null) {
              debugPrint("⏳ [UI] Loading driver info from API...");
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!controller.driverInfoApiController.isLoading.value && rideData == null) {
              debugPrint("🚫 No driver data available");
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "Loading, please wait…",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(
                          pickupTime,
                          style: globalTextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Driver Distance: ${controller.driverDistance.value.isEmpty ? 'Waiting for driver location...' : controller.driverDistance.value}",
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "ETA: ${controller.etaMinutes.value.isEmpty ? 'Waiting for driver location...' : controller.etaMinutes.value}",
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFB),
                      border: Border.all(width: 1, color: const Color(0xFFEDEDF3)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ride details",
                                style: globalTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF041023),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Meet at the pickup point",
                                style: globalTextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        /*Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              debugPrint("🧭 Option button tapped - switching sheet index.");
                              controller.toggleBottomSheet();
                            },
                            child: Image.asset(
                              "assets/images/option_button.png",
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFB),
                      border: Border.all(width: 1, color: const Color(0xFFEDEDF3)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: imageUrl != null
                                  ? Image.network(
                                imageUrl,
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const CircularProgressIndicator();
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint("❌ Error loading driver image: $error");
                                  return Image.asset(
                                    'assets/images/Ellipse 459 (2).png',
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                                  : Image.asset(
                                'assets/images/Ellipse 459 (2).png',
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rideData?.vehicle?.driver?.fullName ?? "Unknown Driver",
                                    overflow: TextOverflow.ellipsis,
                                    style: globalTextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 18, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          "${rideData?.vehicle?.driver?.averageRating?.toStringAsFixed(1) ?? 'N/A'} (${rideData?.vehicle?.driver?.reviewCount ?? 0} reviews)",
                                          overflow: TextOverflow.ellipsis,
                                          style: globalTextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF454F60),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.network(
                              rideData?.vehicle?.image ?? "assets/images/car2.png",
                              height: 80,
                              width: 160,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint("❌ Error loading vehicle image: $error");
                                return Image.asset(
                                  'assets/images/car2.png',
                                  height: 80,
                                  width: 160,
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ===== Chat & Call Buttons Section =====
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text("Chat"),
                          onPressed: () {
                            final idForChat = rideData?.id ?? '';
                            debugPrint("💬 Chat tapped - idForChat=$idForChat");
                            if (idForChat.isNotEmpty) {
                              // TODO: Replace with actual ChatScreen navigation
                               //Get.to(() => ChatScreen(carTransportId: idForChat,));
                               Get.to(() => ChatScreen(carTransportId: idForChat, token: "${AuthController.accessToken}",));
                              Get.snackbar("Info", "ChatScreen navigation not implemented yet.");
                            } else {
                              debugPrint("❌ Chat failed: Ride ID not available.");
                              Get.snackbar("Error", "Ride ID is not available for chat.");
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                      onTap: () async {
            final phone = rideData?.vehicle?.driver?.phoneNumber ?? '';
            debugPrint("Attempting to call: $phone");

            if (phone.isEmpty) {
            Get.snackbar("Error", "Driver's phone number is not available.");
            return;
            }

            final uri = Uri.parse("tel:$phone");

            try {
            bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (launched) {
            debugPrint("✅ Dialer opened successfully");
            } else {
            debugPrint("❌ Failed to open dialer");
            Get.snackbar("Error", "Could not open the phone dialer.");
            }
            } catch (e) {
            debugPrint("❌ Exception: $e");
            Get.snackbar("Error", "Could not open the phone dialer.");
            }
            },
                        child: Image.asset(
                          "assets/images/call.png",
                          height: 60,
                          width: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  String _formatPickupTime(String time24) {
    try {
      final parsedTime = DateFormat("HH:mm").parse(time24);
      return DateFormat.jm().format(parsedTime);
    } catch (e) {
      debugPrint("❌ Error formatting pickup time: $e");
      return time24;
    }
  }
}