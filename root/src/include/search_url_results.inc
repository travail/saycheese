[% WHILE (thumbnail = itr_thumbnail.next) %]
<div onclick="SelectURL('[% thumbnail.url %]')">[% thumbnail.url %]</div>
[% END %]
