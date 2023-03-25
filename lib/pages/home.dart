import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:nfc/pages/home2.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String data = '';

  Future startNfcSession() async {
    NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
    if (availability != NFCAvailability.available) {
      return;
    }

    var tag = await FlutterNfcKit.poll();

    if (tag.ndefAvailable!) {
      final records = await FlutterNfcKit.readNDEFRecords(cached: false);

      for (var record in records) {
        if (record is ndef.UriRecord) {
          data = record.uri.toString();
        } else if (record is ndef.TextRecord) {
          data = record.text!;
        } else {}
        // add more cases to handle other types of NDEF records
      }
    }
    setState(() {});
  }

  Future writeNfcTag() async {
    var tag = await FlutterNfcKit.poll();

    if (tag.ndefWritable!) {
      await FlutterNfcKit.writeNDEFRecords(
        [
          // ndef.UriRecord.fromUri(
          //   Uri.parse(
          //     "https://lichess.org/",
          //   ),
          // ),
          ndef.TextRecord(
            text: '- - -',
            encoding: ndef.TextEncoding.UTF8,
            language: 'en-US',
          ),
        ],
      );
    }
  }

  Future closeNfcTag() async {
    await FlutterNfcKit.finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Reader'),
      ),
      body: PageView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  startNfcSession();
                },
                child: const Text('Start NFC Session'),
              ),
              ElevatedButton(
                onPressed: () async {
                  writeNfcTag();
                },
                child: const Text('Write NFC Session'),
              ),
              ElevatedButton(
                onPressed: () async {
                  closeNfcTag();
                },
                child: const Text('Close'),
              ),
              const SizedBox(height: 20),
              if (data.isNotEmpty) Text('Data read from tag: $data'),
            ],
          ),
          Home2(),
        ],
      ),
    );
  }
}
