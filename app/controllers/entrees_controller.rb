class EntreesController < ApplicationController
  before_action :set_journee_observation
  before_action :set_entree, only: [:edit, :update, :destroy]

  def new
    @entree = @journee_observation.entrees.build
  end

  def create
    @entree = @journee_observation.entrees.build(entree_params)
    if @entree.save
      redirect_to @journee_observation, notice: "Entree ajoutee avec succes."
    else
      redirect_to @journee_observation, alert: "Erreur lors de l'ajout de l'entree: #{@entree.errors.full_messages.join(', ')}"
    end
  end

  def edit
  end

  def update
    if @entree.update(entree_params)
      redirect_to @journee_observation, notice: "Entree mise a jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entree.destroy
    redirect_to @journee_observation, notice: "Entree supprimee."
  end

  private

  def set_journee_observation
    @journee_observation = JourneeObservation.find(params[:journee_observation_id])
  end

  def set_entree
    @entree = @journee_observation.entrees.find(params[:id])
  end

  def entree_params
    params.require(:entree).permit(:heure, :volume_boisson, :volume_urine, :urgenturies, :fuites, :commentaires)
  end
end
