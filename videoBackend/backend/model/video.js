module.exports = (sequelize, DataTypes) => {
    const Video = sequelize.define('video', {
        video_id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false
            // 视频ID，主键，自增，不允许为空
        },
        title: {
            type: DataTypes.STRING(200),
            allowNull: false
            // 视频标题，最大长度为200字符，不允许为空
        },
        description: {
            type: DataTypes.TEXT,
            allowNull: true
            // 视频描述，允许为空
        },
        cover_url: {
            type: DataTypes.STRING(255),
            allowNull: false
            // 视频封面URL，最大长度为255字符，不允许为空
        },
        video_url: {
            type: DataTypes.STRING(255),
            allowNull: false
            // 视频文件URL，最大长度为255字符，不允许为空
        },
        duration: {
            type: DataTypes.INTEGER,
            allowNull: false
            // 视频时长（秒），不允许为空
        },
        status: {
            type: DataTypes.TINYINT,
            allowNull: false,
            defaultValue: 0
            // 视频状态（0 - 草稿，1 - 审核中，2 - 已发布，3 - 下架），默认值为0
        },
        view_count: {
            type: DataTypes.BIGINT,
            allowNull: false,
            defaultValue: 0
            // 视频播放次数，默认值为0
        },
        like_count: {
            type: DataTypes.BIGINT,
            allowNull: false,
            defaultValue: 0
            // 视频点赞数，默认值为0
        },
        publish_time: {
            type: DataTypes.DATE,
            allowNull: true
            // 视频发布时间，允许为空
        },
        create_time: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW
            // 创建时间，默认值为当前时间
        },
        update_time: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW
            // 更新时间，默认值为当前时间
        },
        category: { 
            type: DataTypes.INTEGER,
            allowNull: false
            // 视频分类，不允许为空,0 - 电视剧，1 - 电影，2 - 动漫，3 - 纪实，4 - 短视频
        },
    },{
        freezeTableName: true, // 不自动复数化表名
        timestamps: false // 不自动添加 createdAt 和 updatedAt 字段
    }); 
    return Video;
}