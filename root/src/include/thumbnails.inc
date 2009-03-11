<div id="pager">[% PROCESS include/pager.inc %]</div>

[% WHILE (thumbnail = iter_thumbnail.next) %]
<div class="thumbnail-content">
<div class="thumbnail-title"><span id="title-url[% thumbnail.id %]" class="url"><a href="[% thumbnail.url.as_string %]" target="_blank">[% thumbnail.url.as_string %]</a></span></div>
<div class="thumbnail-body">
<table>
<tr>
<td colspan="2" rowspan="8"><a href="[% thumbnail.url.as_string %]" target="_blank"><img class="thumbnails" src="[% c.config.service_url %]medium/[% thumbnail.url.as_string %]" /></a></td>
</tr>
<tr>
<td colspan="2">[% thumbnail.created_on.ymd %] [% thumbnail.created_on.hms %]</td>
</tr>
<tr>
<td>Large</td><td><a href="[% c.config.service_url %]large/[% thumbnail.url.as_string %]" target="_blank">[% c.config.service_url %]large/[% thumbnail.url.as_string %]</a></td>
</tr>
<tr>
<td>Medium</td><td><a href="[% c.config.service_url %]medium/[% thumbnail.url.as_string %]" target="_blank">[% c.config.service_url %]medium/[% thumbnail.url.as_string %]</a></td>
</tr>
<tr>
<td>Small</td><td><a href="[% c.config.service_url %]small/[% thumbnail.url.as_string %]" target="_blank">[% c.config.service_url %]small/[% thumbnail.url.as_string %]</a></td>
</tr>
<tr>
<td><span id="thumb-update[% thumbnail.id %]" class="thumb-update" onclick="if(confirm('UPDATE?')){UpdateThumbnail([% thumbnail.id %])}">UPDATE</span></td>
<td><span id="thumb-delete[% thumbnail.id %]" class="thumb-delete" onclick="if(confirm('DELETE?')){DeleteThumbnail([% thumbnail.id %])}">DELETE</span></td>
</tr>
<tr>
<td colspan="2"><textarea id="api_path[% thumbnail.id %]" cols="70" rows="4" nowrap="nowrap" readonly="readonly"><a href="[% thumbnail.url.as_string %]"><img src="[% c.config.service_url %]medium/[% thumbnail.url.as_string %]" width="200" height="150" border="0" alt="[% thumbnail.url.as_string %]" /></a></textarea></td>
</tr>
<tr><td colspan="2"><input type="button" value="HIGHTLIGHT TEXT" onclick="SelectAPIPath([% thumbnail.id %]);" /></td></tr>
</table>
</div>
</div>
[% END %]

<div id="pager">[% PROCESS include/pager.inc %]</div>
