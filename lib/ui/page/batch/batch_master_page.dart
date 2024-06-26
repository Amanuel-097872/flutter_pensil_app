
import 'package:flutter/material.dart';
import 'package:flutter_pensil_app/helper/images.dart';
import 'package:flutter_pensil_app/model/batch_model.dart';
import 'package:flutter_pensil_app/states/home_state.dart';
import 'package:flutter_pensil_app/states/quiz/quiz_state.dart';
import 'package:flutter_pensil_app/states/teacher/announcement_state.dart';
import 'package:flutter_pensil_app/states/teacher/batch_detail_state.dart';
import 'package:flutter_pensil_app/states/teacher/material/batch_material_state.dart';
import 'package:flutter_pensil_app/states/teacher/video/video_state.dart';
import 'package:flutter_pensil_app/ui/kit/alert.dart';
import 'package:flutter_pensil_app/ui/kit/overlay_loader.dart';
import 'package:flutter_pensil_app/ui/page/announcement/create_announcement.dart';
import 'package:flutter_pensil_app/ui/page/batch/create_batch/create_batch.dart';
import 'package:flutter_pensil_app/ui/page/batch/pages/batch_assignment_page.dart';
import 'package:flutter_pensil_app/ui/page/batch/pages/material/batch_study_material_page.dart';
import 'package:flutter_pensil_app/ui/page/batch/pages/detail/batch_detail_page.dart';
import 'package:flutter_pensil_app/ui/page/batch/pages/material/upload_material.dart';
import 'package:flutter_pensil_app/ui/page/batch/pages/video/add_video_page.dart';
import 'package:flutter_pensil_app/ui/page/batch/pages/video/batch_videos_page.dart';
import 'package:flutter_pensil_app/model/choice.dart';
import 'package:flutter_pensil_app/ui/theme/theme.dart';
import 'package:flutter_pensil_app/ui/widget/fab/animated_fab.dart';
import 'package:flutter_pensil_app/ui/widget/fab/fab_button.dart';
import 'package:provider/provider.dart';

class BatchMasterDetailPage extends StatefulWidget {
  BatchMasterDetailPage({Key key, this.model, this.isTeacher})
      : super(key: key);
  final BatchModel model;
  final bool isTeacher;
  static MaterialPageRoute getRoute(BatchModel model, {bool isTeacher}) {
    return MaterialPageRoute(
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VideoState(batchId: model.id)),
          ChangeNotifierProvider(
              create: (_) => BatchDetailState(batchId: model.id)),
          ChangeNotifierProvider(
              create: (_) => BatchMaterialState(batchId: model.id)),
          ChangeNotifierProvider(
              create: (_) => AnnouncementState(batchId: model.id)),
          ChangeNotifierProvider(create: (_) => QuizState(batchId: model.id)),
        ],
        builder: (_, child) =>
            BatchMasterDetailPage(model: model, isTeacher: isTeacher),
      ),
    );
  }

  @override
  _BatchMasterDetailPageState createState() => _BatchMasterDetailPageState();
}

class _BatchMasterDetailPageState extends State<BatchMasterDetailPage>
    with TickerProviderStateMixin {
  double _angle = 0;
  BatchModel model;
  AnimationController _controller;
  TabController _tabController;
  bool isOpened = false;
  AnimationController _animationController;
  Curve _curve = Curves.easeOut;
  CustomLoader loader;
  Animation<double> _translateButton;
  ValueNotifier<bool> showFabButton = ValueNotifier<bool>(false);
  ValueNotifier<int> currentPageNo = ValueNotifier<int>(0);

  List<Choice> choices = [
    Choice(title: 'Edit', index: 0),
    Choice(title: 'Delete', index: 1),
  ];

  @override
  void initState() {
    super.initState();
    loader = CustomLoader();
    model = widget.model;
    setupAnimations();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(tabListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<VideoState>(context, listen: false).getVideosList();
      Provider.of<BatchMaterialState>(context, listen: false)
          .getBatchMaterialList();
      Provider.of<AnnouncementState>(context, listen: false)
          .getBatchAnnouncementList();
      Provider.of<QuizState>(context, listen: false).getQuizList();
      Provider.of<BatchDetailState>(context, listen: false).getBatchTimeLine();
    });
    super.initState();
  }

  tabListener() {
    currentPageNo.value = _tabController.index;
  }

  @override
  void dispose() {
    showFabButton.dispose();
    _animationController.dispose();
    _tabController.dispose();
    _controller.dispose();
    currentPageNo.dispose();
    super.dispose();
  }

  setupAnimations() {
    if (!widget.isTeacher) {
      return;
    }
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _controller.repeat();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            setState(() {});
          });

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

  animate() {
    if (!isOpened) {
      _angle = .785;
      _animationController.forward();
    } else {
      _angle = 0;
      _animationController.reverse();
      _angle = 0;
    }
    isOpened = !isOpened;
    showFabButton.value = !showFabButton.value;
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

  List<Widget> _floatingButtons(int index) {
    return <Widget>[
      if (index != 5) ...[
        FabButton(
          icon: Images.edit,
          text: 'Add  Video',
          translateButton: _translateButton,
          animationValue: 3,
          onPressed: () {
            animate();
            Navigator.push(
              context,
              AddVideoPage.getRoute(
                subject: model.subject,
                batchId: model.id,
                state: Provider.of<VideoState>(context, listen: false),
              ),
            );
          },
        ),
        FabButton(
          icon: Images.upload,
          text: 'Upload Material',
          animationValue: 2,
          translateButton: _translateButton,
          onPressed: () {
            animate();
            Navigator.push(
                context,
                UploadMaterialPage.getRoute(
                  model.subject,
                  model.id,
                  state:
                      Provider.of<BatchMaterialState>(context, listen: false),
                ));
          },
        ),
        FabButton(
          icon: Images.announcements,
          text: 'Add Announcement',
          translateButton: _translateButton,
          animationValue: 1,
          onPressed: () {
            animate();
            final model = widget.model;
            model.isSelected = true;
            Navigator.push(
                context,
                CreateAnnouncement.getRoute(
                  batch: model,
                  onAnnouncementCreated: onAnnouncementCreated,
                ));
          },
        ),
      ],
    ];
  }

  // if an announcement is created or edited then
  // refresh timelime api
  void onAnnouncementCreated() async {
    Provider.of<AnnouncementState>(context, listen: false)
        .getBatchAnnouncementList();

    context.read<BatchDetailState>().getBatchTimeLine();
  }

  void deleteBatch() async {
    Alert.yesOrNo(context,
        message: "Are you sure, you want to delete this batch ?",
        title: "Message",
        barrierDismissible: true,
        onCancel: () {}, onYes: () async {
      loader.showLoader(context);
      final isDeleted = await Provider.of<HomeState>(context, listen: false)
          .deleteBatch(widget.model.id);
      if (isDeleted) {
        Navigator.pop(context);
      }
      loader.hideLoader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton:
            !widget.isTeacher ? null : _floatingActionButton(),
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).textTheme.bodyLarge.color,
            tabs: [
              Tab(text: "Detail"),
              Tab(text: "Videos"),
              Tab(text: "Quiz"),
              Tab(text: "Study Material"),
            ],
          ),
          title: Title(
            color: PColors.black,
            child: Text(model.name),
          ),
          actions: [
            if (widget.isTeacher)
              PopupMenuButton<Choice>(
                onSelected: (d) {
                  if (d.index == 1) {
                    deleteBatch();
                  } else if (d.index == 0) {
                    Navigator.push(
                        context, CreateBatch.getRoute(model: widget.model));
                  }
                },
                padding: EdgeInsets.zero,
                offset: Offset(40, 20),
                color: Colors.white,
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                        value: choice, child: Text(choice.title));
                  }).toList();
                },
              ),
            // Center(
            //   child: SizedBox(
            //     height: 40,
            //     child: OutlineButton(
            //         onPressed: () {
            //           Navigator.push(
            //               context, CreateBatch.getRoute(model: widget.model));
            //         },
            //         child: Text("Edit")),
            //   ),
            // ).hP16,
          ],
        ),
        body: Stack(
          children: <Widget>[
            TabBarView(
              controller: _tabController,
              children: [
                BatchDetailPage(batchModel: model, loader: loader),
                BatchVideosPage(loader: loader),
                BatchAssignmentPage(loader: loader),
                BatchStudyMaterialPage(model: model, loader: loader)
              ],
            ),
            if (widget.isTeacher)
              ValueListenableBuilder(
                valueListenable: currentPageNo,
                builder: (BuildContext context, dynamic index, Widget child) {
                  return AnimatedFabButton(
                      showFabButton: showFabButton,
                      children: _floatingButtons(index));
                },
              ),
          ],
        ),
      ),
    );
  }
}
