class UserModel {
  String userId;
  String userPw;
  String name;
  String phone;
  String birth;
  String gender;
  String nickName;
  String userCharacter;
  int lv;
  String introduce;
  String introduceDiary;
  String image;
  int exp;

  UserModel({
    this.userId = "userId",
    this.userPw = "userPw",
    this.name = "name",
    this.phone = "phone",
    this.birth = "birth",
    this.gender = "gender",
    this.nickName = "nickName",
    this.userCharacter = "hedgehog",
    this.lv = 0,
    this.introduce = "introduce",
    this.introduceDiary = 'introduceDiary',
    this.image = "image",
    this.exp = 0
  });
}
