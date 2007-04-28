[% WHILE (thumbnail = itr_thumbnail.next) %]
<div class="search-result" onclick="SelectURL('[% thumbnail.url %]')">[% thumbnail.url %]</div>
[% END %]
