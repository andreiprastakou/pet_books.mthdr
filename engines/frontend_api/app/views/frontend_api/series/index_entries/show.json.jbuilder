# frozen_string_literal: true

json.id @series.id
json.name @series.name
json.wiki_url @series.wiki_url
json.external_links(@series.external_links.map { |link| { name: link.name, url: link.url } })
