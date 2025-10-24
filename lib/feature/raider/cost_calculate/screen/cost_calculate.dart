import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/global_widegts/appBar.dart';
import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/style/global_text_style.dart';
import '../controller/cost_calculate_controller.dart';
import '../controller/cost_controller.dart';
import 'cost_calculate_location.dart';

class CostCalculate extends StatelessWidget {
  CostCalculate({super.key});
  final CostCalculateController controller = Get.put(CostCalculateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomAppBar(
                title: "Costing calculation",
                onLeadingTap: () => Navigator.pop(context),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => Get.to(() => CostCalculateLocation()),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: Color(0xFFF0F0F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First row
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.black),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enter pick up and drop up location",
                                style: globalTextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF777F8B),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                controller.selectPickAddress.value,
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

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



class CostCalculateSheet extends StatelessWidget {
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;

  const CostCalculateSheet({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
  });

  @override
  Widget build(BuildContext context) {
    final fareController = Get.find<FareController>();

    // Use calculated fare from backend if available, otherwise fallback to client calculation
    double totalFare = 0.0;
    double distanceKm = 0.0;

    if (fareController.calculatedFare.value != null) {
      // Use backend calculated fare
      totalFare = fareController.calculatedFare.value!.totalFare ?? 0.0;
      distanceKm = fareController.calculatedFare.value!.distance ?? 0.0;
      print("🎯 Using backend calculated fare: $totalFare, distance: $distanceKm");
    } else {
      // Fallback to client-side calculation
      distanceKm = fareController.calculateDistance(
        pickupLat,
        pickupLng,
        dropLat,
        dropLng,
      );
      totalFare = fareController.calculateTotalFare(distanceKm);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.1,
      maxChildSize: 0.6,
      builder: (BuildContext context, ScrollController scrollController) {
        return Obx(() {
          if (fareController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final fare = fareController.fare.value;
          final calculatedFare = fareController.calculatedFare.value;

          print("🔍 Debug - fare: ${fare?.totalFare}");
          print("🔍 Debug - calculatedFare: ${calculatedFare?.totalFare}");
          print("🔍 Debug - calculatedFare distance: ${calculatedFare?.distance}");

          if (fare == null) {
            return const Center(child: Text("No fare data available"));
          }


          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
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
                    child: Text(
                      "Price Breakdown",
                      style: globalTextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const Divider(),
                  Text(
                    "Your fare will be the price presented before the trip or based on the rates below and other applicable surcharges and adjustments",
                    style: globalTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/car2.png",
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),

                  // Show backend calculated fare if available, otherwise show base fare rates
                  if (calculatedFare != null) ...[
                    // Backend calculated fare breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Distance", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("${calculatedFare.distance?.toStringAsFixed(2) ?? '0.00'} km", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Duration", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("${calculatedFare.duration ?? 0} min", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Base Fare", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("LBP${calculatedFare.baseFare?.toStringAsFixed(2) ?? '0.00'}", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ] else ...[
                    // Base fare rates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Base Fare", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("LBP ${fare.baseFare.toStringAsFixed(2)}", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Minimum Fare", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("LBP ${fare.minimumFare.toStringAsFixed(2)}", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("+ Per Minute", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("LBP ${fare.costPerMin.toStringAsFixed(2)}", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("+ Per Kilometer", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("LBP ${fare.costPerKm.toStringAsFixed(2)}", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),

                  Text(
                    "Additional wait time charges may apply: LBP ${calculatedFare?.waitingPerMin?.toStringAsFixed(2) ?? fare.waitingPerMin.toStringAsFixed(2)} per minute.",
                    style: globalTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // 👉 এখানে শুধু Extra Estimated Fare দেখাচ্ছি (design change না করে)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Estimated Fare", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text("LBP ${totalFare.toStringAsFixed(2)}", style: globalTextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),

                  const SizedBox(height: 20),
                  CustomButton(
                    title: "Close",
                    borderColor: Colors.transparent,
                    backgroundColor: const Color(0xFFFFDC71),
                    onPress: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

