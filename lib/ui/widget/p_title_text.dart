import 'package:flutter/material.dart';

class PTitleText extends StatelessWidget {
  const PTitleText(this.text, {Key key}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall.copyWith(
            fontSize: 20,
          ),
    );
  }
}

class PTitleTextBold extends StatelessWidget {
  const PTitleTextBold(this.text, {Key key}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge.copyWith(
            fontSize: 20,
          ),
    );
  }
}
