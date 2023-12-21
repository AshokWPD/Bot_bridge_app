import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../View/LoginView.dart';
import 'NavigateController.dart';

class LocalDB{

  // set Local Data
  static setLDB(String key,String value) async {
     SharedPreferences pref = await SharedPreferences.getInstance();
     pref.setString(key, value);
  }


  // set Local List Data
  static setListLDB(String key, List<String> value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList(key, value);
  }

  // add String to Local List Data
  static addStringToListLDB(String key, String newValue) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> existingList = pref.getStringList(key) ?? [];
    existingList.add(newValue);
    pref.setStringList(key, existingList);
  }

    // Retrieve Local List Data
  static Future<List<String>> getListLDB(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return Future.value(pref.getStringList(key) ?? []);
  }

  //  static deleteListLDB(String key) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   pref.remove(key);
  // }

  // Clear All Local Data && Logout
  static void clearAllLDB(BuildContext context) async {
    NavigateController.pagePush(context, const LoginView());
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

    // Delete Local List Data by Key
  static Future<void> deleteListLDB(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }


  // Retrieve Local Data
  static Future<String> getLDB(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return Future.value(pref.getString(key) ?? '');
  }


}