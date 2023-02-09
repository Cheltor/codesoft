require "application_system_test_case"

class CodesTest < ApplicationSystemTestCase
  setup do
    @code = codes(:one)
  end

  test "visiting the index" do
    visit codes_url
    assert_selector "h1", text: "Codes"
  end

  test "should create code" do
    visit codes_url
    click_on "New code"

    fill_in "Chapter", with: @code.chapter
    fill_in "Description", with: @code.description
    fill_in "Name", with: @code.name
    fill_in "Section", with: @code.section
    click_on "Create Code"

    assert_text "Code was successfully created"
    click_on "Back"
  end

  test "should update Code" do
    visit code_url(@code)
    click_on "Edit this code", match: :first

    fill_in "Chapter", with: @code.chapter
    fill_in "Description", with: @code.description
    fill_in "Name", with: @code.name
    fill_in "Section", with: @code.section
    click_on "Update Code"

    assert_text "Code was successfully updated"
    click_on "Back"
  end

  test "should destroy Code" do
    visit code_url(@code)
    click_on "Destroy this code", match: :first

    assert_text "Code was successfully destroyed"
  end
end
