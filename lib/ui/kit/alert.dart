import 'package:flutter/material.dart';
import 'package:flutter_pensil_app/helper/images.dart';
import 'package:flutter_pensil_app/ui/theme/theme.dart';
import 'package:flutter_pensil_app/ui/widget/p_button.dart';

class Alert {
  static void sucess(BuildContext context,
      {String message,
      String title,
      double height = 150,
      Function onPressed}) async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          height: height, //MediaQuery.of(context).size.height * .3,
          width: MediaQuery.of(context).size.width * .75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).typography.dense.bodyMedium.copyWith(
                      color: Colors.black,
                    ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPressed();
                                },
                color: Theme.of(context).primaryColor,
                child: Text("OK",
                    style: theme.textTheme.labelLarge
                        .copyWith(color: theme.colorScheme.onPrimary)),
              )
            ],
          ),
        ),
      ),
    );
  }

  static void yesOrNo(BuildContext context,
      {String message,
      String title,
      Function onYes,
      Function onCancel,
      bool barrierDismissible = true}) async {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          width: MediaQuery.of(context).size.width * .75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title,
                  style: Theme.of(context)
                      .typography
                      .dense
                      .titleLarge
                      .copyWith(color: Colors.black)),
              SizedBox(height: 12),
              Text(message,
                  style: Theme.of(context).typography.dense.bodyMedium.copyWith(
                      color: Colors.black, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center),
              SizedBox(height: 16),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                buttonAlignedDropdown: true,
                buttonPadding: EdgeInsets.all(0),
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel")),
                  SizedBox(width: 12),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onYes();
                                        },
                    child: Text("Confirm", textAlign: TextAlign.center),
                    elevation: 1,
                    color: Theme.of(context).primaryColor,
                    padding:
                        EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  static void dialog(BuildContext context,
      {String title,
      Widget child,
      Function onPressed,
      Color titleBackGround = PColors.orange,
      String buttonText = "Ok",
      bool enableCrossButton = true}) async {
    final theme = Theme.of(context);
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Wrap(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: titleBackGround,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width - 160,
                              child: Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    .copyWith(
                                        color: theme.colorScheme.onPrimary),
                                // maxLines: 1,
                                // overflow: TextOverflow.ellipsis,
                              )).vP8,
                          // Spacer(),
                          Image.asset(Images.cross, height: 30).p(8).ripple(() {
                            if (enableCrossButton) Navigator.pop(context);
                          })
                        ],
                      )),
                  child,
                  SizedBox(
                    height: 12,
                  ),
                  PFlatButton(
                    label: buttonText,
                    onPressed: onPressed,
                  ).hP16
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
