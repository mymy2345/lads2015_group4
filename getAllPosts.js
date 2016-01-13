var fs         = require('fs');
var graph      = require('fbgraph');
var csv        = require('csv-write-stream');

var exist = function (obj) {
  return typeof(obj) !== 'undefined';
}
var startDate  = '2015/10/17';
var endDate    = '2016/01/01';

var token      = require('./access');
var target     = [ 'llchu', 'tsaiingwen', 'soong2016', 'love4tw' ];

var postQueryFields = 'id,created_time,from,message,shares,type';

graph.setAccessToken(token);

var postStream    = csv();
postStream.pipe(fs.createWriteStream('posts.csv'));

var makeGet = function (args) {
  var res = [];
  Object.keys(args).map(function (key) {
    res.push([key, args[key]].join('='));
  })
  return res.join('&');
}

var processPost = function (post) {
  postStream.write({
    post_id:      post.id,
    candidate:    post.from.name,
    created_time: post.created_time,
    shares_count: (exist(post.shares))? post.shares.count: 0,
    type:         post.type,
    message:      post.message
  });
}
var pagingPosts = function(err, posts) {
  posts.data.map(processPost);
  if (exist(posts.paging) && exist(posts.paging.next)) {
    graph.get(posts.paging.next, pagingPosts);
  }
}

target.map(function (data, i) {
  graph.get(data, { fields: 'id, name' },
    function (err, page) {
      // 每個候選人
      graph.get(page.id + '/posts',
        { fields: postQueryFields, since: startDate, until: endDate },
        pagingPosts);
    });
});