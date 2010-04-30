# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  layout "default"

  before_filter :convert_params

  def convert_params(p = params)
    p.keys.each do |k|
      if p[k].is_a?(Hash) && p[k].keys
        convert_params(p[k])
      else
        p[k] = p[k].to_i if k.to_s.ends_with?("_id")
      end
    end
  end

  def redis
    @redis ||= Redis.new
  end

end
