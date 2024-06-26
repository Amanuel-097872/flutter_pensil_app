import 'package:flutter/material.dart';
import 'package:flutter_pensil_app/helper/images.dart';
import 'package:flutter_pensil_app/model/actor_model.dart';
import 'package:flutter_pensil_app/states/home_state.dart';
import 'package:flutter_pensil_app/ui/kit/overlay_loader.dart';
import 'package:flutter_pensil_app/ui/page/announcement/create_announcement.dart';
import 'package:flutter_pensil_app/ui/page/batch/create_batch/create_batch.dart';
import 'package:flutter_pensil_app/ui/page/home/home_Scaffold.dart';
import 'package:flutter_pensil_app/ui/page/home/widget/announcement_widget.dart';
import 'package:flutter_pensil_app/ui/page/home/widget/batch_widget.dart';
import 'package:flutter_pensil_app/ui/page/home/widget/poll_widget.dart';
import 'package:flutter_pensil_app/ui/page/poll/View_all_poll_page.dart';
import 'package:flutter_pensil_app/ui/page/poll/create_poll.dart';
import 'package:flutter_pensil_app/ui/theme/theme.dart';
import 'package:flutter_pensil_app/ui/widget/fab/fab_button.dart';
import 'package:flutter_pensil_app/ui/widget/p_title_text.dart';
import 'package:provider/provider.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({Key key}) : super(key: key);
  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(builder: (_) => TeacherHomePage());
  }

  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage>
    with TickerProviderStateMixin {
  double _angle = 0;
  AnimationController _controller;
  bool isOpened = false;
  AnimationController _animationController;
  Animation<double> _animateIcon;
  CustomLoader loader;
  Curve _curve = Curves.easeOut;
  Animation<double> _translateButton;
  ValueNotifier<bool> showFabButton = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    setupAnimations();
    loader = CustomLoader();
    context.read<HomeState>().getBatchList();
    context.read<HomeState>().getAnnouncemantList();
    context.read<HomeState>().getPollList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _angle = .785;
      _animationController.forward();
    } else {
      _angle = 0;
      _animationController.reverse();
    }
    isOpened = !isOpened;
    showFabButton.value = !showFabButton.value;
  }

  setupAnimations() {
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _controller.repeat();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _translateButton = Tween<double>(
      begin: 100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        1,
        curve: _curve,
      ),
    ));
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: animate,
      tooltip: 'Toggle',
      child: Transform.rotate(
        angle: _angle,
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }

  Widget _floatingActionButtonColumn() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: showFabButton.value ? 1 : 0,
      child: Column(
        children: <Widget>[
          FabButton(
            icon: Images.megaphone,
            text: 'Create Poll',
            animationValue: 3,
            translateButton: _translateButton,
            onPressed: () {
              animate();
              Navigator.push(context, CreatePoll.getRoute());
            },
          ),
          FabButton(
            icon: Images.peopleWhite,
            text: 'Create Batch',
            animationValue: 2,
            translateButton: _translateButton,
            onPressed: () {
              animate();
              Navigator.push(context, CreateBatch.getRoute());
            },
          ),
          FabButton(
            icon: Images.announcements,
            text: 'Create Announcement',
            translateButton: _translateButton,
            animationValue: 1,
            onPressed: () {
              animate();
              Navigator.push(context, CreateAnnouncement.getRoute());
            },
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
        padding: EdgeInsets.only(
          top: 8,
          left: 16,
        ),
        child: PTitleText(text));
  }

  @override
  Widget build(BuildContext context) {
    return HomeScaffold<HomeState>(
      floatingButtons: _floatingActionButtonColumn(),
      floatingActionButton: _floatingActionButton(),
      onNotificationTap: () {
        print("Notoficaion");
      },
      builder: (context, state, child) {
        return CustomScrollView(
          slivers: <Widget>[
            FutureBuilder(
              future: state.getUser(),
              builder: (context, AsyncSnapshot<ActorModel> snapShot) {
                if (snapShot.hasData) {
                  return SliverToBoxAdapter(
                    child: Text("Hi, ${snapShot.data.name}",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                .copyWith(fontSize: 22))
                        .hP16
                        .pT(10),
                  );
                } else {
                  return SliverToBoxAdapter(child: SizedBox.shrink());
                }
              },
            ),
            if (!(state.batchList.isNotEmpty))
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _title("Batches"),
                    SizedBox(height: 20),
                    Container(
                      height: 100,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: AppTheme.outline(context),
                      width: AppTheme.fullWidth(context),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("You haven't created any batch yet",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  .copyWith(
                                    color: PColors.gray,
                                  )),
                          SizedBox(height: 10),
                          Text("Tap on below fab button to create new",
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                    SizedBox(height: 20)
                  ],
                ),
              ),
            if (state.batchList.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("You have ${state.batchList.length} Batches"),
                    SizedBox(height: 5),
                    Container(
                      height: 150,
                      width: AppTheme.fullWidth(context),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.batchList.length,
                        itemBuilder: (context, index) {
                          return BatchWidget(state.batchList[index]);
                        },
                      ),
                    ),
                    SizedBox(height: 10)
                  ],
                ),
              ),
            ...[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Divider(),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0)
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _title("Poll"),
                        OutlineButton(
                          onPressed: () {
                            Navigator.push(
                                context, ViewAllPollPage.getRoute());
                          },
                          textColor: Theme.of(context).primaryColor,
                          highlightedBorderColor:
                              Theme.of(context).primaryColor,
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          child: Text("View All"),
                        ).hP16
                      ],
                    );
                  return PollWidget(
                      model: state.polls[index - 1], loader: loader);
                },
                childCount: state.polls.length + 1,
              ),
            ),
            SliverToBoxAdapter(
              child: Divider(),
            ),
          ],
            if (state.announcementList.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0)
                      return _title(
                          "${state.announcementList.length} Announcement");
                    return AnnouncementWidget(
                      state.announcementList[index - 1],
                      loader: loader,
                      onAnnouncementEdit: (model) {
                        Navigator.push(
                          context,
                          CreateAnnouncement.getEditRoute(
                            announcementModel: model,
                            onAnnouncementCreated: () {
                              context.read<HomeState>().getAnnouncemantList();
                            },
                          ),
                        );
                      },
                    );
                  },
                  childCount: state.announcementList.length + 1,
                ),
              ),
          ],
        );
      },
    );
  }
}
