<div id="pager">[% PROCESS include/pager.inc %]</div>

[% service_url = c.config.service_url %]
[% WHILE (thumbnail = iter_thumbnail.next) %]
[%
  id  = thumbnail.id
  url = thumbnail.url.as_string
%]
<div class="thumbnail-content">
<div class="thumbnail-title"><span id="title-url[% id %]" class="url"><a href="[% url %]" target="_blank">[% url %]</a></span></div>
<div class="thumbnail-body">
<table>
<tr>
<td colspan="2" rowspan="8"><a href="[% url %]" target="_blank"><img class="thumbnails" src="[% service_url %]medium/[% url %]" /></a></td>
</tr>
<tr>
<td colspan="2">[% thumbnail.created_on.ymd %] [% thumbnail.created_on.hms %]</td>
</tr>
<tr>
<td>Large</td><td><a href="[% service_url %]large/[% url %]" target="_blank">[% service_url %]large/[% url %]</a></td>
</tr>
<tr>
<td>Medium</td><td><a href="[% service_url %]medium/[% url %]" target="_blank">[% service_url %]medium/[% url %]</a></td>
</tr>
<tr>
<td>Small</td><td><a href="[% service_url %]small/[% url %]" target="_blank">[% service_url %]small/[% url %]</a></td>
</tr>
[% IF c.user_exists %]
<tr>
<td><span id="thumb-update[% id %]" class="thumb-update" onclick="if(confirm('UPDATE?')){return true;}">UPDATE</span></td>
<td><span id="thumb-delete[% id %]" class="thumb-delete" onclick="if(confirm('DELETE?')){DeleteThumbnail([% id %])}">DELETE</span></td>
</tr>
[% END %]
<tr>
<td colspan="2"><textarea id="api_path[% id %]" cols="70" rows="4" nowrap="nowrap" readonly="readonly"><a href="[% url %]"><img src="[% service_url %]medium/[% url %]" width="200" height="150" border="0" alt="[% url %]" /></a></textarea></td>
</tr>
<tr><td colspan="2"><input type="button" value="HIGHTLIGHT TEXT" onclick="SelectAPIPath([% id %]);" /></td></tr>
</table>
</div>
</div>
[% END %]

<div id="pager">[% PROCESS include/pager.inc %]</div>
