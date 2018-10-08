require 'rails_helper'

RSpec.feature 'room_message', type: :feature do

	background {
		log_in_as
	}

	context "room_message" do
		it "view mine", driver: :selenium_chrome_headless, js: true do
			using_session :user_A do
			end
			# fill_in "search", with: "search"
			# click_button "SEARCH"
			# expect(page).to have_content room.name
			# expect(page).to_not have_content other_room.name
		end
		it "view other's", driver: :selenium_chrome_headless, js: true do
			using_session :user_A do
			end
			using_session :user_B do
			end
			# fill_in "search", with: "room"
			# click_button "SEARCH"
			# expect(page).to have_content room.name
			# expect(page).to have_content other_room.name
		end
	end

end