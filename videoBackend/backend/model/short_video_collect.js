module.exports = (sequelize, DataTypes) => {
    const ShortVideoCollect = sequelize.define('short_video_collect', {
        id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false // 收藏记录ID，主键，自增，不允许为空
        },
        user_id: {
            type: DataTypes.BIGINT,
            allowNull: false // 用户ID，关联到user表，不允许为空
        },
        video_id: {
            type: DataTypes.BIGINT,
            allowNull: false // 视频ID，关联到video表 (category=4)，不允许为空
        },
        collect_time: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW // 收藏时间，默认值为当前时间
        }
    }, {
        freezeTableName: true, // 不自动复数化表名
        timestamps: false // 不自动添加 createdAt 和 updatedAt 字段
    });

    // 可以在这里定义关联关系，例如：
    // ShortVideoCollect.associate = (models) => {
    //     ShortVideoCollect.belongsTo(models.User, { foreignKey: 'user_id', targetKey: 'user_id' });
    //     ShortVideoCollect.belongsTo(models.Video, { foreignKey: 'video_id', targetKey: 'video_id' });
    // };

    return ShortVideoCollect;
};