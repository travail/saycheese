function AbleSayCheese() { $('form_request').disabled = ''; };
function DisableSayCheese() { $('form_request').disabled = 'disabled'; }
function DisableSearchThumbnail() { $('form_search').disabled = 'disabled'; }

function ShowIndicator() {
  $('thumbnail').innerHTML = '<img id="thumbnail_path" width="192" height="14" src="/static/images/progress_bar.gif" alt="Loading..." />';
}

function ShowBouncing(id,pos) {
  position = pos + id;
  $(position).innerHTML = '<img width="16" height="16" src="/static/images/loading-bouncing.gif" alt="Loading..." />';
}

function UpdateThumbnail(id) {
  new Ajax.Request('/ajaxrequest/thumbnail/update', {
    method: 'get',
    parameters:     '&id=' + id,
    onCreated:      ShowBouncing(id,'thumb-update'),
    onAccepted:     ShowBouncing(id,'thumb-update'),
    onLoading:      ShowBouncing(id,'thumb-update'),
    onLoaded:       ShowBouncing(id,'thumb-update'),
    onInterractive: ShowBouncing(id,'thumb-update'),
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

function DeleteThumbnail(id) {
  new Ajax.Request('/ajaxrequest/thumbnail/delete', {
    method: 'get',
    parameters:     '&id=' + id,
    onCreated:      ShowBouncing(id,'thumb-delete'),
    onAccepted:     ShowBouncing(id,'thumb-delete'),
    onLoading:      ShowBouncing(id,'thumb-delete'),
    onLoaded:       ShowBouncing(id,'thumb-delete'),
    onInterractive: ShowBouncing(id,'thumb-delete'),
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

function SearchThumbnail(url) {
  if (!url) { return; }
  DisableSearchThumbnail();

  $('form_saycheese').action = $('form_saycheese').action + '?url=' + url;
  $('form_saycheese').submit();
}

function Thumbnail(url) {
  if (!url) { return; }
  DisableSayCheese();

  new Ajax.Request('/ajaxrequest/thumbnail/create', {
    method: 'get',
    parameters:    '&url=' + encodeURIComponent(url),
    onCreated:     ShowIndicator(),
    onAccepted:    ShowIndicator(),
    onLoading:     ShowIndicator(),
    onLoaded:      ShowIndicator(),
    onInteractive: ShowIndicator(),
    onComplete:    function(request) {
      var obj = eval("("+request.responseText+")");
      if (obj.id) {
        ShowThumbnail(obj);
        var param = '&page=1'
        new Ajax.Updater('thumbnails', '/ajaxrequest/thumbnail/recent_thumbnails', {
          method: 'get',
          parameters: param,
          asynchronous: true
        });
      } else {
        $('thumbnail').innerHTML = '<div class="error">Could not get response.<br />Check the URL you input.</div>';
      }
      AbleSayCheese();
    }.bind(this)
  });
}

function ShowThumbnail(obj) {
  $('thumbnail_path').src    = '/static/thumbnail/' + obj.id + '.' + obj.extension;
  $('thumbnail_path').alt    = obj.thumbnail_name;
  $('thumbnail_path').width  = 200;
  $('thumbnail_path').height = 150;
}

function SelectAPIPath(id) {
  var path = 'api_path' + id;
  $(path).select();
}

function SearchURL(url) {
  $('search_url_results').innerHTML = '';
  if (url) {
    var param = '&url=' + url;
    new Ajax.Updater('search_url_results', '/ajaxrequest/thumbnail/search_url', {
      method: 'get',
      parameters: param,
      asynchronous: true
    });
  }
}

function SelectURL(url) {
  $('form_url').value = url;
  $('search_url_results').innerHTML = '';
}

function Paging(rows, page) {
  var param = '&rows=' + rows + '&page=' + page;
  new Ajax.Updater('thumbnails', '/ajaxrequest/thumbnail/recent_thumbnails', {
    method: 'get',
    parameters: param,
    asynchronous: true
  });
}