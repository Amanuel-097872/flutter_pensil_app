import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pensil_app/ui/theme/light_color.dart';

class Ploader extends StatelessWidget {
  final double stroke;

  const Ploader({Key key, this.stroke = 4}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Platform.isAndroid
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(PColors.blue),
              strokeWidth: stroke,
            )
          : CupertinoActivityIndicator(),
    );
  }
}


class PCLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 60,
      child: SizedBox(
        height: 30,
        width: 30,
        child: Ploader(stroke: 1),
      ),
    );
  }
}