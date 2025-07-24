module.exports = (sequelize, DataTypes) => {
    const UserProfile = sequelize.define('user_profile', {
        profile_id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false
            // 主键ID，自增，不允许为空
        },
        gender: {
            type: DataTypes.TINYINT,
            allowNull: true,
            defaultValue: 0
            // 用户性别，0表示未知，1表示男性，2表示女性，默认值为0
        },
        birthday: {
            type: DataTypes.DATE,
            allowNull: true
            // 用户生日，允许为空
        },
        signature: {
            type: DataTypes.STRING(500),
            allowNull: true
            // 用户签名，最大长度为500字符，允许为空
        },
        update_time: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW
            // 更新时间，默认值为当前时间，不允许为空
        },
        user_id: {
            type: DataTypes.BIGINT,
            allowNull: false
            // 用户ID，不允许为空
        }
    },{
        freezeTableName: true, // 不自动复数化表名
        timestamps: false // 不自动添加 createdAt 和 updatedAt 字段
    });
    return UserProfile;
};