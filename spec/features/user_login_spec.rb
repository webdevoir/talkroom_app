require 'rails_helper'

RSpec.feature 'user_login', type: :feature do
	context "user login" do
		it "access home to room_index with login" do
			visit root_path
			find("#access_rooms").click
			expect(current_path).to eq rooms_path
		end
	end
end