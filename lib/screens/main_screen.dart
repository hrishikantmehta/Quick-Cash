import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_atm/assistants/geofire_assistant.dart';
import 'package:mobile_atm/config_maps.dart';
import 'package:mobile_atm/data_handler/app_data.dart';
import 'package:mobile_atm/models/nearby_available_givers.dart';
import 'package:mobile_atm/screens/chat_list_screen.dart';
import 'package:mobile_atm/screens/chat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const String id = "mainScreen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late Position currentPosition;
  var geoLocator = Geolocator();

  Set<Marker> markerSet = {};
  bool giverKeysLoaded = false;
  bool availableGiverScreenVisibility = false;
  double bottomPaddingOfMap = 0;
  double availableGiverListHeight = 300;

  void _showBottomSheet() {
    scaffoldKey.currentState
        ?.showBottomSheet(
          (context) {
            return Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18.0),
                  topLeft: Radius.circular(18.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 20.0,
                    color: Colors.green,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          GeofireAssistant.nearByAvailableGiversList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: const Icon(
                            Icons.account_circle_outlined,
                            size: 50.0,
                          ),
                          title: Text(
                            GeofireAssistant
                                .nearByAvailableGiversList[index].key
                                .substring(keyLen),
                            style: const TextStyle(
                                fontSize: 16.0, fontFamily: "Brand Bold"),
                          ),
                          trailing: TextButton(
                            onPressed: () {
                              String otherID = GeofireAssistant
                                  .nearByAvailableGiversList[index].key
                                  .substring(0, keyLen);
                              String mergedID;
                              if (currentUserData.id.compareTo(otherID) == 1) {
                                mergedID = currentUserData.id + otherID;
                              } else {
                                mergedID = otherID + currentUserData.id;
                              }

                              print("hello");
                              Navigator.pushNamed(
                                context,
                                ChatScreen.id,
                                arguments: ChatScreenArguments(
                                  mergedID,
                                  GeofireAssistant
                                      .nearByAvailableGiversList[index].key
                                      .substring(keyLen),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.message,
                              color: Colors.green,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          backgroundColor: Colors.white,
        )
        .closed
        .whenComplete(() async {
          // print(GeofireAssistant.nearByAvailableGiversList.length);
          await Geofire.stopListener();
          setState(
            () {
              availableGiverScreenVisibility = false;
              bottomPaddingOfMap = 0;
              markerSet = {};
              GeofireAssistant.nearByAvailableGiversList.clear();
            },
          );
        });
  }

  void locatePosition() async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;
    // print(position.latitude);
    // print(position.longitude);
    LatLng latLangPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLangPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.7633248, 78.8178833),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: !availableGiverScreenVisibility,
        child: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              availableGiverScreenVisibility = true;
              bottomPaddingOfMap = availableGiverListHeight;
              initGeoFireListener();
            });
          },
          label: const Text('Search Nearby'),
          icon: const Icon(Icons.youtube_searched_for),
        ),
      ),
      appBar: AppBar(
        title: const Text('Mobile ATM'),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              SizedBox(
                height: 165.0,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/user_icon.png",
                        height: 65.0,
                        width: 65.0,
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Profile Name",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Brand Bold",
                            ),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text("Visit profile"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // const DividerWidget(),
              const SizedBox(
                height: 12.0,
              ),
              const ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, ChatListScreen.id);
                },
                leading: const Icon(Icons.message),
                title: const Text(
                  "My Chats",
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
              ListTile(
                onTap: () {},
                leading: const Icon(Icons.door_back_door),
                title: const Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              locatePosition();
            },
            markers: markerSet,
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: GestureDetector(
              onTap: locatePosition,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void initGeoFireListener() {
    Geofire.initialize("availableGivers");

    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 2)
        ?.listen((map) {
      // print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            // print("key entered");
            NearByAvailableGiver nearByAvailableGiver = NearByAvailableGiver(
                key: map['key'],
                latitude: map['latitude'],
                longitude: map['longitude']);

            GeofireAssistant.nearByAvailableGiversList
                .add(nearByAvailableGiver);
            if (giverKeysLoaded == true) updateAvailableGiversOnMap();
            break;

          case Geofire.onKeyExited:
            // print("key exited");
            GeofireAssistant.removeGiverFromList(map['key']);
            updateAvailableGiversOnMap();
            break;

          case Geofire.onKeyMoved:
            // print("key moved");
            NearByAvailableGiver nearByAvailableGiver = NearByAvailableGiver(
                key: map['key'],
                latitude: map['latitude'],
                longitude: map['longitude']);

            GeofireAssistant.updateGiverLocation(nearByAvailableGiver);
            updateAvailableGiversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableGiversOnMap();
            _showBottomSheet();
            break;
        }
      }

      setState(() {});
    });
  }

  void updateAvailableGiversOnMap() {
    setState(() {
      markerSet.clear();
    });

    Set<Marker> tMarker = <Marker>{};

    for (NearByAvailableGiver giver
        in GeofireAssistant.nearByAvailableGiversList) {
      LatLng giverPosition = LatLng(giver.latitude, giver.longitude);

      Marker marker = Marker(
        infoWindow: InfoWindow(
          title: giver.key.substring(keyLen),
        ),
        markerId: MarkerId(giver.key),
        position: giverPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      tMarker.add(marker);
    }

    setState(() {
      giverKeysLoaded = true;
      markerSet = tMarker;
    });
  }
}
