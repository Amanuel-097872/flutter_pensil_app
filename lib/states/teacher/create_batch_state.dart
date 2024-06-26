import 'dart:developer';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pensil_app/model/actor_model.dart';
import 'package:flutter_pensil_app/model/batch_model.dart';
import 'package:flutter_pensil_app/model/batch_time_slot_model.dart';
import 'package:flutter_pensil_app/model/subject.dart';
import 'package:flutter_pensil_app/resources/repository/batch_repository.dart';
import 'package:flutter_pensil_app/resources/repository/teacher/teacher_repository.dart';
import 'package:flutter_pensil_app/states/base_state.dart';
import 'package:get_it/get_it.dart';

class CreateBatchStates extends BaseState {
  CreateBatchStates(BatchModel model) {
    setBatchToEdit(model);
  }
  final getit = GetIt.instance;
  String batchName = "";
  String description;
  bool isEditBatch = false;
  String selectedSubjects;

  BatchModel editBatch = BatchModel();

  setBatchToEdit(BatchModel model) {
    isEditBatch = true;
    editBatch = model;
    batchName = model.name;
    description = model.description;
    var counter = 0;
    timeSlots = List.from(model.classes);
    timeSlots.forEach((clas) {
      clas.index = counter;
      counter++;
      clas.key = UniqueKey().toString();
    });
  
    selectedSubjects = model.subject;
    selectedStudentsList = model.studentModel;
    // if (model.studentModel != null){
    //    selectedStudentsList.forEach((model) {});
    // }
  }

  List<Subject> availableSubjects;

  List<String> contactList;

  /// list of contacts which is selcted from mobile contacts list
  List<String> deviceSelectedContacts;

  /// selected student's mobile list from availavle students
  List<BatchTimeSlotModel> timeSlots = [BatchTimeSlotModel.initial()];

  /// Total available previous students list from api
  List<ActorModel> studentsList;

  /// List of students selected from Total avilable students list
  List<ActorModel> selectedStudentsList;
  set setBatchName(String value) {
    batchName = value;
  }

  set setBatchdescription(String value) {
    description = value;
  }

  void setTimeSlots(BatchTimeSlotModel model) {
    model.index = timeSlots.length;
    timeSlots.add(model);
    notifyListeners();
  }

  bool removeTimeSlot(BatchTimeSlotModel model) {
    // if (timeSlots.length == 1) {
    //   return false;
    // }
    timeSlots.removeWhere((element) => element.key == model.key);
    timeSlots.forEach((element) {
      element.index = timeSlots.indexOf(element);
    });
    // timeSlots.add(model);
    notifyListeners();
    return true;
  }

  set setSelectedSubjects(String name) {
    var model = availableSubjects.firstWhere((element) => element.name == name);
    availableSubjects.forEach((element) {
      element.isSelected = false;
    });
    model.isSelected = true;
    selectedSubjects = name;
    notifyListeners();
  }

  void updateTimeSlots(BatchTimeSlotModel model, int index) {
    var data = timeSlots[index];
    data = model;
    checkSlotsModel(model);
    notifyListeners();
  }

  void addContact(String mobile) {
    contactList.add(mobile);
    notifyListeners();
  }

  void removeContact(String mobile) {
    contactList.remove(mobile);
    notifyListeners();
  }

  /// Add stuent mobile no. from available list
  set setStudentsFromList(ActorModel value) {
    var model = studentsList
        .firstWhere((e) => e.name == value.name && e.mobile == value.mobile);
    model.isSelected = true;
    // selectedStudentsList.add(model);
    notifyListeners();
  }

  void removeStudentFromList(value) {
    var model = studentsList
        .firstWhere((e) => e.name == value.name && e.mobile == value.mobile);
    model.isSelected = false;
    notifyListeners();
  }

  void addNewSubject(String value) {
    availableSubjects.add(Subject(
        index: availableSubjects.length, name: value, isSelected: false));
      notifyListeners();
  }

  /// If any contact no is selcected from mobile contacts list then it should be added
  void setDeviceSelectedContacts(List<Contact> list) {
    deviceSelectedContacts =
        list.map((e) => e.phones.first.value.replaceAll(" ", "")).toList();
  }

  bool checkSlotsVAlidations() {
    bool allGood = true;
    timeSlots.forEach((model) {
      checkSlotsModel(model);
    });
    notifyListeners();
    return timeSlots.any(
        (element) => !element.isValidEndEntry || !element.isValidStartEntry);
  }

  /// If any time slot has default values then it should display error
  void checkSlotsModel(BatchTimeSlotModel model) {
    if (model.startTime == "Start time") {
      model.isValidStartEntry = false;
    } else {
      model.isValidStartEntry = true;
    }
    if (model.endTime == "End time") {
      model.isValidEndEntry = false;
    } else {
      model.isValidEndEntry = true;
    }

    /// If slots has some time values then compare time
    if (model.startTime != "Start time" && model.endTime != "End time") {
      if (int.parse(model.startTime.split(":")[0]) >
          int.parse(model.endTime.split(":")[0])) {
        model.isValidEndEntry = false;
      }

      /// Compare for slots hours
      /// Start hour should not be greater then endtime hour
      if (int.parse(model.startTime.split(":")[0]) ==
          int.parse(model.endTime.split(":")[0])) {
        /// Compare for slots minutes
        /// If start and end hors are equal then
        /// End min should grater then start min
        if (int.parse(model.startTime.split(":")[1]) >=
            int.parse(model.endTime.split(":")[1])) {
          model.isValidEndEntry = false;
        }
      }
    }
  }

  /// Create batch by calling api
  Future<BatchModel> createBatch() async {
    try {
      final mobile = studentsList
          .where((element) => element.isSelected)
          .map((e) => e.mobile);
      List<String> contacts = new List.from(contactList ?? List<String>())
        ..addAll(mobile ?? List<String>())
        ..addAll(deviceSelectedContacts);
      final model = editBatch.copyWith(
          name: batchName,
          description: description,
          classes: timeSlots,
          subject: selectedSubjects,
          students: contacts);
      // print(model.toJson());
      final repo = getit.get<BatchRepository>();
      await repo.createBatch(model);
      // timeSlots.forEach((e) => print(e.toJson()));
      // return Future.value(null);
      return model;
    } catch (error, strackTrace) {
      log("createBatch", error: error, stackTrace: strackTrace);
      return null;
    }
  }

  Future getStudentList() async {
    try {
      final repo = getit.get<TeacherRepository>();
      studentsList = await repo.getStudentList();
      if (studentsList.isNotEmpty) {
        studentsList.removeWhere((element) => element.mobile == null);
        studentsList.toSet().toList();
        final ids = studentsList.map((e) => e.mobile).toSet();
        studentsList.retainWhere((x) => ids.remove(x.mobile));
        if (selectedStudentsList.isNotEmpty) {
          studentsList.forEach((student) {
            var isAvailable =
                selectedStudentsList.any((element) => student.id == element.id);
            print(student.id);
            student.isSelected = isAvailable;
          });
        }
      }

      await getSubjectList();
      notifyListeners();
    } catch (error, strackTrace) {
      log("getStudentList", error: error, stackTrace: strackTrace);
      return null;
    }
  }

  Future getSubjectList() async {
    await execute(() async {
      final repo = getit.get<TeacherRepository>();
      final list = await repo.getSubjectList();
      /// Remove duplicate subjects
      list.toSet().toList();
      final ids = list.map((e) => e).toSet();
      list.retainWhere((x) => ids.remove(x));

      availableSubjects = Iterable.generate(
        list.length,
        (index) => Subject(
          index: index,
          name: list[index],
          isSelected: selectedSubjects == null
              ? false
              : selectedSubjects == list[index]
                  ? true
                  : false,
        ),
      ).toList();

      if (selectedSubjects == null && availableSubjects.isNotEmpty) {
        selectedSubjects = availableSubjects.first.name;
      }
        }, label: "Get Sybjects");
  }
}
