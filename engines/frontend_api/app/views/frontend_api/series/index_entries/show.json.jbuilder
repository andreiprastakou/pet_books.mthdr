# frozen_string_literal: true

json.id @series.id
json.name @series.name
json.pinned UserPin.pinned?(current_user, @series)
json.external_links ExternalLink.frontend_payload(@series.external_links)
