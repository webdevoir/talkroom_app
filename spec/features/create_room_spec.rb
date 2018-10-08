require 'rails_helper'

RSpec.feature 'create_room', type: :feature do

	background { log_in_as }

	context "create_room" do
		it "create with tag" do
			click_link "CREATE"
			fill_in "name_", with: "new_room"
			fill_in "room_tags_", with: "#tag"
			click_button "CREATE"
			expect(page).to have_content "new_room"
			find(".back-link").click
			expect(page).to have_content "tag"
		end
		it "empty name tag" do
			click_link "CREATE"
			click_button "CREATE"
			expect(page).to have_content "ROOM"
		end
	end
end