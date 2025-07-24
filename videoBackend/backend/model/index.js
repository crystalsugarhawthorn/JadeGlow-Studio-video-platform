const config = require('../config/db.js');
const { Sequelize, DataTypes } = require('sequelize');
const sequelize = new Sequelize(config.database, config.username, config.password,config.option);

const User = require('./user.js')(sequelize, DataTypes);
const UserProfile = require('./user_profile.js')(sequelize, DataTypes);
const Video = require('./video.js')(sequelize, DataTypes);
const Comment = require('./comment.js')(sequelize, DataTypes);
const Like = require('./like.js')(sequelize, DataTypes);
const Favorite = require('./favorite.js')(sequelize, DataTypes);
const WatchHistory = require('./watch_history.js')(sequelize, DataTypes);
const VideoResource = require('./video_resource.js')(sequelize, DataTypes);
const VideoTag = require('./video_tag.js')(sequelize, DataTypes);
const Danmaku = require('./danmaku.js')(sequelize, DataTypes);
const SwiperModel = require('./swiper.js')(sequelize, DataTypes);
const ShortVideoHistory = require('./short_video_history.js')(sequelize, DataTypes);
const ShortVideoCollect = require('./short_video_collect.js')(sequelize, DataTypes);

// 声明表之间的关系
User.hasOne(UserProfile, { foreignKey: 'user_id' });
UserProfile.belongsTo(User, { foreignKey: 'user_id' });

Video.hasMany(Comment, { foreignKey: 'video_id' });
Comment.belongsTo(Video, { foreignKey: 'video_id' });

User.hasMany(Comment, { foreignKey: 'user_id' });
Comment.belongsTo(User, { foreignKey: 'user_id' });

Video.hasMany(Like, { foreignKey: 'video_id' });
Like.belongsTo(Video, { foreignKey: 'video_id' });

Comment.hasMany(Like, { foreignKey: 'comment_id' });
Like.belongsTo(Comment, { foreignKey: 'comment_id' });

User.hasMany(Like, { foreignKey: 'user_id' });
Like.belongsTo(User, { foreignKey: 'user_id' });

Video.hasMany(Favorite, { foreignKey: 'video_id' });
Favorite.belongsTo(Video, { foreignKey: 'video_id' });

User.hasMany(Favorite, { foreignKey: 'user_id' });
Favorite.belongsTo(User, { foreignKey: 'user_id' });

Video.hasMany(WatchHistory, { foreignKey: 'video_id' });
WatchHistory.belongsTo(Video, { foreignKey: 'video_id' });

User.hasMany(WatchHistory, { foreignKey: 'user_id' });
WatchHistory.belongsTo(User, { foreignKey: 'user_id' });

Video.hasMany(VideoResource, { foreignKey: 'video_id' });
VideoResource.belongsTo(Video, { foreignKey: 'video_id' });

// Video 有一个 VideoTag（详细信息）
Video.hasOne(VideoTag, {foreignKey: 'video_id'});

// VideoTag 属于一个 Video
VideoTag.belongsTo(Video, {foreignKey: 'video_id'});

Danmaku.belongsTo(Video, { foreignKey: 'video_id' });
Video.hasMany(Danmaku, { foreignKey: 'video_id' });

Danmaku.belongsTo(User, { foreignKey: 'user_id' });
User.hasMany(Danmaku, { foreignKey: 'user_id' });


// ShortVideoHistory 属于一个 User
ShortVideoHistory.belongsTo(User, {
    foreignKey: 'user_id',
    targetKey: 'user_id',
    as: 'userDetails' // <<< 缺少了这个！请加上
});
// User 可以有很多 ShortVideoHistory
User.hasMany(ShortVideoHistory, {
    foreignKey: 'user_id',
    as: 'shortVideoHistory' // 建议也给 hasMany 加一个别名，虽然不是导致当前错误的直接原因
});

// ShortVideoHistory 属于一个 Video
ShortVideoHistory.belongsTo(Video, {
    foreignKey: 'video_id',
    targetKey: 'video_id',
    as: 'videoDetails' // 这个是正确的
});
// Video 可以有很多 ShortVideoHistory (如果需要通过视频查历史)
Video.hasMany(ShortVideoHistory, {
    foreignKey: 'video_id',
    as: 'historyRecords' // 建议也给 hasMany 加一个别名
});


// ShortVideoCollect 属于一个 User
ShortVideoCollect.belongsTo(User, {
    foreignKey: 'user_id',
    targetKey: 'user_id',
    as: 'userDetails' // <<< 缺少了这个！请加上
});
// User 可以有很多 ShortVideoCollect
User.hasMany(ShortVideoCollect, {
    foreignKey: 'user_id',
    as: 'shortVideoCollects' // 建议也给 hasMany 加一个别名
});

// ShortVideoCollect 属于一个 Video
ShortVideoCollect.belongsTo(Video, {
    foreignKey: 'video_id',
    targetKey: 'video_id',
    as: 'videoDetails' // 这个是正确的
});
// Video 可以有很多 ShortVideoCollect (如果需要通过视频查收藏)
Video.hasMany(ShortVideoCollect, {
    foreignKey: 'video_id',
    as: 'collectRecords' // 建议也给 hasMany 加一个别名
});

// 自动同步所有模型
sequelize.sync()

exports.user = User;
exports.userProfile = UserProfile;
exports.video = Video;
exports.comment = Comment;
exports.like = Like;
exports.favorite = Favorite;
exports.watchHistory = WatchHistory;
exports.videoResource = VideoResource;
exports.videoTag = VideoTag;
exports.danmaku = Danmaku;
exports.swiper = SwiperModel;
exports.short_video_history = ShortVideoHistory;
exports.short_video_collect = ShortVideoCollect;