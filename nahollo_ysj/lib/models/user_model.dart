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
  int image;

  UserModel({
    this.userId = "userId",
    this.userPw = "userPw",
    this.name = "name",
    this.phone = "phone",
    this.birth = "birth",
    this.gender = "gender",
    this.nickName = "nickName",
    this.userCharacter = "userCharacter",
    this.lv = 0,
    this.introduce = "introduce",
    this.image = 1,
  });
}
