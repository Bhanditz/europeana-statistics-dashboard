json.array!(@core_cards) do |core_card|
  json.extract! core_card, :id, :name, :is_public, :content, :properties, :core_card_layout_id, :core_project_id, :core_datacast_identifier, :created_by, :updated_by
  json.url core_card_url(core_card, format: :json)
end
