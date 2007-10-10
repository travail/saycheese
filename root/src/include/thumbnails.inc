    <div id="pager">[% PROCESS include/pager.inc %]</div>
      [% WHILE (thumbnail = itr_thumbnail.next) %]
      <div class="thumbnail-content">
        <div class="thumbnail-title">
          <span id="title-url[% thumbnail.id %]" class="url"><a href="[% thumbnail.url %]" target="_blank">[% thumbnail.url %]</a></span>
        </div>
        <div class="thumbnail-body">
<table>
<tr><td rowspan="6"><a href="[% thumbnail.url %]" target="_blank"><img class="thumbnails" src="/[% thumbnail.img_path %]" /></a></td></tr>
<tr><td>[% thumbnail.created_on.ymd %] [% thumbnail.created_on.hms %]</td></tr>
<tr><td>Large:<a href="[% c.config.service_url %]large/[% thumbnail.url %]" target="_blank">[% c.config.service_url %]large/[% thumbnail.url %]</a></td></tr>
<tr><td>Medium:<a href="[% c.config.service_url %]medium/[% thumbnail.url %]" target="_blank">[% c.config.service_url %]medium/[% thumbnail.url %]</a></td></tr>
<tr><td>Small:<a href="[% c.config.service_url %]small/[% thumbnail.url %]" target="_blank">[% c.config.service_url %]small/[% thumbnail.url %]</a></td></tr>
<tr><td><span id="thumb-delete[% thumbnail.id %]" class="thumb-delete" onclick="if(confirm('DELETE?')){DeleteThumbnail([% thumbnail.id %])}">DELETE</span></td></tr>
<tr><td><textarea id="api_path[% thumbnail.id %]" cols="70" rows="4" nowrap="nowrap" readonly="readonly"><a href="[% thumbnail.url %]"><img src="[% c.config.service_url %]medium/[% thumbnail.url %]" width="[% thumbnail.width %]" height="[% thumbnail.height %]" border="0" alt="" /></a></textarea></td></tr>
<tr><td><input type="button" value="HIGHTLIGHT TEXT" onclick="SelectAPIPath([% thumbnail.id %]);" /></td></tr>
</table>
        </div>
      </div>
      [% END %]
