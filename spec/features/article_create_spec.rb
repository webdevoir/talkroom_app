require 'rails_helper'

RSpec.feature 'article_create', type: :feature do

	let!(:room) { FactoryBot.create(:room) }
	background {
		log_in_as
		visit room_path(room.id)
		fill_in "message_textarea", with: "message rspec"
		find("#send-button").click
		fill_in "message_textarea", with: "save msg rspec"
		find("#send-button").click
		visit current_path
	}

	context "article_create" do
		it "create same", driver: :selenium_chrome_headless, js: true do
			click_link "EDIT"
			click_button "CREATE"
			expect(page).to have_content "message rspec"
			expect(page).to have_content "save msg rspec"
		end
		it "change name and delete one message", driver: :selenium_chrome_headless, js: true do
			click_link "EDIT"
			fill_in "article_title", with: "new title"
			all('.delete-check-box')[0].set(true)
			click_button "CREATE"
			expect(page).to have_content "new title"
			expect(page).to_not have_content "message rspec"
			expect(page).to have_content "save msg rspec"
		end
	end
end