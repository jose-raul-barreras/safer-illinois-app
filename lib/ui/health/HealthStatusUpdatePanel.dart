/*
 * Copyright 2020 Board of Trustees of the University of Illinois.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:illinois/model/Health.dart';
import 'package:illinois/service/Health.dart';
import 'package:illinois/utils/AppDateTime.dart';
import 'package:illinois/service/Localization.dart';
import 'package:illinois/service/Styles.dart';
import 'package:illinois/ui/health/HealthNextStepsPanel.dart';
import 'package:illinois/ui/widgets/RoundedButton.dart';
import 'package:illinois/ui/widgets/StatusInfoDialog.dart';
import 'package:illinois/utils/Utils.dart';

class HealthStatusUpdatePanel extends StatefulWidget {
  final HealthStatus status;
  final String previousStatusCode;

  HealthStatusUpdatePanel({this.status, this.previousStatusCode} );

  @override
  _HealthStatusUpdatePanelState createState() => _HealthStatusUpdatePanelState();
}

class _HealthStatusUpdatePanelState extends State<HealthStatusUpdatePanel> {
  String _updateDate;

  String _oldStatusName;
  String _oldStatusDescription;
  Color _oldSatusColor;

  String _newStatusName;
  String _newStatusDescription;
  Color _newSatusColor;

  @override
  void initState() {
    //_updateStatus();
    _updateDate = (widget.status?.dateUtc != null) ? AppDateTime.formatDateTime(widget.status.dateUtc?.toLocal(), format:"MMMM dd, yyyy", locale: Localization().currentLocale?.languageCode) : '';

    HealthCodeData oldStatusCode = Health().rules?.codes[widget.previousStatusCode];
    _oldStatusName = oldStatusCode?.name(rules: Health().rules) ?? '';
    _oldStatusDescription = oldStatusCode?.description(rules: Health().rules) ?? '';
    _oldSatusColor = oldStatusCode?.color ?? Styles().colors.mediumGray;

    HealthCodeData newStatusCode = Health().rules?.codes[widget?.status?.blob?.code];
    _newStatusName = newStatusCode?.name(rules: Health().rules) ?? '';
    _newStatusDescription = newStatusCode?.description(rules: Health().rules) ?? '';
    _newSatusColor = newStatusCode?.color ?? Styles().colors.mediumGray;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Styles().colors.fillColorPrimary,
        body:
        Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: _buildContent(),
              ),
//              _buildPageIndicator(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: ScalableRoundedButton(
                  label: Localization().getStringEx("panel.health.status_update.button.continue.title","See Next Steps"),
                  backgroundColor: Styles().colors.fillColorPrimary,
                  borderColor: Styles().colors.fillColorSecondary,
                  textColor: Styles().colors.white,
                  onTap:(){
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => HealthNextStepsPanel(status: widget.status,))).then((dynamic){Navigator.pop(context);});
                  },
                ),
              )
            ],
          ),
        )
    );
  }

  Widget _buildContent(){
    String county = "${Health().county?.displayName} ${Localization().getStringEx("app.common.label.county", "County")}";
    return
      SingleChildScrollView(
      child:
      Column(children: <Widget>[
        Container(height: 90,),
        Text(_updateDate,textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: Styles().fontFamilies.regular),),
        Container(height: 12,),
        Text(Localization().getStringEx("panel.health.status_update.heading.title","Status Update"),textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: Styles().fontFamilies.regular),),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child:
              Text(county,textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: Styles().fontFamilies.regular),),
            ),
            Semantics(
              explicitChildNodes: true,
              child: Semantics(
                  label: Localization().getStringEx("panel.health.status_update.button.info.title","Info "),
                  button: true,
                  excludeSemantics: true,
                  child:  IconButton(icon: Image.asset('images/icon-info-orange.png', excludeFromSemantics: true,), onPressed: () =>  StatusInfoDialog.show(context, Health().county?.displayName), padding: EdgeInsets.all(10),)
            ))
          ],
        ),
        Container(height: 25,),
        Container(child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child:
            Column(
              children: <Widget>[
                CircleAvatar(child: Image.asset("images/icon-avatar-placeholder.png", excludeFromSemantics: true,),backgroundColor: _oldSatusColor, radius: 32,),
                Container(height: 8,),
                Text(_oldStatusName,style:TextStyle(color: Styles().colors.white, fontSize: 14, fontFamily: Styles().fontFamilies.regular)),
                Text(_oldStatusDescription,style:TextStyle(color: Styles().colors.white, fontSize: 14, fontFamily: Styles().fontFamilies.bold)),
              ],
            )),
            Container(width: 25,),
            Container(margin: EdgeInsets.only(top: 20), width: 16,child:Image.asset("images/icon-white-arrow-right.png", excludeFromSemantics: true)),
            Container(width: 25,),
            Expanded(child:
            Column(
              children: <Widget>[
                CircleAvatar(child: Image.asset("images/icon-avatar-placeholder.png", excludeFromSemantics: true),backgroundColor: _newSatusColor, radius: 32,),
                Container(height: 8 ,),
                Text(_newStatusName,style:TextStyle(color: Styles().colors.white, fontSize: 14, fontFamily: Styles().fontFamilies.regular)),
                Text(_newStatusDescription,style:TextStyle(color: Styles().colors.white, fontSize: 14, fontFamily: Styles().fontFamilies.bold)),
              ],
            )),
        ],)),
        Container(height: 24,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Container(height: 1, color: Styles().colors.surfaceAccent ,),
        ),
        _buildReasonContent(),
        ],
      ),
    );
  }

  Widget _buildReasonContent(){
    String date = AppDateTime.formatDateTime(widget.status?.dateUtc?.toLocal(), format: "MMMM dd, yyyy", locale: Localization().currentLocale?.languageCode);
    String reasonStatusText = widget.status?.blob?.displayReason;

    HealthHistoryBlob reasonHistory = widget.status?.blob?.historyBlob;
    String reasonHistoryName;
    Widget reasonHistoryDetail;
    if (reasonHistory != null) {
      if (reasonHistory.isTest) {
        reasonHistoryName = reasonHistory.testType;
        
        reasonHistoryDetail = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("images/icon-selected.png",excludeFromSemantics: true,),
              Container(width: 7,),
              Text(Localization().getStringEx("panel.health.status_update.label.reason.result", "Result:"), style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: Styles().fontFamilies.bold)),
              Container(width: 5,),
              Text(reasonHistory.testResult ?? '', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: Styles().fontFamilies.regular)),
          ],);

      }
      else if (reasonHistory.isSymptoms) {
        reasonHistoryName = Localization().getStringEx("panel.health.status_update.label.reason.symptoms.title", "You reported new symptoms");
        
        List<Widget> symptomLayouts = List();
        List<HealthSymptom> symptoms = reasonHistory.symptoms;
        if (symptoms?.isNotEmpty ?? false) {
          symptoms.forEach((HealthSymptom symptom){
            String symptomName = Health().rules?.localeString(symptom?.name) ?? symptom?.name;
            if (AppString.isStringNotEmpty(symptomName)) {
              symptomLayouts.add(Text(symptomName, style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: Styles().fontFamilies.regular)));
            }
          });
        }

        reasonHistoryDetail = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: symptomLayouts,
        );
      }
      else if (reasonHistory.isContactTrace) {
        reasonHistoryName = Localization().getStringEx("panel.health.status_update.label.reason.exposed.title","You were exposed to someone who was likely infected");

        reasonHistoryDetail = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("images/icon-selected.png",excludeFromSemantics: true,),
            Container(width: 7,),
            Text(Localization().getStringEx("panel.health.status_update.label.reason.exposure.detail","Duration of exposure: "), style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: Styles().fontFamilies.bold)),
            Container(width: 5,),
            Text(reasonHistory.traceDurationDisplayString ?? "", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: Styles().fontFamilies.regular)),
          ],);
      }
      else if (reasonHistory.isAction) {
        reasonHistoryName = Localization().getStringEx("panel.health.status_update.label.reason.action.title", "You were required an action by health authorities");

        reasonHistoryDetail = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("images/icon-selected.png",excludeFromSemantics: true,),
              Container(width: 7,),
              Text(Localization().getStringEx("panel.health.status_update.label.reason.action.detail", "Action Required: "), style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: Styles().fontFamilies.bold)),
            ],),
          Text(reasonHistory.actionDisplayString ?? "", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: Styles().fontFamilies.regular)),
          

        ],);

      }
    }

    if ((reasonStatusText != null) || (reasonHistoryName != null) || (reasonHistoryDetail != null)) {
      List<Widget> content = <Widget>[
        Container(height: 30,),
        Text(Localization().getStringEx("panel.health.status_update.label.reason.title", "STATUS CHANGED BECAUSE:"), textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: Styles().fontFamilies.bold),),
        Container(height: 30,),
      ];

      if (date != null) {
        content.addAll(<Widget>[
          Text(date, textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: Styles().fontFamilies.bold),),
          Container(height: 2,),
        ]);
      }

      if (reasonHistoryName != null) {
        content.addAll(<Widget>[
          Text(reasonHistoryName,textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: Styles().fontFamilies.extraBold),),
          Container(height: 9,),
        ]);
      }

      if (reasonHistoryDetail != null) {
        content.addAll(<Widget>[
          reasonHistoryDetail,
        ]);
      }

      if (reasonStatusText != null) {
        content.addAll(<Widget>[
          Container(height: 60,),
          Text(reasonStatusText, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: Styles().fontFamilies.bold),),
          Container(height: 30,),
        ]);
      }

      return Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Column(children: content,),
        ),
      );
    }

    return Container();
  }

  /*Widget _buildLoading(){
    return SingleChildScrollView(child:Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
//          Expanded(
//            child:
            Container(height: 48,),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                alignment:Alignment.center,child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(child:
                    Text(Localization().getStringEx("panel.health.status_update.label.loading","Hang tight while we update your status"),textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: Styles().fontFamilies.bold),),)
                  ],),
                  Container(height: 23,),
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Styles().colors.fillColorSecondary), strokeWidth: 3,),
                  Container(height: 48,)
                  ],)
            )
//          )
        ])
    );
  }*/
}