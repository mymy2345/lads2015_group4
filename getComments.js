var post_id    = process.argv[2];

var fs         = require('fs');
var graph      = require('fbgraph');
var csv        = require('csv-write-stream');

var exist = function (obj) {
  return typeof(obj) !== 'undefined';
}
var startDate  = '2015/10/17';
var endDate    = '2016/01/01';

var token      = require('../access');

var commentQueryFields = 'id,created_time,from,message,comment_count,like_count';

graph.setAccessToken(token);

var commentStream = csv();
commentStream.pipe(fs.createWriteStream('comments' + post_id + '.csv'));

var makeGet = function (args) {
  var res = [];
  Object.keys(args).map(function (key) {
    res.push([key, args[key]].join('='));
  })
  return res.join('&');
}

var makePagingComments = function (pid, link) {
  graph.get(link, function (err, comments) {
    if (comments == null) {
      console.log(err, comments);
    }
    comments.data.map(function (comment, i) {
      commentStream.write({
        user_id:       comment.from.id,
        comment_id:    comment.id,
        parent_id:     pid,
        created_time:  comment.created_time,
        comment_count: comment.comment_count,
        like_count:    comment.like_count,
        message:       comment.message
      });
      makePagingComments(comment.id, comment.id + '/comments?' + makeGet({
        fields: commentQueryFields,
        since:  startDate,
        until:  endDate
      }));
    });
    if (exist(comments.paging) && exist(comments.paging.next)) {
      makePagingComments(pid, comments.paging.next);
    }
  });
}

makePagingComments(post_id, post_id + '/comments?' + makeGet({
  fields: commentQueryFields,
  since:  startDate,
  until:  endDate
}));