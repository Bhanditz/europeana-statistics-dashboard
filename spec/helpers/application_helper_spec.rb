require 'rails_helper'

RSpec.describe ApplicationHelper, :type => :helper do
  describe "#link_to profile picture for email_id" do
    it "returns the url for profile picture with default size 20" do
      email_id = 'test@emmail.com'
      size = 20
      profile_picture_url = dp(email_id)
      expect(profile_picture_url).to eq("https://gravatar.com/avatar/#{Digest::MD5.hexdigest(email_id)}.png?s=#{size}")
    end

    it "returns the url for profile picture with size 30" do
      email_id = 'test@emmail.com'
      size = 30
      profile_picture_url = dp(email_id, size)
      expect(profile_picture_url).to eq("https://gravatar.com/avatar/#{Digest::MD5.hexdigest(email_id)}.png?s=#{size}")
    end
  end

  describe "generate profile picture image", :type => :helper do
    it 'returns the url for profile picture' do
      t = Account.first
      email_id = 'europeana_user@europeana.eu'
      size = 30
      profile_picture_url = account_image(t, size)
      expect(profile_picture_url).to eq("https://gravatar.com/avatar/#{Digest::MD5.hexdigest(email_id)}.png?s=#{size}")
    end
  end


  describe 'generate html string for project name', type: :helper do
    it 'returns html string for given project' do
      p = Core::Project.first
      html_string = helper.show_project_name(p)
      expect(html_string).to eq("<a class='thin gray' style='letter-spacing: -1px; margin-left: 30px;' href='#{_account_project_path(p.account, p)}'>Home</a>")
    end
  end

  describe 'generate html string for project name', type: :helper do
    it 'returns html string for given project' do
      p = Core::Project.first
      html_string = helper.show_project_name(p)
      expect(html_string).to eq("<a class='thin gray' style='letter-spacing: -1px; margin-left: 30px;' href='#{_account_project_path(p.account, p)}'>Home</a>")
    end
  end


  describe 'generate report status html indicator', type: :helper do
    it 'should return a html string with class signal sig-red' do
      impl = Impl::Aggregation.last
      indicator = get_impl_status(impl)
      expect(indicator).to eq("<div class='signal sig-red'></div>")
    end

    it 'should return a html string with class signal sig-gray' do
      impl = Impl::Aggregation.fourth
      indicator = get_impl_status(impl)
      expect(indicator).to eq("<div class='signal sig-gray'></div>")
    end

    it 'should return a html string with class signal sig-green' do
      impl = Impl::Aggregation.first
      indicator = get_impl_status(impl)
      expect(indicator).to eq("<div class='signal sig-green'></div>")
    end
  end

  describe 'generate an custom html tag for timeago', type: :helper do
    it 'should return <time></time> for the given date' do
      time = Time.new(2015, 10, 31)
      html = timeago(time)
      expect(html).to eq('<time class="timeago" datetime="2015-10-30T18:30:00Z">2015-10-31 00:00:00 +0530</time>')
    end
  end

end