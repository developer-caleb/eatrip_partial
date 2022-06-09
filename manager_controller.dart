import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:matjipmemo/constants/const_location.dart';
import 'package:matjipmemo/constants/logger.dart';
import 'package:matjipmemo/controller/login_controller.dart';
import 'package:matjipmemo/models/firebase/matjip_model.dart';
import 'package:matjipmemo/models/firebase/user_model.dart';
import 'package:matjipmemo/repo/matjip_network_repository.dart';
import 'package:matjipmemo/tools/enums.dart';


import '../constants/strings.dart';
import '../tools/location_tools.dart';

class ManagerController extends GetxController{
  static ManagerController get to => Get.find();
  //List<FirebaseFolderModel> folderModellist= [];
  RxList<MatjipModel> _matjipModelList= [MatjipModel.sample()].obs;
  RxList<MatjipModel> get matjipModelList => _matjipModelList;
  Map<String, String> _progressText = {}; //일단 광장에서 받는 걸로 해결하자

 // File? folderdirectory;
  //File? filedirectory;
  //String localpath ='';
  RxString progressText=''.obs;
  RxBool scrollable  = false.obs;
  Rx<PageState> pageState = PageState.Loading.obs;
  RxList groupedMatjipList = [].obs;

  RxString _selectedGrouping = groupingList[0].obs;
  RxString  get selectedGrouping => _selectedGrouping;

  @override
  void onInit() async{
    _matjipModelList([]);
    //localpath = await fileInternalRepository.localfileaddress;
    //await _getfolderModelList();
    //folderdirectory =  File('$localpath/folders.json');

    super.onInit();
  }

  Future managerSignout() async{
    var myposition = await getPosition();
    _matjipModelList([MatjipModel.sample(mylocation: myposition==null? seoulcityGeoPoint: GeoPoint(myposition.latitude, myposition.longitude))]);
    update();
  }
 /* Future<void> _getfolderModelList() async {
    try{
      folderModellist=await fileInternalRepository.readFolders();
    }catch(e){print(e.toString());
    folderModellist=[];
    }
  }*/
  void setSelectedGrouping(String selectedGrouping, String queryText) async{
    pageState(PageState.Loading);
    if(_selectedGrouping.value != selectedGrouping){
      _selectedGrouping(selectedGrouping);
      logger.d('setSelectedGrouping $selectedGrouping');
      await getMatjipModelListFromFirebase(queryText:  queryText);
    } //똑같은 거 클릭하면 함수 없이 그냥 보내 버리기
    pageState(PageState.Done);
  }
  void setProgressText(String text){
    progressText(text);
  }
  void deleteMatjip(MatjipModel matjip ){
    logger.d('deleteMatjip ${matjip.matjipid} , ${matjip.matjipname}');
    _matjipModelList.removeWhere((element) => element.matjipid==matjip.matjipid);
    updates();
  }
  void updates(){
    newSortList();
  }
  Future moreScroll() async {
    if(scrollable.value==false){return;}
    pageState(PageState.Loading);
    logger.d('morescroll -> ${matjipModelList.last.matjipname}');
    UserModel? loginUser = Get.find<LoginController>().userModel.value;
    if(loginUser!=null) {
      var count =40;
     List<MatjipModel> resultList =  await matjipNetworkRepository.readManageMatjipList(loginUser.uid! , count: count, lastDocref: matjipModelList.last.reference, selectedGrouping: selectedGrouping.value);
      newSortList(scrollMatjipList:resultList);
     _matjipModelList.addAll(resultList);
     if(count ==resultList.length){scrollable(true);}else{scrollable(false);}
    }
    pageState(PageState.Done);
    //update();
  }
  void newSortList({List<MatjipModel>? scrollMatjipList }){
    var newList = [];
    List<MatjipModel> targetMatjipList = scrollMatjipList==null ?  _matjipModelList : scrollMatjipList ;
    for(int i=0;i< targetMatjipList.length;i++) {
      var element = targetMatjipList[i];
      switch(selectedGrouping.value){
        case '방문여부':  element.groupingfactor=  element.visited? '가본 곳':'가볼 곳'; break;
        case '지역별': element.groupingfactor =  element.addresssimple!= null ?  element.addresssimple! : '🏠기타'; break;
        case '카테고리': {
          element.groupingfactor =element.orderCategory?? '🥘 기타'; break;
        }
        case '상호별': element.groupingfactor =  '상호별'; break;
        case '날짜별': element.groupingfactor =  element.orderDate?? '🥘 기타';
        break;
      }
      if(scrollMatjipList!=null && _matjipModelList.last.groupingfactor == targetMatjipList[i].groupingfactor) {
        logger.d('이미 있는 카테고리임, targetMatjipList[i] ${targetMatjipList[i]}, ${targetMatjipList[i].groupingfactor}');
      }//이거 안해주면 새로 불러왔을 때도 기존에 있는 카테고리가 추가 되기 때문에 해줘야 함
      else{
        if(i==0){newList.add(element.groupingfactor);}
        else if( targetMatjipList[i-1].groupingfactor != targetMatjipList[i].groupingfactor){
          newList.add(element.groupingfactor);
        }
      }
      newList.add(element);
    }
    if(scrollMatjipList==null){groupedMatjipList(newList);}else{groupedMatjipList.addAll(newList);}
  }

  //TODO : 1차적으로 firebase 에서 소팅함, 2차적으로 grouped_list에서(필수) 소팅함
  //deprecated 22.03.28
/*  void sortList(){
    //그룹 정의
    _matjipModelList.forEach((element) {
      switch(selectedGrouping.value){
      case '방문여부':  element.groupingfactor=  element.visited? '가본 곳':'가볼 곳'; break;
      case '지역별': element.groupingfactor =  element.addresssimple!= null ?  element.addresssimple! : '🏠기타'; break;
      case '카테고리': {
      element.groupingfactor =element.orderCategory?? '🥘 기타'; break;
      }
      case '상호별': element.groupingfactor =  element.matjipname!; break;
      case '날짜별': element.groupingfactor =  element.orderDate?? '🥘 기타';
      break;
    }
    });
    //2차 소팅-> 그룹소팅
    _matjipModelList.sort((MatjipModel a, MatjipModel b) =>
    ['날짜별'].contains(_selectedGrouping)?  b.groupingfactor.compareTo(a.groupingfactor) :   a.groupingfactor.compareTo(b.groupingfactor));

    //1차 소팅-> 일반소팅
    switch(selectedGrouping.value){
      case '상호별' : _matjipModelList.sort( (MatjipModel a, MatjipModel b) => a.matjipname!.compareTo(b.matjipname!) ); break;
      default : _matjipModelList.sort( (MatjipModel a, MatjipModel b) => b.created.compareTo(a.created) ); break;
    }
  }*/

  void updateMatjip(MatjipModel afterModel){
    var index = _matjipModelList.indexWhere((element) => element.matjipid == afterModel.matjipid);
    if(index!=-1){
      logger.d('logger-> updateMatjip ${afterModel.matjipname} \n'
          '${afterModel.imageurls}'
          '${afterModel.toString()}'
      );
      //지우고 추가해야함 -> 그렇지 않으면 이미지 삭제 시 controller 반영이 안 됨!
      _matjipModelList[index] = afterModel;
      updates(); //22.05.30 추가. 나머지 코드에서는 없어도 실행 되었는데 찾았는데 동일한 곳 나와서 수정해줬을 때
      //_groupedList에 반영이 안 되는 것 같아서 추가 시켜 준 것임.
      //내 생각에는 수정으로 하면 그 수정 model이 주소에 그대로 수정되니까 _groupedList 수정안해줘도 되는 듯?
      //아무튼 문제 생길 시 여기 참고하면 될 듯하다.
    }
  }

  Future getMatjipModelListFromFirebase({String? queryText}) async
  {
    pageState(PageState.Loading);
    logger.d("_getMatjipModelListFromFirebase");
    UserModel? loginUser = Get.find<LoginController>().userModel.value;
    var loginstate = Get.find<LoginController>().authStatus.value;
    if(loginstate == AuthStatus.PROCESSING){
      logger.d('Login state => Progress');
      pageState(PageState.Done);
      return;
    }
    if(loginUser==null) {
      if(loginstate==AuthStatus.SIGNOUT){
      logger.d("uid is empty");
      var myposition = await getPosition();
      _matjipModelList([MatjipModel.sample(mylocation: myposition==null? seoulcityGeoPoint: GeoPoint(myposition.latitude, myposition.longitude))]);
      pageState(PageState.Done);
      scrollable(false);
      updates();
      return;
      }
    }
      var count =40;
      logger.d("get matjipModellist ${loginUser!.uid} selectedGrouping -> $selectedGrouping");
      List<MatjipModel> resultList=[];
      if (queryText?.isEmpty??true) resultList=await matjipNetworkRepository.readManageMatjipList( loginUser.uid!, count: count, selectedGrouping: selectedGrouping.value);
      else resultList=await matjipNetworkRepository.queryManageMatjipList(queryText!, loginUser);
      _matjipModelList(resultList);
      if(resultList.length == count){
        scrollable(true);
      }else{scrollable(false);}
      pageState(PageState.Done);
      updates();
  }
  void setscrollable(bool value){
    scrollable(value);
  }

  void addMatjipModelToList(MatjipModel matjipModel) {
    MatjipModel newMatjipModel= matjipModel;
    logger.d("addMatjipModelToList : ${newMatjipModel.toString()}");
    _matjipModelList.insert(0, newMatjipModel);
    updates();
  }
  void setMatjpList(List<MatjipModel> matjiplist){
    _matjipModelList(matjiplist);
    updates();
  }


  /*Future<File> addFolder(FirebaseFolderModel folderModel, {FirebaseFolderModel category}) async{
    print(folderModellist.toString());
    if(folderModellist.indexWhere((element) => element.foldername==folderModel.foldername)!=-1)
    {print('동일한 이름의 폴더 또는 카테고리가 있습니다.'); return null;}
    folderModellist.add(folderModel);
    if(category!=null){
      folderModellist
          .where((element) => element.folderid == category.folderid)
          .forEach((element) {
      });
    }
    print(folderModel.toString());

    print(folderdirectory);
    /// Write to the file
    savefolder();
  }*/

/*
  Future savefolder() async{
    var listfoldermap = [];
    List<FirebaseFolderModel> folderModellist2 = [];
    folderModellist.where((element) => element.parentFolderName==null).forEach((element) {
      listfoldermap.add(element.toMap());
      folderModellist2.add(element);
    });
    folderModellist.where((element) => element.parentFolderName!=null).forEach((element) {
      listfoldermap.add(element.toMap());
      folderModellist2.add(element);
    });
    folderModellist = folderModellist2;
    update();
    print('폴더 추가->${listfoldermap.toString()}');
    return folderdirectory.writeAsString(jsonEncode(listfoldermap));
  }
  bool folderCheck(String foldermodelname){
    if(folderModellist.indexWhere((element) => element.name==foldermodelname)!=-1)
    {print('동일한 이름의 폴더 또는 카테고리가 있습니다.'); return false;}
    else return true;
  }*/


}
