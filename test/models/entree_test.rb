require "test_helper"

class EntreeTest < ActiveSupport::TestCase
  test "heure is required" do
    entree = Entree.new(
      journee_observation: journee_observations(:today),
      heure: nil
    )
    assert_not entree.valid?
    assert_includes entree.errors[:heure], "can't be blank"
  end

  test "valid entree with all attributes" do
    entree = Entree.new(
      journee_observation: journee_observations(:today),
      heure: "10:00",
      volume_boisson: 200,
      volume_urine: 150,
      urgenturies: "X",
      fuites: "",
      commentaires: "test"
    )
    assert entree.valid?
  end

  test "commentaires maximum length is 10 characters" do
    entree = Entree.new(
      journee_observation: journee_observations(:today),
      heure: "10:00",
      commentaires: "a" * 11
    )
    assert_not entree.valid?
    assert_includes entree.errors[:commentaires], "is too long (maximum is 10 characters)"
  end

  test "commentaires with exactly 10 characters is valid" do
    entree = Entree.new(
      journee_observation: journee_observations(:today),
      heure: "10:00",
      commentaires: "a" * 10
    )
    assert entree.valid?
  end

  test "urgenturies allows valid values" do
    journee = journee_observations(:today)
    ["", "X", "XX", "XXX"].each do |value|
      entree = Entree.new(journee_observation: journee, heure: "10:00", urgenturies: value)
      assert entree.valid?, "urgenturies should accept '#{value}'"
    end
  end

  test "urgenturies rejects invalid values" do
    entree = Entree.new(
      journee_observation: journee_observations(:today),
      heure: "10:00",
      urgenturies: "INVALID"
    )
    assert_not entree.valid?
    assert_includes entree.errors[:urgenturies], "is not included in the list"
  end

  test "urgenturies allows nil" do
    entree = Entree.new(
      journee_observation: journee_observations(:today),
      heure: "10:00",
      urgenturies: nil
    )
    assert entree.valid?
  end

  test "fuites allows valid values" do
    journee = journee_observations(:today)
    ["", "X", "XX", "XXX"].each do |value|
      entree = Entree.new(journee_observation: journee, heure: "10:00", fuites: value)
      assert entree.valid?, "fuites should accept '#{value}'"
    end
  end

  test "fuites rejects invalid values" do
    entree = Entree.new(
      journee_observation: journee_observations(:today),
      heure: "10:00",
      fuites: "INVALID"
    )
    assert_not entree.valid?
    assert_includes entree.errors[:fuites], "is not included in the list"
  end

  test "fuites allows nil" do
    entree = Entree.new(
      journee_observation: journee_observations(:today),
      heure: "10:00",
      fuites: nil
    )
    assert entree.valid?
  end

  test "belongs_to journee_observation" do
    entree = entrees(:morning_drink)
    assert_respond_to entree, :journee_observation
    assert_kind_of JourneeObservation, entree.journee_observation
  end

  test "URGENTURIES_OPTIONS constant is defined" do
    assert_equal ["", "X", "XX", "XXX"], Entree::URGENTURIES_OPTIONS
  end

  test "FUITES_OPTIONS constant is defined" do
    assert_equal ["", "X", "XX", "XXX"], Entree::FUITES_OPTIONS
  end
end
