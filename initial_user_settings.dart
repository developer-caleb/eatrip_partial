import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matjipmemo/constants/common_size.dart';
import 'package:matjipmemo/constants/logger.dart';
import 'package:matjipmemo/constants/material_color.dart';
import 'package:matjipmemo/controller/login_controller.dart';
import 'package:matjipmemo/models/firebase/user_model.dart';
import 'package:matjipmemo/pages/auth/agree_location.dart';
import 'package:matjipmemo/pages/auth/agree_personal_info.dart';
import 'package:matjipmemo/pages/auth/agree_terms.dart';
import 'package:matjipmemo/repo/user_network_repository.dart';
import 'package:matjipmemo/widget/show_toast.dart';

class InitialUserSettings extends StatefulWidget {
  const InitialUserSettings({Key? key}) : super(key: key);

  @override
  _InitialUserSettingsState createState() => _InitialUserSettingsState();
}

class _InitialUserSettingsState extends State<InitialUserSettings> {
  TextEditingController nicknameController = TextEditingController();
  bool check1  = false;
  bool viewcheck1  = false;
  bool check2  = false;
  bool viewcheck2  = false;
  bool check3  = false;
  bool viewcheck3  = false;
  bool checkall  = false;
  UserModel? _userModel;
  bool processing = false;
  @override
  void dispose() {

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(Get.find<LoginController>().userModel.value==null){logger.d('유저 모델 null');}else{_userModel = Get.find<LoginController>().userModel.value;}
    return IgnorePointer(
      ignoring: processing,
      child: Scaffold(
        appBar: AppBar(
          title: Text("회원가입"),
          backgroundColor: Colors.white,
          actions: [
            IconButton(onPressed: () async{
              var text = nicknameController.text.trim();
              if(text.isEmpty){showToast("닉네임을 입력해주세요.");return;}
              if(!(check1&&check2&&check3)){showToast("필수 동의항목을 확인해주세요.");return;}
              if(text.contains("@")||text.contains("#")||text.contains(" ")){
                showToast("@, #문자, 공백은 사용하실 수 없습니다.");return;
              }
              processing= true;
               var result = await userNetworkRepository.updateInitialUserDataWithNickname( _userModel!.uid!, text, );
              if(result) {logger.d('멤버 설정 성공');//Get.back();
             await Get.find<LoginController>().changeAuthStatus();
              Get.back();
              } else {logger.d('멤버 설정 실패');}
              processing=false;
            }, icon: Text("완료", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),))
          ],
        ),
        body: WillPopScope(
          onWillPop: () {
            Get.find<LoginController>().signOut();
            return  Future(() => true);
          },
          child: Column(
          children: [
            Spacer(flex: 3,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
              child: Row(
                children: [
                  Text("닉네임", textAlign: TextAlign.left, style: TextStyle(fontSize: 16),),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: nicknameController,
                      maxLength: 15,
                    ),
                  ),
                 //  ElevatedButton(onPressed: (){}, child: Text("랜덤")),
                ],
              ),
            ),
            Spacer(flex: 1,),
            Row(
              children: [
                Checkbox(value: check1,
                    activeColor: maincolor,
                    shape: CircleBorder(),
                    onChanged: (value){
                  setState(() {
                    check1 = value!;
                    if(!viewcheck1){Get.to(()=>AgreeTerms());
                    viewcheck1= true;
                    }
                    checkallvalue();
                  });
                }),
                InkWell(
                    onTap: (){
                      viewcheck1=true;
                      Get.to(()=>AgreeTerms(agree: (bool){
                        logger.d('입력 들어옴$bool');
                        if(bool){
                          check1= bool;
                          setState(() {});
                        }
                      }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: common_s_gap),
                      child: Text('(필수) EATRIP 이용약관 동의', style: TextStyle(fontSize: 18),),
                    ))
              ],
            ),
            Row(
              children: [
                Checkbox(value: check2,
                    activeColor: maincolor,
                    shape: CircleBorder(),
                    onChanged: (value){
                 setState(() {
                   check2 = value!;
                   if(!viewcheck2){Get.to(()=>AgreePersonalInfo());
                   viewcheck2= true;
                   }
                   checkallvalue();
                 });
                }),
                InkWell(
                    onTap: (){
                      viewcheck2=true;
                      Get.to(()=>AgreePersonalInfo(agree: (bool){
                        logger.d('입력 들어옴$bool');
                        if(bool){
                          check2= bool;
                          setState(() {});
                        }
                      }));

                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: common_s_gap),
                      child: Text('(필수) 개인정보 수집 및 이용 동의', style: TextStyle(fontSize: 18),),
                    ))
              ],
            ),

            Row(
              children: [
                Checkbox(value: check3,
                    activeColor: maincolor,
                    shape: CircleBorder(),
                    onChanged: (value){
                    setState(() {
                    check3 = value!;
                    if(!viewcheck3){Get.to(()=>AgreeLocation());
                    viewcheck3= true;
                    }
                    checkallvalue();
                  });
                }),
                InkWell(
                  onTap: (){
                    viewcheck3=true;
                    Get.to(()=>AgreeLocation(agree: (bool){
                      logger.d('입력 들어옴$bool');
                      if(bool){
                        check3= bool;
                        setState(() {});
                      }
                    }));
                  },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: common_s_gap),
                      child: Text('(필수) 위치기반서비스 이용 동의', style: TextStyle(fontSize: 18),),
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Checkbox(value: checkall,
                      activeColor: maincolor,
                      shape: CircleBorder(),
                      onChanged: (value){
                    if(value!){
                      if(!viewcheck3){Get.to(()=>AgreeLocation());  viewcheck3= true;  }
                      if(!viewcheck2){Get.to(()=>AgreePersonalInfo());  viewcheck2= true;  }
                      if(!viewcheck1){Get.to(()=>AgreeTerms());  viewcheck1= true;  }
                    }
                    setState(() {
                      setAll(value);
                    });
                  }),
                  Text('전체동의', style:  TextStyle(fontSize: 18),)
                ],
              ),
            ),
            Spacer(flex: 3,),
          ],
          ),
        ),

      ),
    );
  }
  void checkallvalue(){
    if(check1&&check2&&check3){checkall = true;}
    else{checkall = false;}
  }
  void setAll(bool value){
    check1 = value;
    check2 = value;
    check3 = value;
    checkall = value;
  }
}
