require "test_helper"

class JourneeObservationTest < ActiveSupport::TestCase
  test "date_observation is required" do
    journee = JourneeObservation.new(date_observation: nil)
    assert_not journee.valid?
    assert_includes journee.errors[:date_observation], "can't be blank"
  end

  test "date_observation must be unique" do
    existing = journee_observations(:today)
    journee = JourneeObservation.new(date_observation: existing.date_observation)
    assert_not journee.valid?
    assert_includes journee.errors[:date_observation], "has already been taken"
  end

  test "valid journee with all attributes" do
    journee = JourneeObservation.new(
      date_observation: Date.current + 10.days,
      heure_lever: "07:00",
      heure_coucher: "22:00"
    )
    assert journee.valid?
  end

  test "has_many entrees association" do
    journee = journee_observations(:today)
    assert_respond_to journee, :entrees
    assert_kind_of ActiveRecord::Associations::CollectionProxy, journee.entrees
  end

  test "dependent destroy removes entrees" do
    journee = journee_observations(:today)
    entree_count = journee.entrees.count
    assert entree_count > 0, "Fixture should have entrees"

    assert_difference("Entree.count", -entree_count) do
      journee.destroy
    end
  end

  test "total_boissons sums volume_boisson of all entrees" do
    journee = journee_observations(:today)
    expected = journee.entrees.sum(:volume_boisson)
    assert_equal expected, journee.total_boissons
    assert_equal 450, journee.total_boissons # 250 + 0 + 200
  end

  test "total_urine sums volume_urine of all entrees" do
    journee = journee_observations(:today)
    expected = journee.entrees.sum(:volume_urine)
    assert_equal expected, journee.total_urine
    assert_equal 450, journee.total_urine # 0 + 300 + 150
  end

  test "total_boissons returns 0 when no entrees" do
    journee = journee_observations(:two_days_ago)
    assert_equal 0, journee.total_boissons
  end

  test "total_urine returns 0 when no entrees" do
    journee = journee_observations(:two_days_ago)
    assert_equal 0, journee.total_urine
  end

  test "en_cours? returns true when date is today and no heure_coucher" do
    journee = journee_observations(:today)
    assert journee.en_cours?
  end

  test "en_cours? returns false when date is today but heure_coucher is set" do
    journee = journee_observations(:today)
    journee.heure_coucher = "22:00"
    assert_not journee.en_cours?
  end

  test "en_cours? returns false when date is not today" do
    journee = journee_observations(:yesterday)
    assert_not journee.en_cours?
  end

  test "par_date scope orders by date_observation desc" do
    journees = JourneeObservation.par_date
    dates = journees.pluck(:date_observation)
    assert_equal dates, dates.sort.reverse
  end
end
