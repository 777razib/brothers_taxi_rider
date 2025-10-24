import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../../../../core/style/global_text_style.dart';
import '../../../auth/login/view/login_view.dart';
import '../../my_rides/screen/my_rides.dart';
import '../../privacy_policy/screen/privacy_policy.dart';
import '../../ride_complete.dart/screen/ride_complete.dart';
import '../controller/profile_edit_controller.dart';
import '../widget/notification_widget.dart';
import '../widget/profile_action_widgets.dart';
import '../widget/profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final UpdateProfileController updateProfileController = Get.put(UpdateProfileController());


class _ProfileScreenState extends State<ProfileScreen> {


  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void fetchProfileData() async {
    final profile = await updateProfileController.fetchMyProfile();
    if (profile?.profileImage != null) {
      updateProfileController.fullNameController.text = profile?.fullName ?? '';
      updateProfileController.emailController.text = profile?.email ?? '';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ()async{
            updateProfileController.fetchMyProfile();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    "Profile",
                    style: globalTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 1, color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => ProfileEditScreen());
                            },
                            child: Image.asset(
                              "assets/images/edit.png",
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Obx(() {
                              final user = updateProfileController.userData.value;
                              final profileImage = user?.profileImage ?? '';
                              final selectedImage = updateProfileController.selectedImage.value;

                              return Center(
                                child: GestureDetector(
                                  onTap: updateProfileController.pickImage,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: selectedImage != null
                                        ? FileImage(selectedImage)
                                        : (profileImage.isNotEmpty
                                        ? NetworkImage(profileImage)
                                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider),
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(height: 12),
                            Text(
                              updateProfileController.fullNameController.text,
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              updateProfileController.emailController.text,
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                            ),


                            Divider(),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        Text(
                                          "My Rating",
                                          style: globalTextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF777F8B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "4.8",
                                      style: globalTextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        Text(
                                          "Total Distance ",
                                          style: globalTextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF777F8B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "55.09KM",
                                      style: globalTextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.electric_bike,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        Text(
                                          "Total ride",
                                          style: globalTextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF777F8B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "20",
                                      style: globalTextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 21),
                  NotificationWidget(
                    tagId: "Notification",
                    image: "assets/icons/notification.png",
                    actionName: "Notification",
                    style: globalTextStyle(),
                    voidCallback: () => print("Switch toggled"),
                  ),
                  const SizedBox(height: 21),
                  ProfileActionWidgets(
                    image: "assets/icons/car.png",
                    actionName: "My rides",
                    style: globalTextStyle(),
                    voidCallback: () {
                      Get.to(() => MyRides());

                      //  Get.snackbar("Hello", "");
                    },
                    iconData: (Icons.arrow_forward_ios),
                    size: 18,
                  ),
                  const SizedBox(height: 21),
                  ProfileActionWidgets(
                    image: "assets/icons/car.png",
                    actionName: "Completed rides",
                    style: globalTextStyle(),
                    voidCallback: () {
                      Get.to(() => RideCompletedScreen());

                      //  Get.snackbar("Hello", "");
                    },
                    iconData: (Icons.arrow_forward_ios),
                    size: 18,
                  ),
                  const SizedBox(height: 21),
                  ProfileActionWidgets(
                    image: "assets/icons/terms.png",
                    actionName: "Privacy policy",
                    style: globalTextStyle(),
                    voidCallback: () {
                      Get.to(() => PrivacyPolicy());
                    },
                    iconData: (Icons.arrow_forward_ios),
                    size: 18,
                  ),
                  const SizedBox(height: 21),
                  ProfileActionWidgets(
                    image: "assets/icons/logout.png",
                    actionName: "Log out",
                    style: globalTextStyle(),
                    voidCallback: () {
                      AuthController.dataClear();
                      Get.to(() => LoginView());
                    },
                    iconData: (Icons.arrow_forward_ios),
                    size: 18,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
