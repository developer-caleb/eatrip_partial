class FollowSearchPage extends StatefulWidget {
  const FollowSearchPage({Key? key}) : super(key: key);

  @override
  State<FollowSearchPage> createState() => _FollowSearchPageState();
}

class _FollowSearchPageState extends State<FollowSearchPage> {
  var textfieldColor = Colors.grey;
  var textfieldController  = TextEditingController();
  List<UserModel> userModelList  = [];
  @override
  void dispose() {
    textfieldController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구 추가하기'),
        bottom: PreferredSize(child: Container(color: maincolor, height: 2,),
            preferredSize: Size.fromHeight(1)),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(common_gap),
              child: TextField(
                controller: textfieldController,
                autofocus: true,
                onChanged: (text) {
                   submitText(text);
                },
                decoration: InputDecoration(
                focusColor: Colors.grey,
                focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),),
                hintText: '닉네임으로 친구 검색',
                suffixIcon: IconButton(onPressed: (){
                  submitText(textfieldController.text);
                }, icon: Icon(Icons.search, color: Colors.grey,))
                ),
              ),
            ),
           GetBuilder(builder: (LoginController loginController){
             return Expanded(child: ListView(
             children: List.generate(userModelList.length, (index) => ListTile(
               leading: networkCircleImg(imgurl: userModelList[index].userimg??'',
               imgsize: iconsize_lll, replaceicon: Icons.person),
               title: Text(userModelList[index].nickname??'Unknown'),
               subtitle: Text(userModelList[index].description??'', maxLines: 1, overflow: TextOverflow.ellipsis,),
               trailing: userModelList[index].uid== loginController.userModel.value!.uid? SizedBox.shrink(): SizedBox(
                   width : Get.size.width*0.3,
                   child: Obx(() => loginController.userModel.value!.following.contains(userModelList[index].uid)?
                   OutlinedButton(onPressed: (){
                     logger.d('팔로->언팔로우 버튼');
                     userNetworkRepository.cancelFollowUser(userModelList[index].uid!, loginController.userModel.value!.uid!);
                   }, child: Text("팔로잉", style: TextStyle(color: Colors.black54),)):
                   OutlinedButton(onPressed: (){
                     logger.d('언팔로우->팔로우 버튼');
                     userNetworkRepository.setFollowUser(userModelList[index].uid!, loginController.userModel.value!.uid!);
                   }, child: Text("팔로우" ,style: TextStyle(color: Colors.black87),),
                       style: OutlinedButton.styleFrom(
                         side: BorderSide(width: 2.0, color: maincolor.withOpacity(0.5)),
                       )),
                   )),
               onTap: userModelList[index].uid ==loginController.userModel.value!.uid ? null :   (){
                 logger.d('go profile -> ${userModelList[index].uid}');
                 Get.to(()=>OthersProfilePage(userModelList[index].uid!));
               },
            ))));})
          ],
        ),
      ),
    );
  }

  Future submitText(String text) async{
    if(text.isEmpty){}else{
      userModelList =await userNetworkRepository.queryUserList(text);
      setState(() {});
    }
  }
}
