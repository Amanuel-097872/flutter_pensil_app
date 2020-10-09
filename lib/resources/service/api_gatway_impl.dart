import 'package:dio/dio.dart';
import 'package:flutter_pensil_app/helper/constants.dart';
import 'package:flutter_pensil_app/model/batch_model.dart';
import 'package:flutter_pensil_app/model/create_announcement_model.dart';
import 'package:flutter_pensil_app/model/poll_model.dart';
import 'package:flutter_pensil_app/resources/service/api_gatway.dart';
import 'package:flutter_pensil_app/resources/service/dio_client.dart';
import 'package:flutter_pensil_app/model/actor_model.dart';

class ApiGatewayImpl implements ApiGateway {
  final DioClient _dioClient;

  ApiGatewayImpl(this._dioClient);

  @override
  Future getUser() {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<bool> createBatch(BatchModel model) async {
    try {
      final data = model.toJson();
      print(data);
      String token = Constants.token;
      final header = {"Authorization": "Bearer " + token};
      var response = await _dioClient.post(Constants.batch,
          data: data, options: Options(headers: header));
      return true;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<bool> createAnnouncement(AnnouncementModel model) async {
    try {
      final data = model.toJson();
      String token = Constants.token;
      final header = {"Authorization": "Bearer " + token};
      var response = await _dioClient.post(Constants.createAnnouncement,
          data: data, options: Options(headers: header));
      return true;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<ActorModel> login(ActorModel model)async {
    try {
      final data = model.toJson();
      String token = Constants.token;
      final header = {"Authorization": "Bearer " + token};
      var response = await _dioClient.post(Constants.login, data: data, options: Options(headers: header));
      var map = _dioClient.getJsonBody(response);
      var actor = ActorModel.fromJson(map["user"]);
      return actor;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<BatchModel>> getBatches() async{
     try {
      String token = Constants.token;
      final header = {"Authorization": "Bearer " + token};
      var response = await _dioClient.get(Constants.batch, options: Options(headers: header));
      var json = _dioClient.getJsonBody(response);
      final list = BatchResponseModel.fromJson(json);
      return list.batches;
    } catch (error) {
      throw error;
    }
  }
  Future<bool> createPoll(PollModel model)async{
    try {
      final data = model.toJson();
      String token = Constants.token;
      final header = {"Authorization": "Bearer " + token};
      await _dioClient.post(Constants.poll, data: data, options: Options(headers: header));
      return true;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncemantList() async{
    try {
      String token = Constants.token;
      final header = {"Authorization": "Bearer " + token};
      final response = await _dioClient.get(Constants.createAnnouncement,options: Options(headers: header));
      var json = _dioClient.getJsonBody(response);
      final model = AnnouncementListResponse.fromJson(json);
      return model.announcements;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<PollModel>> getPollList()async{
    try {
      String token = Constants.token;
      final header = {"Authorization": "Bearer " + token};
      final response = await _dioClient.get(Constants.poll,options: Options(headers: header));
      var json = _dioClient.getJsonBody(response);
      final model = PollResponseModel.fromJson(json);
      return model.polls;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<ActorModel>> getStudentList()async{
      try {
      String token = Constants.token;
      final header = {"Authorization": "Bearer " + token};
      final response = await _dioClient.get(Constants.getAllStudentList,options: Options(headers: header));
      var json = _dioClient.getJsonBody(response);
      final model = StudentResponseModel.fromJson(json);
      return model.students;
    } catch (error) {
      throw error;
    }
  }
}
