import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:daily/components/bottom_button.dart';
import 'package:daily/pages/share/post_enter.dart';
import 'package:daily/styles/colors.dart';
import 'package:daily/styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

class ShareContentPost extends StatefulWidget {
  String bgUrl;
  String qrImageUrl;

  ShareContentPost({this.bgUrl, this.qrImageUrl});

  @override
  _ShareContentPostState createState() => _ShareContentPostState();
}

class _ShareContentPostState extends State<ShareContentPost> {
  GlobalKey globalKey = GlobalKey();

  Future<void> _capturePng() async {
    // '保存中...'
    RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: window.devicePixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    var status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      var result = await ImageGallerySaver.saveImage(pngBytes);
      print(result);
      if (result == true || result != '') {
        showToast('成功保存到相册！');
        // Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          brightness: Brightness.dark,
          backgroundColor: AppColors.homeBackGorundColor,
          title: Text('分享', style: AppTextStyles.shareTitleStyle),
          leading: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.pop(context),
            child: Container(height: 50, width: 50, child: Icon(Icons.arrow_back, color: Colors.black)),
          ),
        ),
        body: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(30),
            color: AppColors.homeBackGorundColor,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: RepaintBoundary(
                    key: globalKey,
                    child: EnterPostPage(
                      bgUrl: widget.bgUrl,
                      qrImageUrl: widget.qrImageUrl,
                      screenWidth: MediaQuery.of(context).size.width,
                      screenHeight: MediaQuery.of(context).size.height,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: BottomButton(
                    text: '保存',
                    height: 50,
                    handleOk: () => _capturePng(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
