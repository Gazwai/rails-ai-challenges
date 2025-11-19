class ChallengesController < ApplicationController
  def index
    @challenges = Challenge.all
    # render 'index.html.erb'
    # respond_to do |format|
    #   format.html { render 'index' }
    #   format.json { render json: @challenges }
    #   format.txt { render plain: @challenges }
    # end
  end

  def show
    @challenge = Challenge.find(params[:id])
  end
end
