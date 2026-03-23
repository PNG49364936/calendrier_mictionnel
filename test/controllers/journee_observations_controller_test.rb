require "test_helper"

class JourneeObservationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @journee = journee_observations(:yesterday)
  end

  test "GET index returns success" do
    get journee_observations_url
    assert_response :success
  end

  test "GET new returns success" do
    get new_journee_observation_url
    assert_response :success
  end

  test "POST create with valid data redirects" do
    assert_difference("JourneeObservation.count") do
      post journee_observations_url, params: {
        journee_observation: {
          date_observation: Date.current + 30.days,
          heure_lever: "07:00",
          heure_coucher: nil
        }
      }
    end
    assert_redirected_to journee_observation_url(JourneeObservation.last)
  end

  test "POST create with invalid data renders new" do
    assert_no_difference("JourneeObservation.count") do
      post journee_observations_url, params: {
        journee_observation: {
          date_observation: nil
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "POST create with duplicate date renders new" do
    assert_no_difference("JourneeObservation.count") do
      post journee_observations_url, params: {
        journee_observation: {
          date_observation: @journee.date_observation
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "GET show returns success" do
    get journee_observation_url(@journee)
    assert_response :success
  end

  test "GET edit returns success" do
    get edit_journee_observation_url(@journee)
    assert_response :success
  end

  test "PATCH update with valid data redirects" do
    patch journee_observation_url(@journee), params: {
      journee_observation: {
        heure_coucher: "23:00"
      }
    }
    assert_redirected_to journee_observation_url(@journee)
    @journee.reload
    assert_equal "23:00", @journee.heure_coucher.strftime("%H:%M")
  end

  test "PATCH update with invalid data renders edit" do
    patch journee_observation_url(@journee), params: {
      journee_observation: {
        date_observation: nil
      }
    }
    assert_response :unprocessable_entity
  end

  test "DELETE destroy removes journee and redirects" do
    assert_difference("JourneeObservation.count", -1) do
      delete journee_observation_url(@journee)
    end
    assert_redirected_to journee_observations_url
  end
end
