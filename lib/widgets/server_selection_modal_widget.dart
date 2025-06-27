import 'package:begzar/model/server_model.dart';
import 'package:circle_flags/circle_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ServerSelectionModal extends StatelessWidget {
  final ServerModel selectedServer;
  final Function(ServerModel, String) onServerSelected;
  final List<ServerModel> allservers;

  ServerSelectionModal(
      {required this.selectedServer,
      required this.onServerSelected,
      required this.allservers});

  @override
  Widget build(BuildContext context) {
    print(allservers);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('select_server'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Lottie.asset('assets/lottie/auto.json', width: 30),
              title: Text('Automatic'),
              trailing: selectedServer.location == 'Automatic'
                  ? Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => onServerSelected(ServerModel.empty(), ''),
            ),
            Divider(),
            for (var server in allservers)
              if (server.location != 'Automatic')
                ListTile(
                  leading: CircleFlag(
                    server.country_code,
                    size: 32,
                  ),
                  title: Text(
                    server.location,
                    style: TextStyle(fontFamily: 'GM'),
                  ),
                  trailing: selectedServer.config == server.config
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () => onServerSelected(server, server.config),
                ),
          ],
        ),
      ),
    );
  }
}
