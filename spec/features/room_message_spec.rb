require 'rails_helper'

RSpec.feature 'room_message', type: :feature do

	let!(:room) { FactoryBot.create(:room) }

	context "room_message" do
		it "view mine", driver: :selenium_chrome_headless, js: true do
			log_in_as
			visit room_path(room.id)
			fill_in "message_textarea", with: "message rspec"
			find("#send-button").click
			expect(page).to have_content "message rspec"
			expect(page).to have_content "ゲスト"
		end
		it "view other's", driver: :selenium_chrome_headless, js: true do
			using_session :user_A do
				log_in_as
				visit room_path(room.id)
			end
			using_session :user_B do
				log_in_as
				visit room_path(room.id)
			end
			using_session :user_A do
				fill_in "message_textarea", with: "message rspec"
				find("#send-button").click
			end
			using_session :user_B do
				expect(page).to have_content "message rspec"
			end
		end
	end

end