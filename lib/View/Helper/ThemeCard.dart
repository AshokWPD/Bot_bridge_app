import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class CustomTheme{
  static Color background_green = const Color(0xff6ACE74);
  static Color circle_green = const Color(0xff84DF8F);
  static DateFormat normalDate = DateFormat("dd-MM-yyyy");





}

AnsiPen penwhite = AnsiPen()..white(bold: true);
AnsiPen penblack = AnsiPen()..black(bold: true);
AnsiPen pengreen = AnsiPen()..green(bold: true);
AnsiPen penred = AnsiPen()..red(bold: true);
