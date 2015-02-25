json.array!(@professors) do |professor|
  json.extract! professor, :id, :name, :last_names
  json.url professor_url(professor, format: :json)
end
