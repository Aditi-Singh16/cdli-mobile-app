import 'package:flutter/material.dart';
import 'package:cdli_tablet_app/services/cdli_data_state.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:cdli_tablet_app/services/cdli_data.dart';
import 'package:cache_image/cache_image.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ListTileModel extends StatefulWidget {
  final title;
  final image;
  final info;
  final thumbnail;
  final short_info;

  ListTileModel(this.title, this.image, this.info, this.thumbnail, this.short_info);

  @override
  State<StatefulWidget> createState() {
    return _ListTileModelState(this.title, this.image, this.info, this.thumbnail, this.short_info);
  }
}

class _ListTileModelState extends State<ListTileModel> {
  String title;
  String image;
  String info;
  String thumbnail;
  String short_info;

  _ListTileModelState(this.title, this.image, this.info, this.thumbnail, this.short_info);

  final cdliDataState dataState = new cdliDataState();
  cdliData data;

  @override
  void initState() {
    super.initState();
    getDataFromApi();
  }

  getDataFromApi() async {
    if (!mounted) return;
    await dataState.getDataFromAPI();
    setState(() {
      if (dataState.error) {
        _showError();
      }
    });
  }

  void _retry() {
    Scaffold.of(context).removeCurrentSnackBar();
    dataState.reset();
    setState(() {});
    getDataFromApi();
  }

  void _showError() {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text('Check your connection and try again.', style: TextStyle(fontFamily: 'NotoSansJP',
        fontWeight: FontWeight.w400,),),
      duration: new Duration(seconds: 3),
      action: new SnackBarAction(
        label: 'Retry',
        textColor: Colors.cyan,
        onPressed: () {
          _retry();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
        topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0));
    return PageView.builder(
      itemCount: dataState.list.length.compareTo(0),
      itemBuilder: (BuildContext context, int index) {
        return SlidingUpPanel(
          renderPanelSheet: false,
          backdropEnabled: true,
          borderRadius: radius,
          panel: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15.0,
                    color: Color.fromRGBO(18, 18, 18, 1),
                  ),
                ]
            ),
            //color: Colors.white,
            margin: const EdgeInsets.all(24.0),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[ Html(
                          data: info,
                          defaultTextStyle: TextStyle(
                              color: Colors.black,
                              fontFamily: 'NotoSansJP',
                              fontSize: 15),
                          onLinkTap: (url) async {
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                        ),
                          ButtonTheme(
                            minWidth: 330.0,
                            height: 50.0,
                            child: RaisedButton(
                              color: Color.fromRGBO(18, 18, 18, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              onPressed: (){
                                share(thumbnail, short_info);
                              },
                              child: Text('Share', style: TextStyle(
                                color: Colors.white, fontSize: 15, fontFamily: 'NotoSansJP',
                                fontWeight: FontWeight.w400,), textAlign: TextAlign.center),
                            ),),],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          collapsed: Container(
            margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(18, 18, 18, 1),
              borderRadius: radius,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                          child: Icon(
                            Icons.maximize,
                            color: Colors.white,
                            size: 30,
                          ))
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(title,
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'NotoSansJP',
                            fontWeight: FontWeight.w400,
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
          body: Center(
            child: PhotoView(
              imageProvider: CacheImage(image),
              loadingBuilder: (context, progress) => Center(
                  child: new Container(
                      child: PlatformCircularProgressIndicator(
                        android: (_) => MaterialProgressIndicatorData(),
                        ios: (_) => CupertinoProgressIndicatorData(radius: 25),
                      ))),
            ),
          ),
        );
      },);
  }

  void share(String thumbnail, String short_info) async {
    var request = await HttpClient().getUrl(Uri.parse(thumbnail));
    var response = await request.close();

    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    await Share.file('cdli tablet', 'image.jpg', bytes, 'image/jpg',
        text: 'I saw this entry on the app "cdli tablet" and wanted to share it with you: \n\n'
            + '"' + short_info + '"' + "\n\n" + 'Download the free "cdli tablet" app:' + "\n"
            + 'for Android mobile devides: https://play.google.com/store/apps/details?id=com.cdlisolutions.cdli.cdlitablet' + "\n"
            + 'for iPad: https://apps.apple.com/us/app/cdli-tablet/id636437023?ls=1');
  }

  void showSnackBar(BuildContext context) {
    Scaffold.of(context).showSnackBar(new SnackBar(
        content: Text('Saved to collection', style: TextStyle(fontFamily: 'NotoSansJP',
          fontWeight: FontWeight.w400,)),
        duration: const Duration(seconds: 2),
        action: new SnackBarAction(
            label: "Undo",
            textColor: Colors.cyan,
            onPressed: () {
              // Undo change
            })));
  }
}
