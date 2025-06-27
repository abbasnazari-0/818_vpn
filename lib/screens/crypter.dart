import 'package:begzar/common/encdec.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class CrypterScreen extends StatelessWidget {
  CrypterScreen({super.key});
  TextEditingController inputController = TextEditingController();
  TextEditingController outputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          //   create 1 text field for input
          Expanded(
            child: TextFormField(
              controller: inputController,
              maxLines: 15,
              decoration: InputDecoration(
                labelText: 'input',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    // make button radius 10
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 36),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    // set button width to full

                    onPressed: () {
                      if (inputController.text.isEmpty) {
                        // show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Please enter some text to encrypt')),
                        );
                        return;
                      }

                      final String encypted = EncDec().encryptString(
                        inputController.text,
                      );

                      outputController.text = encypted;

                      //
                    },
                    child: Text('Encrypt',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                      // make button color

                      style: ElevatedButton.styleFrom(
                          // make color primary: Colors.red,
                          backgroundColor: Colors.blueAccent,
                          minimumSize: Size(double.infinity, 36),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      // set button width to full

                      onPressed: () async {
                        if (outputController.text.isEmpty) {
                          // show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Please enter some text to encrypt')),
                          );
                          return;
                        }
                        //   copy output to clipboard
                        await Clipboard.setData(
                            ClipboardData(text: outputController.text));

                        // show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                              content: Text('Output copied to clipboard')),
                        );
                      },
                      child: Text('Copy',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)))),
            ],
          ),
          Expanded(
            child: TextFormField(
              controller: outputController,
              decoration: InputDecoration(
                labelText: 'Output',
                border: OutlineInputBorder(),
              ),
              maxLines: 18,
            ),
          ),
        ]),
      ),
    );
  }
}
