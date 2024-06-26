import 'dart:developer';
import 'package:flutter_pensil_app/helper/constants.dart';
import 'package:flutter_pensil_app/helper/enum.dart';
import 'package:flutter_pensil_app/helper/shared_prefrence_helper.dart';
import 'package:flutter_pensil_app/model/actor_model.dart';
import 'package:flutter_pensil_app/model/batch_model.dart';
import 'package:flutter_pensil_app/model/create_announcement_model.dart';
import 'package:flutter_pensil_app/model/poll_model.dart';
import 'package:flutter_pensil_app/resources/repository/batch_repository.dart';
import 'package:flutter_pensil_app/resources/repository/teacher/teacher_repository.dart';
import 'package:flutter_pensil_app/states/base_state.dart';
import 'package:get_it/get_it.dart';

class HomeState extends BaseState {
  List<BatchModel> batchList;
  List<AnnouncementModel> announcementList;
  List<PollModel> polls;
  List<PollModel> allPolls;
  String userId;
  Future<ActorModel> user;
  bool isTeacher = true;

  Future getBatchList() async {
    try {
      final getit = GetIt.instance;
      final pref = getit.get<SharedPrefrenceHelper>();
      var user = await pref.getUserProfile();
      userId = user.id;
      isTeacher = user.role == Role.TEACHER.asString();
      final repo = getit.get<BatchRepository>();
      batchList = await repo.getBatch();
      notifyListeners();
    } catch (error) {
      log("getBatchList", error: error, name: this.runtimeType.toString());
    }
  }

  Future getAnnouncemantList() async {
    try {
      final getit = GetIt.instance;
      final repo = getit.get<BatchRepository>();
      announcementList = await repo.getAnnouncemantList();
      if (announcementList.isNotEmpty)
        announcementList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (error) {
      log("getAnnouncemantList",
          error: error, name: this.runtimeType.toString());
    }
  }

  Future getPollList() async {
    try {
      final repo = getit.get<BatchRepository>();
      polls = await repo.getPollList();
      if (polls.isNotEmpty) {
        polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        allPolls = List.from(polls);
        polls.removeWhere((poll) => poll.endTime.isBefore(DateTime.now()));
        notifyListeners();
      }
    } catch (error) {
      log("getPollList", error: error, name: this.runtimeType.toString());
    }
  }

  void savePollSelection(PollModel model) {
    var copyModel = polls.firstWhere((e) => e.id == model.id);
    copyModel = model;
    notifyListeners();
  }

  Future castVoteOnPoll(PollModel poll, String vote) async {
    if (isTeacher) {
      print("Teacher can't cast vote");
      return;
    }
    poll.selection.loading = true;
    var model = await execute(() async {
      isBusy = true;
      final getit = GetIt.instance;
      final repo = getit.get<BatchRepository>();
      return await repo.castVoteOnPoll(poll.id, vote);
    }, label: "castVoteOnPoll");

    var dt = polls.indexWhere((element) => element.id == model.id);
    polls[dt] = model;
    print("Voted sucess");
      poll.selection.loading = false;
    isBusy = false;
  }

  void logout() {
    batchList = null;
    polls = null;
    userId = null;
    announcementList = null;
    user = null;
    final pref = GetIt.instance<SharedPrefrenceHelper>();
    pref.cleaPrefrenceValues();
  }

  Future<ActorModel> getUser() {
    final pref = GetIt.instance<SharedPrefrenceHelper>();
    user = user ?? pref.getUserProfile();
    return user;
  }

  Future<bool> deleteBatch(String batchId) async {
    try {
      final repo = getit.get<BatchRepository>();
      var isDeleted = await repo.deleteById(Constants.deleteBatch(batchId));
      if (isDeleted) {
        batchList.removeWhere((element) => element.id == batchId);
      }
      notifyListeners();
      return true;
    } catch (error) {
      log("deleteBatch", error: error, name: this.runtimeType.toString());
      return false;
    }
  }

  Future<bool> deletePoll(String pollId) async {
    try {
      final repo = getit.get<BatchRepository>();
      var isDeleted = await repo.deleteById(Constants.crudePoll(pollId));
      if (isDeleted) {
        polls.removeWhere((element) => element.id == pollId);
      }
      notifyListeners();
      return true;
    } catch (error) {
      log("deleteBatch", error: error, name: this.runtimeType.toString());
      return false;
    }
  }

  Future<bool> expirePoll(String pollId) async {
    try {
      final repo = getit.get<TeacherRepository>();
      var isExpired = await repo.expirePollById(pollId);
      if (isExpired) {
        var oldModel = polls.firstWhere((element) => element.id == pollId);
        oldModel.copyWith(endTime: DateTime.now());
      }
      var oldModel = polls.firstWhere((element) => element.id == pollId);
      var index = polls.indexOf(oldModel);
      oldModel = oldModel.copyWith(endTime: DateTime.now());
      polls[index] = oldModel;
      // polls.
      notifyListeners();
      return true;
    } catch (error) {
      log("deleteBatch", error: error, name: this.runtimeType.toString());
      return false;
    }
  }

  Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      var isDeleted =
          await deleteById(Constants.crudAnnouncement(announcementId));
      if (isDeleted) {
        announcementList.removeWhere((element) => element.id == announcementId);
      }
      notifyListeners();
      return isDeleted;
    } catch (error) {
      log("deleteAnnouncement",
          error: error, name: this.runtimeType.toString());
      return false;
    }
  }
}
