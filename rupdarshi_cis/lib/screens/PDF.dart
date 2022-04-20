import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf_flutter/pdf_flutter.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:printing/printing.dart';

void main() => runApp(PdfApp());

class PdfApp extends StatefulWidget {
  final String pdfURL;

  const PdfApp({Key key, this.pdfURL}) : super(key: key);

  @override
  _PdfAppState createState() => _PdfAppState();
}

class _PdfAppState extends State<PdfApp> {
  WebViewController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //print(" PDF URL -> " + this.widget.pdfURL);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: Text(
                "Invoice",
                style: TextStyle(
                    color: Constants.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              backgroundColor: Constants.bgColor,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.keyboard_arrow_left,
                  size: 35,
                  color: Constants.greyColor, // add custom icons also
                ),
              ),
            ),
            // body: Container(
            //     height: double.infinity,
            //     width: double.infinity,
            //     child: WebView(
            //       javascriptMode: JavascriptMode.unrestricted,
            //       initialUrl: this.widget.pdfURL,
            //       // initialUrl: "https://www.naukri.com/",
            //       onWebViewCreated: (WebViewController webViewController) {
            //         _controller = webViewController;
            //       },
            //     ))
            body: Container(
              color: Colors.white,
              child: PDF.network(
                this.widget.pdfURL,
                height: double.infinity,
                width: double.infinity,
                placeHolder:
                    Image.asset("assets/invoice.png", height: 200, width: 100),
              ),
            )
            
            ));
  }
}
