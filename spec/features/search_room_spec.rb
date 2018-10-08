require 'rails_helper'

RSpec.feature 'search_room', type: :feature do

	let!(:room) { FactoryBot.create(:room) }
	let!(:other_room) { FactoryBot.create(:room) }
	let!(:room_tag) { FactoryBot.build(:room_tag) }
	background {
		log_in_as
		room.name = "search_room1"
		other_room.name = "aaa_room2"
		room_tag.room_id = room.id
		room_tag.name = "rspec test"
		room.save
		other_room.save
		room_tag.save
	}

	context "search_room" do
		it "only word" do
			fill_in "search", with: "search"
			click_button "SEARCH"
			expect(page).to have_content room.name
			expect(page).to_not have_content other_room.name
		end
		it "common word" do
			fill_in "search", with: "room"
			click_button "SEARCH"
			expect(page).to have_content room.name
			expect(page).to have_content other_room.name
		end
		it "empty" do
			fill_in "search", with: ""
			click_button "SEARCH"
			expect(page).to have_content room.name
			expect(page).to have_content other_room.name
		end
	end
	context "search tag" do
		it "only tag" do
			fill_in "search", with: "rspec"
			click_button "SEARCH"
			expect(page).to have_content room.name
			expect(page).to_not have_content other_room.name
		end
	end

end