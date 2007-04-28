      [% pager = itr_thumbnail.pager%]
      [% FOREACH page = [pager.first_page .. pager.last_page] %]
      [% IF pager.current_page == page %][% class = 'active-page-num' %][% ELSE %][% class = 'page-num' %][% END %]
      <span class="[% class %]" onclick="Paging([% pager.entries_per_page %],[% page %])" >[% page %]</span>
      [% END %]
