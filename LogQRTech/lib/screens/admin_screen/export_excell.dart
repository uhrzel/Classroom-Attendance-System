import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import '../sql_helpers/DatabaseHelper.dart';

Future<void> exportToExcel(BuildContext context) async {
  try {
    // Check for storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // Request storage permission
      status = await Permission.storage.request();
      if (!status.isGranted) {
        // Handle denied permission
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Storage permission is required for exporting to Excel'),
          ),
        );
        return;
      }
    }

    // Retrieve data from the database
    var usersWithSubjectDetails =
        await RegistrationSQLHelper.fetchUsersWithSubjectDetails();
    var entryLogs = await RegistrationSQLHelper.getEntryLogs();
    var exitLogs = await RegistrationSQLHelper.getExitLogs();

    // Create a new Excel package
    var excel = Excel.createExcel();

    // Create a new sheet
    var sheet = excel['Students Data'];

    // Insert the headers in the first row
    var headers = [
      'Full Name',
      'Section',
      'School Year',
      'Semester',
      'Late',
      'Entry Time',
      'Exit Time',
    ];
    sheet.appendRow(headers);

    // Insert data in the rows
    for (var user in usersWithSubjectDetails) {
      var entryTime = '';
      var exitTime = '';

      var entryLog = entryLogs.firstWhere((log) => log['user_id'] == user['id'],
          orElse: () => Map<String, dynamic>.from({}));
      if (entryLog.isNotEmpty) {
        entryTime = '${entryLog['entrydate']} ${entryLog['entrytime']}';
      }

      var exitLog = exitLogs.firstWhere((log) => log['user_id'] == user['id'],
          orElse: () => Map<String, dynamic>.from({}));
      if (exitLog.isNotEmpty) {
        exitTime = '${exitLog['exitdate']} ${exitLog['exittime']}';
      }

      List<dynamic> row = [
        user['fullName'] ?? '',
        user['courses'] ?? '',
        user['class'] ?? '',
        user['school_year'] ?? '',
        user['late']?.toString() ?? '',
        entryTime,
        exitTime,
      ];
      sheet.appendRow(row);
    }

    // Save the Excel file to external storage
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      String filePath = '${externalDir.path}/student.xlsx';
      excel.encode().then((onValue) {
        File file = File(filePath);
        file.createSync(recursive: true);
        file.writeAsBytesSync(onValue);

        // Show a Snackbar instead of printing to console
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file successfully created at $filePath'),
          ),
        );
      });
    } else {
      // Handle the case when external directory is null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to access external storage'),
        ),
      );
    }
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error while exporting to Excel: $e')),
    );
  }
}
