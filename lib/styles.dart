import 'package:flutter/material.dart';

List<BoxShadow> boxShadows = [
  BoxShadow(blurRadius: 7.0, offset: Offset(-7, -7), color: Colors.grey[300]),
  BoxShadow(blurRadius: 7.0, offset: Offset(7, -7), color: Colors.grey[300]),
  BoxShadow(blurRadius: 7.0, offset: Offset(-7, 7), color: Colors.grey[300]),
  BoxShadow(blurRadius: 7.0, offset: Offset(7, 7), color: Colors.grey[300]),
];

TextStyle regularFontSize = TextStyle(
  fontSize: 17.0,
);

TextStyle largeFontSize = TextStyle(
  fontSize: 19.0
);