require "test_helper"

class EntreesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @journee = journee_observations(:today)
    @entree = entrees(:morning_drink)
  end

  test "GET new returns success" do
    get new_journee_observation_entree_url(@journee)
    assert_response :success
  end

  test "POST create with valid data redirects to journee" do
    assert_difference("Entree.count") do
      post journee_observation_entrees_url(@journee), params: {
        entree: {
          heure: "11:00",
          volume_boisson: 150,
          volume_urine: 0,
          urgenturies: "",
          fuites: "",
          commentaires: "eau"
        }
      }
    end
    assert_redirected_to journee_observation_url(@journee)
  end

  test "POST create with invalid data redirects with alert" do
    assert_no_difference("Entree.count") do
      post journee_observation_entrees_url(@journee), params: {
        entree: {
          heure: nil,
          volume_boisson: 100
        }
      }
    end
    assert_redirected_to journee_observation_url(@journee)
    assert_equal "Erreur lors de l'ajout de l'entree: Heure can't be blank", flash[:alert]
  end

  test "GET edit returns success" do
    get edit_journee_observation_entree_url(@journee, @entree)
    assert_response :success
  end

  test "PATCH update with valid data redirects to journee" do
    patch journee_observation_entree_url(@journee, @entree), params: {
      entree: {
        volume_boisson: 500
      }
    }
    assert_redirected_to journee_observation_url(@journee)
    @entree.reload
    assert_equal 500, @entree.volume_boisson
  end

  test "PATCH update with invalid data renders edit" do
    patch journee_observation_entree_url(@journee, @entree), params: {
      entree: {
        heure: nil
      }
    }
    assert_response :unprocessable_entity
  end

  test "DELETE destroy removes entree and redirects" do
    assert_difference("Entree.count", -1) do
      delete journee_observation_entree_url(@journee, @entree)
    end
    assert_redirected_to journee_observation_url(@journee)
  end
end
