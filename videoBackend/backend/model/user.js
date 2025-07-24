module.exports = (sequelize, DataTypes) => { 
    const User = sequelize.define('user', {
        user_id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false // 用户ID，主键，自增，不允许为空
        },
        username: {
            type: DataTypes.STRING(50),
            unique: true,
            allowNull: false // 用户名，唯一，不允许为空
        },
        password: {
            type: DataTypes.STRING(100),
            allowNull: false // 用户密码，不允许为空
        },
        nickname: {
            type: DataTypes.STRING(50),
            allowNull: false,
            defaultValue: '快去取一个昵称吧~' // 昵称，不允许为空，默认值为'快去取一个昵称吧~'
        },
        avatar: {
            type: DataTypes.STRING(255),
            allowNull: true // 头像URL，允许为空
        },
        phone: {
            type: DataTypes.STRING(20),
            unique: true,
            allowNull: true // 手机号码，唯一，允许为空
        },
        email: {
            type: DataTypes.STRING(100),
            unique: true,
            allowNull: true // 电子邮件，唯一，允许为空
        },
        register_time: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW // 注册时间，不允许为空，默认值为当前时间
        },
        status: {
            type: DataTypes.TINYINT,
            allowNull: false,
            defaultValue: 0 // 用户状态，不允许为空，默认值为0（0 - 正常，1 - 封禁，2 - 注销）
        },
        user_level: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 1 // 用户等级，不允许为空，默认值为1
        },
        last_login_time: {
            type: DataTypes.DATE,
            allowNull: true // 最后登录时间，允许为空
        }
    },{
        freezeTableName: true, // 不自动复数化表名
        timestamps: false // 不自动添加 createdAt 和 updatedAt 字段
    });
    return User;
};