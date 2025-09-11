// import 'dart:convert';
// import 'dart:io';
// import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
//
// class ChatGPTService {
//   static final ChatGPTService _instance = ChatGPTService._internal();
//   late final OpenAI _openAI;
//
//   factory ChatGPTService() {
//     return _instance;
//   }
//
//   ChatGPTService._internal() {
//     _openAI = OpenAI.instance.build(
//       token: const String.fromEnvironment('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'),
//       baseOption: HttpSetup(
//         receiveTimeout: const Duration(seconds: 20),
//         connectTimeout: const Duration(seconds: 20),
//       ),
//       enableLog: true,
//     );
//   }
//
//   Future<Map<String, String>> extractTicketInfoFromImage(File imageFile) async {
//     try {
//       // Convert image to base64
//       final bytes = await imageFile.readAsBytes();
//       final base64Image = base64Encode(bytes);
//
//       final request = CompleteText(
//         prompt: '''Analyze this ticket image and extract the following information. Return ONLY a JSON object with these fields, nothing else:
//         {
//           "seat": "seat number",
//           "row": "row identifier",
//           "entrance": "entrance number/name",
//           "area": "area/section name",
//           "stand": "stand/block name"
//         }
//
//         Ticket image (base64): $base64Image''',
//         model: TextDavinci3Model(),
//         maxTokens: 300,
//       );
//
//       final response = await _openAI.onCompletion(request: request);
//       final jsonStr = response?.choices.first.text.trim() ?? '{}';
//
//       try {
//         // Clean up the response to ensure it's valid JSON
//         final cleanJson = jsonStr.replaceAll(RegExp(r'```json|```'), '').trim();
//         final Map<String, dynamic> data = json.decode(cleanJson);
//
//         return {
//           'seat': data['seat']?.toString() ?? '',
//           'row': data['row']?.toString() ?? '',
//           'entrance': data['entrance']?.toString() ?? '',
//           'area': data['area']?.toString() ?? '',
//           'stand': data['stand']?.toString() ?? '',
//         };
//       } catch (e) {
//         print('Error parsing ChatGPT response: $e');
//         return {};
//       }
//     } catch (e) {
//       print('Error calling ChatGPT API: $e');
//       return {};
//     }
//   }
// }
