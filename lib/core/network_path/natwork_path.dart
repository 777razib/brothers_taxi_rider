class NetworkPath{
  static const String _local_url="http://72.61.163.212:5006/api/v1";
  static const String login="${_local_url}/users/create-user/register";
  static const String authVerifyLogin="${_local_url}/auth/verify-login";
  static const String getMe="$_local_url/users/get-me";
  static const String updateProfile="$_local_url/users/update-profile";
  static const String myRidesHistory="$_local_url/carTransports/my-rides-history";
  static const String getCurrentFare="$_local_url/fares/current";
}
class APIKeys {
  static const String googleApiKey = "AIzaSyC7AoMhe2ZP3iHflCVr6a3VeL0ju0bzYVE";

}