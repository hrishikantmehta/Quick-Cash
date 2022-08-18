import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_atm_giver/configMaps.dart';
import 'package:mobile_atm_giver/screens/registration_screen.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;
  late Position currentPosition;
  var geoLocator = Geolocator();
  String giverStatusText = "Offline Now - Go Online";
  Color giverStatusColor = Colors.black;
  bool isGiverAvailable = false;

  void locatePosition() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: HomeTabPage._kGooglePlex,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              // locatePosition();
            },
            padding: const EdgeInsets.only(top: 120.0),
          ),

          //online offline container
          Container(
            height: 120,
            width: double.infinity,
            color: Colors.black54,
          ),

          Positioned(
            top: 30.0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (isGiverAvailable != true) {
                        makeGiverOnline();
                        getLocationLiveUpdates();

                        setState(() {
                          giverStatusColor = Colors.green;
                          giverStatusText = "Online Now - Go Offline";
                          isGiverAvailable = true;
                        });

                        displayToastMessage("You are Online Now", context);
                      } else {
                        makeGiverOffline();

                        setState(() {
                          giverStatusColor = Colors.black;
                          giverStatusText = "Offline Now - Go Online";
                          isGiverAvailable = false;
                        });

                        displayToastMessage("You are Offline Now", context);
                      }
                    },
                    color: giverStatusColor,
                    child: Padding(
                      padding: const EdgeInsets.all(17.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            giverStatusText,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(
                            Icons.phone_android,
                            color: Colors.white,
                            size: 26.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void makeGiverOnline() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize("availableGivers");
    Geofire.setLocation(currentFirebaseUser.uid + currentUserName,
        currentPosition.latitude, currentPosition.longitude);
  }

  void getLocationLiveUpdates() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;

      if (isGiverAvailable == true) {
        Geofire.setLocation(currentFirebaseUser.uid + currentUserName,
            position.latitude, position.longitude);
      }

      LatLng latLang = LatLng(position.latitude, position.longitude);

      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLang));
    });
  }

  void makeGiverOffline() {
    Geofire.removeLocation(currentFirebaseUser.uid + currentUserName);
  }
}
