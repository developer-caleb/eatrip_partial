import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matjipmemo/constants/common_size.dart';
import 'package:matjipmemo/constants/logger.dart';
import 'package:matjipmemo/controller/login_controller.dart';
import 'package:matjipmemo/controller/manager_controller.dart';
import 'package:matjipmemo/controller/square_controller.dart';
import 'package:matjipmemo/kakao/kakao_place_model.dart';
import 'package:matjipmemo/models/firebase/matjip_model.dart';
import 'package:matjipmemo/models/firebase/place_model.dart';
import 'package:matjipmemo/pages/add_matjip/add_matjip_write.dart';
import 'package:matjipmemo/repo/matjip_network_repository.dart';
import 'package:matjipmemo/repo/user_network_repository.dart';
import 'package:matjipmemo/tools/kakao_tools.dart';
import 'package:matjipmemo/widget/report_item/open_report_dialog.dart';

InkWell optionButton(String text , Function()? function) {
  return InkWell(
    onTap: function,
    child: Padding(
      padding: const EdgeInsets.all(common_main_gap),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text( text,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}

Widget optionButton_modify(MatjipModel matjipModel) {
  return optionButton( "수정하기".tr, (){
    logger.d("게시물 수정");
    Get.back();
    Get.to(()=>AddMatjipWrite(matjipModel: matjipModel, ));
  });
}
Widget optionButton_delete(MatjipModel matjipModel, {Function()? function}) {
  return optionButton( "삭제하기".tr, function!=null ? function: () async{
    logger.d("게시물 삭제");
    Get.back();
    if(await matjipNetworkRepository.deleteMatjipModel(matjipModel)){
      Get.find<ManagerController>().deleteMatjip(matjipModel);
      Get.find<SquareController>().deleteMatjip(matjipModel);
    }
  });
}
Widget optionButtonShareMatjip(MatjipModel matjipModel) {
  return optionButton( "공유하기".tr, () async{
    Get.back();
    await KakaoShareManager().shareMatjipMyCode(matjipModel,
    );
  });
}
Widget optionButtonSharePlace(PlaceModel placeModel) {
  return optionButton( "공유하기".tr, () async{
    Get.back();
    await KakaoShareManager().sharePlaceMyCode(placeModel, placeModel.imageurls.length>0? placeModel.imageurls[0]: null
    );
  });
}
Widget optionButton_cancel_following(MatjipModel matjipModel) {
  return optionButton( "팔로우 취소".tr, () async{
    logger.d("팔로우 취소");
    await userNetworkRepository.cancelFollowUser(matjipModel.makeruid!, Get.find<LoginController>().userModel.value!.uid!);
    Get.back();
  });
}
Widget optionButton_following(MatjipModel matjipModel) {
  return optionButton( "팔로잉".tr, () async{
    logger.d("팔로잉");
    await userNetworkRepository.setFollowUser(matjipModel.makeruid!, Get.find<LoginController>().userModel.value!.uid!);
    Get.back();
  });
}
Widget optionButton_AddMatjip(MatjipModel matjipModel) {
  return optionButton( "가볼 곳 추가".tr, () async{
    logger.d("가볼 곳 추가");
    Get.back();
    Get.to(()=>AddMatjipWrite( kakaoPlace: KaKaoPlaceDocument.fromMatjip(matjipModel), linkedMatjip: matjipModel,));

  });
}

Widget optionButton_report(Object objectModel) {
  return optionButton( "신고하기".tr, (){
    logger.d("신고하기");
    Get.back();
    openReportDialog(objectModel);
  });
}
