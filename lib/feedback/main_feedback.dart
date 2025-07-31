import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:http/http.dart' as http;

class MainFeedback extends StatefulWidget {
  const MainFeedback({super.key});

  @override
  State<MainFeedback> createState() => _MainFeedbackState();
}

class _MainFeedbackState extends State<MainFeedback> {
  final feedbackController = TextEditingController();
  final emailController = TextEditingController();
  bool isFormValid = false;
  bool isSending = false;


  @override
  void initState() {
    super.initState();
    isSending = false;
  }

  @override
  Widget build(BuildContext context) {
    isFormValid = feedbackController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: MyColors().purple),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Icon(Icons.email, size: 50, color: MyColors().purple),
              const SizedBox(height: 20),
              Text(
                'Feel free to share any problems or suggestions.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              // 이메일 입력
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isFormValid && !isSending
                      ? () async {
                    setState(() {
                      isSending = true;
                    });
                          final userId = await Purchases.appUserID;
                          final feedback = feedbackController.text;
                          final email = emailController.text;
                          final response = await http.post(
                            Uri.parse('https://us-central1-podo-49335.cloudfunctions.net/onSendFeedbackEmail'),
                            body: {
                              'userEmail': email,
                              'userId': userId,
                              'appName': 'Podo Words',
                              'feedback': feedback,
                            },
                          );

                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Thank you! Your feedback has been sent.'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            feedbackController.clear();
                            emailController.clear();
                            Get.back();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to send feedback. Please try again later.'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          setState(() {
                            isSending = false;
                          });
                        }
                      : null,
                  label: const Text('Send Feedback', style: TextStyle(fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFormValid ? MyColors().purple : Colors.grey.shade300,
                    foregroundColor: isFormValid ? Colors.white : Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
