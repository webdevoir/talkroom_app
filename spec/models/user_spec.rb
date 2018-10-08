require 'rails_helper'

RSpec.describe User, type: :model do

  pending "add some examples to (or delete) #{__FILE__}"
  let(:user) { FactoryBot.create(:user) }

  context "validates" do
    context "error" do
      it "length" do
        user.name = "a" * 20
        expect(user).to_not be_valid
      end
    end
    context "success" do
      it "present and length" do
        expect(user).to be_valid
      end
    end
  end

end
