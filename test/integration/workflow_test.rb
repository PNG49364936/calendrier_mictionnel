require "test_helper"

class WorkflowTest < ActionDispatch::IntegrationTest
  test "complete workflow: create journee, add entrees, check resultats, generate PDF" do
    # Step 1: Create a new journee d'observation
    future_date = Date.current + 50.days
    assert_difference("JourneeObservation.count") do
      post journee_observations_url, params: {
        journee_observation: {
          date_observation: future_date,
          heure_lever: "06:30"
        }
      }
    end
    journee = JourneeObservation.find_by(date_observation: future_date)
    assert_not_nil journee
    assert_redirected_to journee_observation_url(journee)
    follow_redirect!
    assert_response :success

    # Step 2: Add multiple entrees
    assert_difference("Entree.count", 3) do
      post journee_observation_entrees_url(journee), params: {
        entree: { heure: "07:00", volume_boisson: 300, volume_urine: 0, urgenturies: "", fuites: "", commentaires: "petit dej" }
      }
      post journee_observation_entrees_url(journee), params: {
        entree: { heure: "10:00", volume_boisson: 0, volume_urine: 250, urgenturies: "X", fuites: "", commentaires: "" }
      }
      post journee_observation_entrees_url(journee), params: {
        entree: { heure: "12:30", volume_boisson: 200, volume_urine: 180, urgenturies: "", fuites: "X", commentaires: "repas" }
      }
    end

    # Step 3: Verify totals
    journee.reload
    assert_equal 500, journee.total_boissons  # 300 + 0 + 200
    assert_equal 430, journee.total_urine     # 0 + 250 + 180

    # Step 4: Consult resultats
    get resultats_url, params: { dates: [future_date.to_s] }
    assert_response :success

    # Step 5: Generate PDF
    get resultats_pdf_url, params: { dates: [future_date.to_s] }
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  test "workflow with multiple days and global totals" do
    # Use existing fixtures: yesterday and two_days_ago
    yesterday = journee_observations(:yesterday)
    two_days_ago = journee_observations(:two_days_ago)

    dates = [yesterday.date_observation.to_s, two_days_ago.date_observation.to_s]

    # Consult resultats with multiple dates
    get resultats_url, params: { dates: dates }
    assert_response :success

    # Generate PDF with multiple dates (triggers global totals section)
    get resultats_pdf_url, params: { dates: dates }
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  test "set heure_coucher to close the day" do
    journee = journee_observations(:today)
    assert journee.en_cours?

    patch journee_observation_url(journee), params: {
      journee_observation: { heure_coucher: "22:30" }
    }
    assert_redirected_to journee_observation_url(journee)

    journee.reload
    assert_not journee.en_cours?
  end
end
