module.exports = (sequelize, DataTypes) => {
    const WatchHistory = sequelize.define('watch_history', {
        history_id: {
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
            allowNull: false // 视频ID，关联到video表，不允许为空
        },
        watch_time: {
            type: DataTypes.INTEGER,
            allowNull: false // 播放时长（秒），不允许为空
        },
        last_watch_time: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW // 最后观看时间，默认值为当前时间
        }
    },{
        freezeTableName: true, // 不自动复数化表名
        timestamps: false // 不自动添加 createdAt 和 updatedAt 字段
    });
    return WatchHistory;
};