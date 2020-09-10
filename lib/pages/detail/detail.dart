import 'dart:async';
import 'dart:io';
import 'package:daily/components/file_image.dart';
import 'package:daily/components/placeholder_image.dart';
import 'package:daily/model/daily.dart';
import 'package:daily/pages/edit/edit.dart';
import 'package:daily/styles/colors.dart';
import 'package:daily/styles/iconfont.dart';
import 'package:daily/styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeroDetailPage extends StatefulWidget {
  final Daliy daliy;
  final String imgPlaceHolder;
  const HeroDetailPage({Key key, this.daliy, this.imgPlaceHolder}) : super(key: key);
  @override
  _HeroDetailPageState createState() => _HeroDetailPageState();
}

class _HeroDetailPageState extends State<HeroDetailPage> {
  Timer _timer;
  bool _toogle = true;
  int _countdownTime = 2;
  String countYear = '';
  String countMonth = '';
  String countDay = '';
  String countTotalDay = '';
  bool _todayIsLateTarget = true;

  @override
  void initState() {
    caclTimeDistance();
    startCountdownTimer();

    super.initState();
  }

  // 计算时间差
  void caclTimeDistance() {
    int year = 0;
    int month = 0;
    int day = 0;
    int total = 0;
    final today = new DateTime.now();
    final targetDay = DateTime.parse(widget.daliy.targetDay);
    final difference = today.difference(targetDay);
    _todayIsLateTarget = difference.inDays > 0 ? true : false;
    total = (difference.inDays).abs();
    year = total ~/ 365;
    month = (total - year * 365) ~/ 30;
    day = total - year * 365 - month * 30;
    countTotalDay = formatNum(total);
    countYear = formatNum(year);
    countMonth = formatNum(month);
    countDay = formatNum(day);
    setState(() {});
    // print([countTotalDay, countYear, countMonth, countDay]);
  }

  String formatNum(int num) {
    return num < 10 ? '0$num' : num.toString();
  }

  // 每隔2s切换Widget
  void startCountdownTimer() {
    const oneSec = Duration(seconds: 1);
    var callback = (timer) => {
          setState(() {
            if (_countdownTime < 1) {
              _toogle = !_toogle;
              _countdownTime = 2;
            } else {
              _countdownTime = _countdownTime - 1;
            }
          })
        };

    _timer = Timer.periodic(oneSec, callback);
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: AppColors.detailBackGorundColor,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Hero(
                    tag: 'hero${widget.daliy.id}',
                    child: Container(
                      height: 400,
                      child: Stack(
                        children: <Widget>[
                          _buildTopBg(context, widget.daliy),
                          _buildTopContent(context, widget.daliy),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomContent(widget.daliy),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 顶部背景图
  Widget _buildTopBg(BuildContext context, Daliy daliy) {
    return Container(
      height: 400,
      width: MediaQuery.of(context).size.width,
      child: File(daliy.imageUrl).existsSync()
          ? FileImageFormPath(imgPath: daliy.imageUrl)
          : PlaceHolderImage(imgUrl: widget.imgPlaceHolder),
    );
  }

  /// 顶部内容
  Widget _buildTopContent(BuildContext context, Daliy daliy) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(daliy.headText, style: AppTextStyles.headTextStyle),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 300),
                          pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
                            return ScaleTransition(
                              scale: animation,
                              alignment: Alignment.topRight,
                              child: EditPage(daliy: daliy),
                            );
                          }),
                    ).then((value) {
                      setState(() {
                        daliy = value;
                      });
                    });
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(builder: (context) {
                    //     return EditPage(daliy: daliy);
                    //   }),
                    // ).then((value) {
                    //   setState(() {
                    //     daliy = value;
                    //   });
                    // });
                  },
                  child: Container(
                    width: 80,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('编辑', style: AppTextStyles.headTextStyle),
                    ),
                  ),
                ),
              ],
            ),
            Text(daliy.title, style: AppTextStyles.titleTextStyle),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(seconds: 1),
                child: _toogle
                    ? _buildMiddleYear(daliy, senceWidth: MediaQuery.of(context).size.width)
                    : _buildMiddleCountDay(daliy, senceWidth: MediaQuery.of(context).size.width),
              ),
            ),
            Text(daliy.targetDay, style: AppTextStyles.targetDayStyle)
          ],
        ),
      ),
    );
  }

  ///  年月日
  Widget _buildMiddleYear(Daliy daliy, {double senceWidth}) {
    return Center(
      key: ValueKey('year'),
      child: Container(
        width: (senceWidth - 36) * 0.6,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Text(countYear, style: AppTextStyles.countTitleStyle),
                  Positioned(top: 50, child: Text('年', style: AppTextStyles.countBottomTipStyle)),
                ],
              ),
            ),
            Container(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Text(countMonth, style: AppTextStyles.countTitleStyle),
                  Positioned(top: 50, child: Text('月', style: AppTextStyles.countBottomTipStyle)),
                ],
              ),
            ),
            Container(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Text(countDay, style: AppTextStyles.countTitleStyle),
                  Positioned(top: 50, child: Text('日', style: AppTextStyles.countBottomTipStyle)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 距离目标日的总天数
  Widget _buildMiddleCountDay(Daliy daliy, {double senceWidth}) {
    return Center(
      key: ValueKey('day'),
      child: Container(
        width: (senceWidth - 36) * 0.6,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(countTotalDay, style: AppTextStyles.countTitleStyle),
            SizedBox(width: 2),
            Text('天', style: AppTextStyles.countBottomTipStyle),
            Icon(_todayIsLateTarget ? Iconfont.up2 : Iconfont.down1, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  /// 底部内容
  Widget _buildBottomContent(Daliy daliy) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width - 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(daliy.remark, style: AppTextStyles.contentStyle),
    );
  }
}
