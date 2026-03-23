class JourneeObservationsController < ApplicationController
  before_action :set_journee_observation, only: [:show, :edit, :update, :destroy]

  def index
    @journees = JourneeObservation.par_date
    @journee_en_cours = JourneeObservation.find_by(date_observation: Date.current)
  end

  def show
    @entree = @journee_observation.entrees.build
  end

  def new
    @journee_observation = JourneeObservation.new(date_observation: Date.current)
  end

  def create
    @journee_observation = JourneeObservation.new(journee_observation_params)
    if @journee_observation.save
      redirect_to @journee_observation, notice: "Journee d'observation creee avec succes."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @journee_observation.update(journee_observation_params)
      redirect_to @journee_observation, notice: "Journee d'observation mise a jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @journee_observation.destroy
    redirect_to journee_observations_url, notice: "Journee d'observation supprimee."
  end

  private

  def set_journee_observation
    @journee_observation = JourneeObservation.find(params[:id])
  end

  def journee_observation_params
    params.require(:journee_observation).permit(:date_observation, :heure_lever, :heure_coucher)
  end
end
