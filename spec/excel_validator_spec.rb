require "spec_helper"

module Helpers
	def upload(file)
		excel_file = File.open(File.join(File.dirname(__FILE__), file))
		return ActionDispatch::Http::UploadedFile.new(:tempfile => excel_file, :filename => File.basename(excel_file))
	end
end

describe ExcelValidator do

	include Helpers
	describe "general validation" do
		class TestUser1 < TestModel
			validates :excel, :excel => true
		end

		it "should be valid" do
			TestUser1.new(:excel => upload('column_valid.xlsx')).should be_valid
		end

		it "should be invalid if no excel file given" do
			testUser = TestUser1.new()
			expect(testUser.valid?).to be_falsey
			expect(testUser.errors[:excel][0]).to eq("must be present")
		end

		it "should be invalid due to maformed CSV" do
			testUser = TestUser1.new(:excel => upload('activrecord.png'))
			expect(testUser.valid?).to be_falsey
			expect(testUser.errors[:excel][0]).to eq("is not a valid CSV file")
		end

	end

	describe "column validation" do
		class TestUser2 < TestModel
			validates :excel, :excel => {:columns => 3,:header_starts_from=>1}
		end

		it "should be invalid due to exact column count" do
			testUser = TestUser2.new(:excel => upload('column_invalid.xlsx'))
			expect(testUser.valid?).to be_falsey
			expect(testUser.errors[:excel][0]).to eq("should have 3 columns")
		end

		class TestUser3 < TestModel
			validates :excel, :excel => {:header_values=>["email_id","date","country"],:header_starts_from=>1}
		end

		it "should be invalid due to header mismatch" do
			testUser = TestUser3.new(:excel => upload('column_invalid.xlsx'))
			expect(testUser.valid?).to be_falsey
			expect(testUser.errors[:excel][0]).to eq("not valid headers")
		end

		class TestUser4 < TestModel
			validates :excel, :excel => {:header_values=>["email_id","date","country"],:header_starts_from=>1,:columns => 3}
		end
		it "should be valid with columns" do
			TestUser4.new(:excel => upload('column_valid.xlsx')).should be_valid
		end
	end
	describe "content validation" do

		class TestUser5 < TestModel
			# column number which contains email
			validates :excel, :excel => {:email => 1}
		end
		it "should have valid email addresses" do
			TestUser5.new(:excel => upload('column_valid.xlsx')).should be_valid
		end
	end
end
