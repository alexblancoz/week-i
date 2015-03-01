# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = [
  {
      name: 'Pablo',
      last_names: 'Cárdenas',
      major: User::Major::ITC,
      enrollment: 'A01019808',
      campus: User::Campus::CSF,
      password: '123456',
      password_confirmation: '123456'
  },
  {
      name: 'Vicente',
      last_names: 'Cubells',
      major: User::Major::ITC,
      enrollment: 'L01019808',
      campus: User::Campus::CSF,
      password: '123456',
      password_confirmation: '123456'
  }
]

def create_user(params)
  u = User.new(params)
  unless u.save
    p u.errors.messages
  end
end

users.each do |user|
  create_user(user)
end