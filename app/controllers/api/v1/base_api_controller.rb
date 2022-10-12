class Api::V1::BaseApiController < ApplicationController
  def current_user
    @current_user ||= User.first
    # ||の左側がtrueだったら右側は実行しない(if => false)
    # ||の左側がfalse/nilだったら右側を実行する（if => true）
  end
end
