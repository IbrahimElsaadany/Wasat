import "package:flutter/material.dart";
extension SplitCap on String{
  String splitAndCapitalize(){
    final String s = split('-').join(' ');
    return s[0].toUpperCase()+s.substring(1);
  }
}
double getDimension(final BuildContext context, final double factor, {bool isRadius=false})
=> !isRadius&& MediaQuery.of(context).size.width>MediaQuery.of(context).size.height? MediaQuery.of(context).size.width*factor: MediaQuery.of(context).size.height*factor*1.8;