    <div id="pager">[% PROCESS include/pager.inc %]</div>
      [% WHILE (thumbnail = itr_thumbnail.next) %]
      <div class="thumbnail-content">
        <div class="thumbnail-title">
          <span id="title-url[% thumbnail.id %]" class="url"><a href="[% thumbnail.url %]" target="_blank">[% thumbnail.url %]</a></span>
        </div>
        <div class="thumbnail-body">
<table>
<tr><td rowspan="6"><a href="[% thumbnail.url %]" target="_blank">[% thumbnail.img %]</a></td></tr>
<tr><td>[% thumbnail.created_on.ymd %] [% thumbnail.created_on.hms %]</td></tr>
<tr><td>API:<a href="[% base %]api/[% thumbnail.url %]" target="_blank">[% base %]api/[% thumbnail.url %]</a></td></tr>
<tr><td><span id="thumb-delete[% thumbnail.id %]" class="thumb-delete" onclick="if(confirm('DELETE?')){DeleteThumbnail([% thumbnail.id %])}">DELETE</span></td></tr>
<tr><td><textarea id="api_path[% thumbnail.id %]" cols="70" rows="4" nowrap="nowrap" readonly="readonly"><a href="[% thumbnail.url %]"><img src="[% base %]api/[% thumbnail.url %]" width="[% thumbnail.width %]" height="[% thumbnail.height %]" border="0" alt="" /></a></textarea></td></tr>
<tr><td><input type="button" value="HIGHTLIGHT TEXT" onclick="SelectAPIPath([% thumbnail.id %]);" /></td></tr>
</table>
        </div>
      </div>
      [% END %]