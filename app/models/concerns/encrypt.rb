module Encrypt

  extend ActiveSupport::Concern

  def self.sha1(*args)
    require 'digest/sha1'
    args.push '123456' #ENV['TASKER_SALT']
    Digest::SHA1.hexdigest(args.join)
  end

end
