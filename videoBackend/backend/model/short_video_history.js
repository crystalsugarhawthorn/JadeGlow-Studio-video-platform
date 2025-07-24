module.exports = (sequelize, DataTypes) => {
    const ShortVideoHistory = sequelize.define('short_video_history', {
        id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false // 历史记录ID，主键，自增，不允许为空
        },
        user_id: {
            type: DataTypes.BIGINT,
            allowNull: false // 用户ID，关联到user表，不允许为空
        },
        video_id: {
            type: DataTypes.BIGINT,
            allowNull: false // 视频ID，关联到video表 (category=4)，不允许为空
        },
        watch_time: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW // 观看时间，默认值为当前时间
        },
        last_watched_progress: {
            type: DataTypes.INTEGER, // 对应 MySQL 的 INT
            allowNull: true, // 允许为空，因为 MySQL 中默认值是 0
            defaultValue: 0 // 上次观看进度，单位秒
        }
    }, {
        freezeTableName: true, // 不自动复数化表名
        timestamps: false // 不自动添加 createdAt 和 updatedAt 字段
    });

    // 可以在这里定义关联关系，例如：
    // ShortVideoHistory.associate = (models) => {
    //     ShortVideoHistory.belongsTo(models.User, { foreignKey: 'user_id', targetKey: 'user_id' });
    //     ShortVideoHistory.belongsTo(models.Video, { foreignKey: 'video_id', targetKey: 'video_id' });
    // };

    return ShortVideoHistory;
};