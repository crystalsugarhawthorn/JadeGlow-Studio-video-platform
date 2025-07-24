module.exports = (sequelize, DataTypes) => {
    const Favorite = sequelize.define('favorite', {
        favorite_id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false // 收藏ID，主键，自增，不允许为空
        },
        user_id: {
            type: DataTypes.BIGINT,
            allowNull: false // 用户ID，关联到user表，不允许为空
        },
        category_id: {
            type: DataTypes.BIGINT,
            allowNull: false // 分类ID，关联到category表，不允许为空
        },
        video_id: {
            type: DataTypes.BIGINT,
            allowNull: false // 视频ID，关联到video表，不允许为空
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
    return Favorite;
};