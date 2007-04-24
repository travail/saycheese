function ShowIndicator() {
  $('thumbnail').innerHTML = '<img id="thumbnail_path" width="32" height="32" src="/static/images/loading.gif" alt="Loading..." />';
}

function ShowBouncing(id) {
  thumb_delete = 'thumb-delete' + id;
  $(thumb_delete).innerHTML = '<img width="16" height="16" src="/static/images/loading-bouncing.gif" alt="Loading..." />';
}

function DeleteThumbnail(id) {
  new Ajax.Request('/ajaxrequest/thumbnail/delete', {
    method: 'get',
    parameters:     '&id=' + id,
    onCreated:      ShowBouncing(id),
    onAccepted:     ShowBouncing(id),
    onLoading:      ShowBouncing(id),
    onLoaded:       ShowBouncing(id),
    onInterractive: ShowBouncing(id),
    onComplete:     function(request) {
      var param = '&page=1'
      new Ajax.Updater('thumbnails', '/ajaxrequest/thumbnail/recent_thumbnails', {
        method: 'get',
        parameters: param,
        asynchronous: true
      });
    }.bind(this)
  })
}

function Thumbnail(url) {
  new Ajax.Request('/ajaxrequest/thumbnail/create', {
    method: 'get',
    parameters:    '&url=' + url,
    onCreated:     ShowIndicator(),
    onAccepted:    ShowIndicator(),
    onLoading:     ShowIndicator(),
    onLoaded:      ShowIndicator(),
    onInteractive: ShowIndicator(),
    onComplete:    function(request) {
      var obj = eval("("+request.responseText+")");
      ShowThumbnail(obj);

      var param = '&page=1'
      new Ajax.Updater('thumbnails', '/ajaxrequest/thumbnail/recent_thumbnails', {
        method: 'get',
        parameters: param,
        asynchronous: true
      });
    }.bind(this)
  });
}

function ShowThumbnail(obj) {
  $('thumbnail_path').src    = '/static/thumbnail/' + obj.id + '.' + obj.extention;
  $('thumbnail_path').alt    = obj.thumbnail_name;
  $('thumbnail_path').width  = obj.width;
  $('thumbnail_path').height = obj.height;
}
