json.array!(@users) do |user|
  json.extract! user, :id, :name, :last_names, :enrollment, :major, :semester, :hashed_password, :identity
  json.url user_url(user, format: :json)
end
