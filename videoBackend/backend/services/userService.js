const db = require('../model'); // 引入您的数据库模型
const User = db.user; // 获取user模型
const md5 = require('md5')

class UserService {
  // 根据用户名查找用户
  static async findByUsername(username) {
    try {
      return await User.findOne({
        where: { username }
      });
    } catch (error) {
      throw new Error(`查找用户失败: ${error.message}`);
    }
  }

  // 根据邮箱查找用户
  static async findByEmail(email) {
    if (!email) return null;
    try {
      return await User.findOne({
        where: { email }
      });
    } catch (error) {
      throw new Error(`查找邮箱失败: ${error.message}`);
    }
  }

  // 根据手机号查找用户
  static async findByPhone(phone) {
    if (!phone) return null;
    try {
      return await User.findOne({
        where: { phone }
      });
    } catch (error) {
      throw new Error(`查找手机号失败: ${error.message}`);
    }
  }

  // 创建新用户
  static async createUser(userData) {
    const { username, password, email, phone } = userData;
    
    try {
      // 密码加密
      const hashedPassword = md5(password);
      
      // 生成默认昵称
      const nickname = `用户${Date.now().toString().slice(-6)}`;
      
      const newUser = await User.create({
        username: username.trim(),
        password: hashedPassword,
        nickname,
        email: email && email.trim() ? email.trim() : null,
        phone: phone && phone.trim() ? phone.trim() : null,
        register_time: new Date(),
        status: 0, // 正常状态
        user_level: 1 // 普通用户
      });
      
      return newUser;
    } catch (error) {
      throw new Error(`创建用户失败: ${error.message}`);
    }
  }



  // 根据ID查找用户（安全信息，不含密码）
  static async findById(userId) {
    try {
      return await User.findByPk(userId, {
        attributes: { 
          exclude: ['password'] // 排除密码字段
        }
      });
    } catch (error) {
      throw new Error(`查找用户失败: ${error.message}`);
    }
  }
  // 更新最后登录时间
  static async updateLastLoginTime(userId) {
    try {
      await User.update(
        { last_login_time: new Date() },
        { where: { user_id: userId } }
      );
    } catch (error) {
      throw new Error(`更新登录时间失败: ${error.message}`);
    }
  }



  // 检查用户名是否已存在
  static async isUsernameExists(username) {
    const user = await this.findByUsername(username);
    return !!user;
  }

  // 检查邮箱是否已存在
  static async isEmailExists(email) {
    if (!email) return false;
    const user = await this.findByEmail(email);
    return !!user;
  }

  // 检查手机号是否已存在
  static async isPhoneExists(phone) {
    if (!phone) return false;
    const user = await this.findByPhone(phone);
    return !!user;
  }
}

module.exports = UserService;