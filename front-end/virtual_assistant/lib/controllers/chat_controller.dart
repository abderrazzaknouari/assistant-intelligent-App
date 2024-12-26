import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:mime_type/mime_type.dart';
import 'package:virtual_assistant/models/attachement.dart';
import 'package:virtual_assistant/models/data.dart';
import 'package:virtual_assistant/models/method_to_use_type.dart';
import 'package:virtual_assistant/models/prompt_request.dart';
import 'package:virtual_assistant/models/prompt_response.dart';
import 'package:virtual_assistant/models/prompt_response_type.dart';
import 'package:virtual_assistant/models/simple_text.dart';
import 'package:virtual_assistant/services/chat_service.dart';
import 'package:virtual_assistant/services/storage_serivce.dart';
import 'package:virtual_assistant/wrappers/response.dart';

import '../models/message.dart';
import '../models/user.dart';

class ChatController with ChangeNotifier {

  final url = dotenv.env['URL']!;
  final secretToken = dotenv.env['SECRET_TOKEN']!;
  List<Message> messages = [];
  List<Attachment> attachments = [];
  PromptResponse? lastPrompt ;
  Status _status = Status.NORMAL;
  Status get status => _status;
  late HttpChatService chatService;

  ChatController() {
    chatService = HttpChatService(token: secretToken, url: url);
  }

    Data<User?> user = Data<User?>(status: Status.NORMAL);
    void setUser(User? user) {
      this.user.data = user;
        notifyListeners();
    }

  StorageService storageService = StorageService.instance;
    Future init() async {
      await storageService.init();
  }

  Future getMessages() async {
    _status = Status.LOADING;
    notifyListeners();
    messages = await storageService.readData();
    _status = Status.SUCCESS;
    notifyListeners();
  }

  Future sendMessage(String messageText) async {
    _status = Status.LOADING;
    notifyListeners()  ;
    Message message = Message(message: messageText,attachments: attachments);
    storageService.saveMessage(message);
    try {
      HttpResponse<PromptResponse>? promptResponse;
      if (lastPrompt == null) {
        promptResponse =
        await chatService.sendMessage(message, user.data!.tokenId);
      } else {
        promptResponse = await chatService.sendRePromptRequest(
            PromptRequest(promptResponse: lastPrompt!, userText: messageText),
            user.data!.tokenId);
      }
      lastPrompt = promptResponse.data;
      if (promptResponse.statusCode == 200) {
        if (promptResponse.data!.typeAnswer == PromptResponseType.message ||
            promptResponse.data!.methodToUse != MethodToUseType.create || promptResponse.data!.methodToUse != MethodToUseType.send) {
          lastPrompt = null;
          storageService.saveMessage(Message(
              message: promptResponse.data.toString(), isSender: false));
        } else if (promptResponse.data!.satisfied != true) {
          storageService.saveMessage(Message(
              message: promptResponse.data.toString(), isSender: false));
        } else if (promptResponse.data!.satisfied == true) {
          lastPrompt = null;
          storageService.saveMessage(
              Message(message: "your request is Sent", isSender: false)
          );
        }
      } else {
        lastPrompt = null;
        storageService.saveMessage(
            Message(message: promptResponse.error, isSender: false)
        );
      }
    }
    catch (e) {
      lastPrompt = null;
      if(e is SocketException)
        storageService.saveMessage(Message(message: "No internet connection", isSender: false));
        else
        storageService.saveMessage(Message(message: e.toString(), isSender: false));
    }
    _status = Status.SUCCESS;
    notifyListeners();
  }

  void showPicker(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      for (var i = 0; i < result.files.length; i++) {
        final tempFile = File(result.files[i].path!);
        Uint8List? fileBytes= await tempFile.readAsBytes();
        final ex=result.files[i].extension;
        attachments.add(Attachment(
          name: result.files[i].name,
          data: Base64Encoder().convert(fileBytes),
          contentType: mime(result.files[i].name)!,
        ));
      }

    } else {
      // User canceled the picker
      attachments=[];
    }
  }

  ValueListenable<Box<dynamic>?> getMessagesListener() {
    return storageService.getListener();
  }

   User? getUser() {
    return user.data;
  }
  clearChat() {
    storageService.clear();
    notifyListeners();
  }

}
