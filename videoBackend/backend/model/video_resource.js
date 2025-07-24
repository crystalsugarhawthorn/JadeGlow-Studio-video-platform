module.exports = (sequelize, DataTypes) => {
    const VideoResource = sequelize.define('video_resource', {
        resource_id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false // 资源ID，主键，自增，不允许为空
        },
        video_id: {
            type: DataTypes.BIGINT,
            allowNull: false // 视频ID，关联到video表，不允许为空
        },
        resolution: {
            type: DataTypes.STRING(50),
            allowNull: false // 清晰度，例如 "1080p"、"720p" 等，不允许为空
        },
        file_url: {
            type: DataTypes.STRING(255),
            allowNull: false // 视频文件URL，最大长度为255字符，不允许为空
        },
        file_size: {
            type: DataTypes.BIGINT,
            allowNull: false // 文件大小（字节），不允许为空
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
    return VideoResource;
};