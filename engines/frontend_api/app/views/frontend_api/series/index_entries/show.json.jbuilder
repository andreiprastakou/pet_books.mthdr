# frozen_string_literal: true

json.id @series.id
json.name @series.name
json.external_links ExternalLink.frontend_payload(@series.external_links)
