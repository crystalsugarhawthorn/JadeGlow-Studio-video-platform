module.exports = (sequelize, DataTypes) => {
    const Danmaku = sequelize.define('danmaku', {
        danmaku_id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false // 弹幕ID，主键，自增，不允许为空
        },
        video_id: {
            type: DataTypes.BIGINT,
            allowNull: false // 视频ID，关联到video表，不允许为空
        },
        user_id: {
            type: DataTypes.BIGINT,
            allowNull: false // 用户ID，关联到user表，不允许为空
        },
        content: {
            type: DataTypes.STRING(200),
            allowNull: false // 弹幕内容，最大长度为200字符，不允许为空
        },
        time_offset: {
            type: DataTypes.INTEGER,
            allowNull: false // 弹幕出现的时间偏移量（秒），不允许为空
        },
        color: {
            type: DataTypes.STRING(7),
            allowNull: false // 弹幕颜色，格式为 "#RRGGBB"，不允许为空
        },
        position: {
            type: DataTypes.TINYINT,
            allowNull: false,
            defaultValue: 0 // 弹幕位置（0 - 底部，1 - 中间，2 - 顶部），默认值为0
        },
        create_time: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW // 创建时间，默认值为当前时间
        }
    },{
        freezeTableName: true, // 不自动复数化表名
        timestamps: false // 不自动添加 createdAt 和 updatedAt 字段
    });
    return Danmaku;
};