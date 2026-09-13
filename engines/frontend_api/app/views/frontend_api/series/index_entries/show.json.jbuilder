# frozen_string_literal: true

json.id @series.id
json.name @series.name
json.external_links(@series.external_links.map { |link| { external_resource: link.external_resource, url: link.url } })
