module.exports = (sequelize, DataTypes) => {
    const VideoTag = sequelize.define('video_tag', {
        video_id: {
            type: DataTypes.BIGINT,
            allowNull: false, // 视频ID，关联到video表，不允许为空
            primaryKey: true  // 设为主键，因为每个视频只有一条记录
        },
        year: {
            type: DataTypes.INTEGER, // 年份，如2024
            allowNull: true,
            validate: {
                min: 1900,
                max: new Date().getFullYear() + 5 // 允许未来几年的年份
            },
            comment: '发行年份'
        },
        region: {
            type: DataTypes.STRING(50), // 地区，如"中国大陆"、"美国"等
            allowNull: true,
            comment: '制作地区'
        },
        genre: {
            type: DataTypes.STRING(100), // 题材，如"动作片"、"喜剧片"等
            allowNull: true,
            comment: '视频题材类型'
        },
        rating: {
            type: DataTypes.DECIMAL(3, 1), // 评分，如9.5分，精度为3位数字，1位小数
            allowNull: true,
            validate: {
                min: 0.0,
                max: 10.0
            },
            comment: '视频评分，范围0-10'
        },
        create_time: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW // 创建时间，默认值为当前时间
        }
    }, {
        freezeTableName: true, // 不自动复数化表名
        timestamps: false // 不自动添加 createdAt 和 updatedAt 字段
    });
    return VideoTag;
};