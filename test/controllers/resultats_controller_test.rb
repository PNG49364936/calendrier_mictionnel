require "test_helper"

class ResultatsControllerTest < ActionDispatch::IntegrationTest
  test "GET index without dates returns success" do
    get resultats_url
    assert_response :success
  end

  test "GET index with selected dates returns success" do
    journee = journee_observations(:yesterday)
    get resultats_url, params: { dates: [journee.date_observation.to_s] }
    assert_response :success
  end

  test "GET index with multiple dates returns success" do
    dates = [
      journee_observations(:yesterday).date_observation.to_s,
      journee_observations(:two_days_ago).date_observation.to_s
    ]
    get resultats_url, params: { dates: dates }
    assert_response :success
  end

  test "GET pdf with dates returns PDF" do
    journee = journee_observations(:yesterday)
    get resultats_pdf_url, params: { dates: [journee.date_observation.to_s] }
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  test "GET pdf with multiple dates returns PDF" do
    dates = [
      journee_observations(:yesterday).date_observation.to_s,
      journee_observations(:two_days_ago).date_observation.to_s
    ]
    get resultats_pdf_url, params: { dates: dates }
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  test "GET pdf without dates redirects to resultats" do
    get resultats_pdf_url
    assert_redirected_to resultats_path
  end

  test "GET pdf with empty string dates redirects to resultats" do
    get resultats_pdf_url, params: { dates: [""] }
    assert_redirected_to resultats_path
  end
end
