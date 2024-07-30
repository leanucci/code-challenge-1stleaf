class Api::UsersController < ApplicationController
  before_action :set_user, only: %i[ show ]

  def index
    if (params.keys - ['action', 'controller', 'full_name', 'email', 'metadata', 'user']).any?
      render json: { error: 'Invalid query params' }, status: :unprocessable_entity
    end

    search_conditions = {}
    %w[full_name email metadata].each do |field|
      search_conditions[field] = params[field] if params[field].present?
    end

    users_scope = User.order('created_at DESC')

    if search_conditions.any?
      like_str = search_conditions.map { |h| "#{h.first} LIKE '%#{h.last.gsub("'", "''")}%'"}.join(" AND ")
      users_scope = users_scope.where(like_str)
    end

    @users = users_scope.all
  end

  def show
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render :show, status: :created, location: api_user_url(@user)
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:email, :phone_number, :full_name, :password, :password_confirmation, :key, :metadata)
    end
end
