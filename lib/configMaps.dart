import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_atm_giver/data_handler/app_data.dart';

String mapKey = "AIzaSyBOeuCyr8oWRaVj5YllGLnicKDXl5Do5Hc";

late User currentFirebaseUser;
late String currentUserName;

late StreamSubscription<Position> homeTabPageStreamSubscription;
