require 'rails_helper'

RSpec.feature 'random_chat', type: :feature do

	context "random_chat" do
		it "matching", driver: :selenium_chrome_headless, js: true do
			using_session :user_A do
				log_in_as
				click_link "RANDOM TALK"
				expect(page).to have_content "入室しました"
				fill_in "chat_textarea", with: "message rspec"
				find("#send-button").click
				expect(page).to have_content "message rspec"
			end
			using_session :user_B do
				log_in_as
				click_link "RANDOM TALK"
				expect(page).to have_content "入室しました"
				expect(page).to have_content "message rspec"
			end
		end
		it "create", driver: :selenium_chrome_headless, js: true do
			using_session :user_A do
				log_in_as
				click_link "RANDOM TALK"
				fill_in "chat_textarea", with: "message rspec"
				find("#send-button").click
			end
			using_session :user_B do
				log_in_as
				click_link "RANDOM TALK"
			end
			using_session :user_C do
				log_in_as
				click_link "RANDOM TALK"
				expect(page).to have_content "入室しました"
				expect(page).to_not have_content "message rspec"
			end
		end
		it "leave and re matching", driver: :selenium_chrome_headless, js: true do
			using_session :user_A do
				log_in_as
				click_link "RANDOM TALK"
			end
			using_session :user_B do
				log_in_as
				click_link "RANDOM TALK"
			end
			using_session :user_A do
				visit rooms_path
			end
			using_session :user_B do
				expect(page).to have_content "退出しました"
				fill_in "chat_textarea", with: "message rspec"
				find("#send-button").click
			end
			using_session :user_C do
				log_in_as
				click_link "RANDOM TALK"
				expect(page).to have_content "message rspec"
			end
		end
	end

end