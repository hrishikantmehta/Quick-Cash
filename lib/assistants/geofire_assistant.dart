import 'package:mobile_atm/models/nearby_available_givers.dart';

class GeofireAssistant {
  static List<NearByAvailableGiver> nearByAvailableGiversList = [];

  static void removeGiverFromList(String key) {
    int index =
        nearByAvailableGiversList.indexWhere((element) => element.key == key);

    nearByAvailableGiversList.removeAt(index);
  }

  static void updateGiverLocation(NearByAvailableGiver giver) {
    int index = nearByAvailableGiversList
        .indexWhere((element) => element.key == giver.key);

    nearByAvailableGiversList[index].longitude = giver.longitude;
    nearByAvailableGiversList[index].latitude = giver.latitude;
  }
}
