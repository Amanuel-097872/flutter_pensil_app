import 'package:flutter/material.dart';
import 'package:flutter_pensil_app/states/home_state.dart';
import 'package:flutter_pensil_app/ui/page/home/widget/poll_widget.dart';
import 'package:flutter_pensil_app/ui/widget/secondary_app_bar.dart';
import 'package:provider/provider.dart';

class ViewAllPollPage extends StatelessWidget {
  const ViewAllPollPage({Key key}) : super(key: key);
  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
      builder: (_) => ViewAllPollPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar("All Polls"),
      body: Consumer<HomeState>(
        builder: (context, state, child) {
          return Container(
            child: ListView.builder(
              itemCount: state.allPolls.length,
              itemBuilder: (context, index) {
                return PollWidget(model: state.allPolls[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
