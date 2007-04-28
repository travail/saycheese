      [% pager = itr_thumbnail.pager%]
      [% FOREACH page = [pager.first_page .. pager.last_page] %]
      <span class="page_num" onclick="Paging(5,[% page %])">[% page %]</span>
      [% END %]
