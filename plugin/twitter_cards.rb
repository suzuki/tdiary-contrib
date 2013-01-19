# -*- coding: utf-8 -*-
# twitter_cards.rb - add Twitter Cards <meta> tags to header
#
# Copyright (c) 2013 Norio Suzuki <norio.suzuki@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#

# Twitter Cards Documents
#	 https://dev.twitter.com/docs/cards

# 
# @conf['twitter_cards.site']	 - Your Twitter ID (ex. @suzuki)
# 

def twitter_cards_description

	@twitter_cards = []

	section_index = @cgi.params['p'][0]
	# section_index = "1"
	if @mode == 'day' and section_index
		diary = @diaries[@date.strftime('%Y%m%d')]
		sections = diary.instance_variable_get(:@sections)
		section = sections[section_index.to_i - 1].body_to_html
		@conf.shorten(apply_plugin(section, true), 200)
	else
		@conf.description
	end
end

add_header_proc do

	uri = @conf.index.dup
	uri[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
	uri.gsub!( %r|/\./|, '/' )
	if @mode == 'day' then
		uri += anchor( @date.strftime( '%Y%m%d' ) )
	end

	headers = {
		# TODO: support type of 'photo' and 'player'
		'twitter:card' => 'summary',
		'twitter:url' => uri,
		'twitter:title' => title_tag.match(/>([^<]+)</).to_a[1],
		'twitter:description' => twitter_cards_description,
		'twitter:image' => @conf.banner,
		'twitter:site' => @conf['twitter_cards.site']
	}
	headers.select {|key, val|
		val && !val.empty?
	}.map {|key, val|
		%Q|<meta property="#{key}" content="#{CGI::escapeHTML(val)}">|
	}.join("\n")
end

add_conf_proc('Twitter Cards', 'Twitter Cards') do
	if @mode == 'saveconf'
		@conf['twitter_cards.site'] = @cgi.params['twitter_cards.site'][0]
	end

	<<-HTML
	<h3>Twitter Cards : site (@username)</h3>
	<p><input name="twitter_cards.site" value="#{h(@conf['twitter_cards.site'])}"></p>
	HTML
end
