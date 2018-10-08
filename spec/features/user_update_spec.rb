require 'rails_helper'

RSpec.feature 'user_update', type: :feature do

	background { log_in_as }

	context "user_update" do
		it "change name" do
			expect(page).to have_content 'ゲスト'
			click_link "CHANGE"
			fill_in "user_name", with: "new_name"
			click_button "CHANGE"
			expect(page).to_not have_content 'ゲスト'
		end
		it "empty name" do
			expect(page).to have_content 'ゲスト'
			click_link "CHANGE"
			fill_in "user_name", with: ""
			click_button "CHANGE"
			expect(page).to have_content 'ゲスト'
		end
	end
end