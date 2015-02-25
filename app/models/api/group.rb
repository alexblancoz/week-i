class Api::Group < Group

  module Json
    LIST = { only: [:id, :name, :member_count, :user_name, :user_last_names] }
    SHOW = { only: [:id, :name, :member_count, :user_name, :user_last_names, :status, :owner_id], methods: [:members] }
  end

end