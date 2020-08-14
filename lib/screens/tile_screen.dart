import 'package:flutter/material.dart';
import 'package:cdli_tablet_app/models/tile_model.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class TileScreen extends StatefulWidget {
  final position;

  TileScreen(this.position);

  @override
  State<StatefulWidget> createState() {
    return _TileScreenState(this.position);
  }
}

class _TileScreenState extends State<TileScreen> {
  int position;

  _TileScreenState(this.position);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'cdli tablet',
          style: TextStyle(color: Colors.white, fontFamily: 'NotoSansJP',
            fontWeight: FontWeight.w400,),
        ),
        backgroundColor: Color.fromRGBO(18, 18, 18, 1),
        leading: PlatformIconButton(
          android: (_) => MaterialIconButtonData(icon: Icon(Icons.arrow_back, color: Colors.white,)),
          ios: (_) => CupertinoIconButtonData(icon: Icon(Icons.arrow_back_ios, color: Colors.white,)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        //automaticallyImplyLeading: false,
      ),
      body: TileModel(position),);
  }
}
