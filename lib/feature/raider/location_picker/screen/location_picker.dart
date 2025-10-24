import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/global_widegts/appBar.dart';
import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../../../../core/style/global_text_style.dart';
import '../../choose_taxi/screen/choose_taxi.dart';
import '../controller/location_picker_controller.dart';

class LocationPicker extends StatelessWidget {
  LocationPicker({super.key});
  final LocationPickerController controller = Get.put(
    LocationPickerController(),
  );

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
                title: "Plan your ride ",
                onLeadingTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),

              // -----------------------------------------------------------------
              //                         PICKUP LOCATION WIDGETS
              // -----------------------------------------------------------------

              Obx(() => controller.selectPickAddress.isEmpty
                  ? Column(
                children: [
                  // --- PICKUP TEXTFIELD ---
                  TextField(
                    textInputAction: TextInputAction.next,
                    controller: controller.searchPickController,
                    cursorColor: Colors.amber,
                    decoration: InputDecoration(
                      labelText: 'Enter pickup location',
                      labelStyle: const TextStyle(color: Colors.black),
                      fillColor: Colors.white,
                      filled: true,
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.amber, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.amber, width: 1),
                      ),
                    ),
                    onChanged: (value) => controller.searchPickPlaces(value),
                  ),
                  // --- Use Current Location Button ---
                  const SizedBox(height: 16),
                  controller.isPickLoading.value
                      ? const Center(child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2))
                      : ElevatedButton.icon(
                    onPressed: () async {
                      await controller.useCurrentPickLocation();
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.my_location, color: Colors.amber),
                    label: const Text('Use Current Location', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: Colors.black12, width: 1),
                    ),
                  ),
                ],
              )
              // --- Selected Pick Address Display/Clear ---
                  : SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton.icon(
                  onPressed: controller.clearPickLocation,
                  icon: const Icon(Icons.location_on, color: Colors.amber),
                  label: Text(
                    controller.selectPickAddress.value,
                    style: globalTextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.withOpacity(0.1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Colors.amber),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              )),

              // --- PICKUP PREDICTIONS LIST ---
              Obx(() {
                if (controller.pickPredictions.isEmpty) {
                  return const SizedBox();
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.pickPredictions.length,
                    itemBuilder: (context, index) {
                      final prediction = controller.pickPredictions[index];
                      return ListTile(
                        title: Text(prediction['description']),
                        onTap: () {
                          controller.selectPickPlace(
                            prediction['place_id'],
                            prediction['description'],
                          );
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                  ),
                );
              }),

              const SizedBox(height: 20),

              // -----------------------------------------------------------------
              //                       DROP-OFF LOCATION WIDGETS
              // -----------------------------------------------------------------

              Obx(() => controller.selectDropOffAddress.isEmpty
                  ? Column(
                children: [
                  // --- DROP-OFF TEXTFIELD ---
                  TextField(
                    textInputAction: TextInputAction.done,
                    controller: controller.searchDropOffController,
                    cursorColor: Colors.green,
                    decoration: InputDecoration(
                      labelText: 'Where to?',
                      labelStyle: const TextStyle(color: Colors.black),
                      fillColor: Colors.white,
                      filled: true,
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.green, width: 1),
                      ),
                    ),
                    onChanged: (value) => controller.searchDropOffPlaces(value),
                  ),
                  // --- Use Current Location Button for Drop-Off (optional, added for completeness) ---
                  const SizedBox(height: 16),
                  /*controller.isDropOffLoading.value
                      ? const Center(child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2))
                      : ElevatedButton.icon(
                    onPressed: () async {
                      await controller.useCurrentDropOffLocation();
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.my_location, color: Colors.green),
                    label: const Text('Use Current Location as Drop-off', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: Colors.black12, width: 1),
                    ),
                  ),*/
                ],
              )
              // --- Selected Drop-Off Address Display/Clear ---
                  : SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton.icon(
                  onPressed: controller.clearDropOffLocation,
                  icon: const Icon(Icons.location_on, color: Colors.green),
                  label: Text(
                    controller.selectDropOffAddress.value,
                    style: globalTextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              )),

              // --- DROP-OFF PREDICTIONS LIST ---
              Obx(() {
                if (controller.dropOffPredictions.isEmpty) {
                  return const SizedBox();
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.dropOffPredictions.length,
                    itemBuilder: (context, index) {
                      final prediction = controller.dropOffPredictions[index];
                      return ListTile(
                        title: Text(prediction['description']),
                        onTap: () {
                          controller.selectDropOffPlace(
                            prediction['place_id'],
                            prediction['description'],
                          );
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                  ),
                );
              }),

              const Spacer(),

              // --- DONE/CONTINUE BUTTON ---
              Obx(
                    () => controller.selectDropOffAddress.isNotEmpty &&
                    controller.selectPickAddress.isNotEmpty
                    ? CustomButton(
                  title: 'Done',
                  backgroundColor: const Color(0xFFFFDC71),
                  borderColor: Colors.transparent,
                  textStyle: globalTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  onPress: () {


                    locationApiCall();


                    // Navigate and pass both pick and drop-off data


                  },
                )
                    : const SizedBox(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> locationApiCall()async{
    Map<String,dynamic>mapBody={
      "pickup": controller.selectPickAddress.value,
      "dropOff": controller.selectDropOffAddress.value,
      "pickupLat": controller.pickLat.value,
      "pickupLng": controller.pickLong.value,
      "dropOffLat": controller.dropOffLat.value,
      "dropOffLng":  controller.dropOffLong.value,
    };

    NetworkResponse response=await NetworkCall.postRequest(url: Urls.pickUpLocation,body: mapBody);

    if(response.isSuccess){
      await AuthController.getUserData();
      print("--------------code---------${response.statusCode}");
      print("-------------Token----------${AuthController.accessToken}");
      print("location find success");
      Get.to(() => ChooseTaxiScreen(), arguments: {
        'pickup': controller.selectPickAddress.value,
        'pickupLat': controller.pickLat.value,
        'pickupLng': controller.pickLong.value,
        'dropOff': controller.selectDropOffAddress.value,
        'dropOffLat': controller.dropOffLat.value,
        'dropOffLng': controller.dropOffLong.value,
      });
    }else{
      print("${response.statusCode}");
    }
}

}



