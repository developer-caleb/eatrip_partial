import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matjipmemo/constants/common_size.dart';
import 'package:matjipmemo/constants/logger.dart';
import 'package:matjipmemo/controller/login_controller.dart';
import 'package:matjipmemo/models/firebase/matjip_model.dart';
import 'package:matjipmemo/models/firebase/user_model.dart';
import 'package:matjipmemo/pages/others/others_profile_page.dart';
import 'package:matjipmemo/widget/rounded_icon.dart';

class HeaderWidget extends StatelessWidget {
  HeaderWidget(this._matjipModel, {this.callback, required this.index, this.tutorialKey, Key? key}) : super(key: key);
  MatjipModel _matjipModel;
  VoidCallback? callback;
  GlobalKey? tutorialKey;
  UserModel? userModel = Get.find<LoginController>().userModel.value;
  int index;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 12, right: 2),
      child: Row(
        children: [
          InkWell(
            onTap: userModel==null? (){ Get.to(()=>OthersProfilePage(_matjipModel.makeruid!));}: _matjipModel.makeruid!=userModel!.uid?(){
              logger.d('go to others profile');
              Get.to(()=>OthersProfilePage(_matjipModel.makeruid!));
            }:null,
            child: Row(
              key: index==0 ? tutorialKey:null,
              children: [
                networkCircleImg(imgurl: _matjipModel.writerimg!, imgsize: iconsize_ll, replaceicon: Icons.person),
                SizedBox(width: common_ss_gap,),
                Text(_matjipModel.makername!, style: TextStyle(fontSize: 16,),),
              ],
            ),
          ),
          Spacer(),

          IconButton(onPressed: callback/*(){
            optionButtonBottomSheet(_matjipModel);
          }*/, icon: Icon(Icons.more_vert))
        ],
      ),
    );
  }
}
