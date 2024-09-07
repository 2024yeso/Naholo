class Info {
  late var userId;
  late var userPw;
  late var userName;
  late var nickName;

  Info({
    this.userId = 'default_id', // 디폴트 값 'default_id'
    this.userPw = 'default_pw', // 디폴트 값 'default_pw'
    this.userName = 'default_name', // 디폴트 값 'default_name'
    this.nickName = 'default_nick', // 디폴트 값 'default_nick'
  });
}
