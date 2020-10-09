import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_pensil_app/model/create_announcement_model.dart';
import 'package:flutter_pensil_app/resources/repository/batch_repository.dart';
import 'package:get_it/get_it.dart';

class AnnouncementState extends ChangeNotifier{
  bool isForAll = false;
  
  void setIsForAll(bool value){
    isForAll = value;
    notifyListeners();
  }
  Future<AnnouncementModel> createAnnouncement({String title,String description})async{
    try{
      assert(title != null);
      var model = AnnouncementModel(
        // title:title,
        batches: [""],
        description: description,
        isForAll: isForAll
      );
      final getit = GetIt.instance;
      final repo = getit.get<BatchRepository>();
      await repo.createAnnouncement(model);
      return model;
    }catch (error, strackTrace){
      log("createBatch", error:error, stackTrace:strackTrace);
      return null;
    }
  }
}