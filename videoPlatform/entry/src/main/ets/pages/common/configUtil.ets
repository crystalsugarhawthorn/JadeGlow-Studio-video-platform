export  class ConfigUtil{
  static readonly IP = "192.168.75.1"
  static readonly SERVER=`http://${this.IP}:3000`
  static readonly SERVERURL=`http://${this.IP}:3000/uploads/`
  static readonly SERVER_URL_COVERS=`http://${this.IP}:3000/uploads/covers/`
  static readonly SERVER_URL_VIDEOS=`http://${this.IP}:3000/uploads/videos/`
  static readonly SERVER_URL_USER=`http://${this.IP}:3000/uploads/user/`
  static readonly HTTP_CODE_200=200  // 成功

  static readonly SERVER_NET_SUCCESS: string = '请求数据成功';
  static readonly SERVER_NET_ERROR: string = '请求失败请检查网络';

  static readonly HTTP_CONNECT_TIMEOUT: number = 10000;
  static readonly HTTP_READ_TIMEOUT: number = 10000;
}