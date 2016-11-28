# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#link_to profile picture for email_id' do
    it 'returns the url for profile picture with default size 20' do
      email_id = 'test@example.com'
      size = 20
      profile_picture_url = dp(email_id)
      expect(profile_picture_url).to eq("https://gravatar.com/avatar/#{Digest::MD5.hexdigest(email_id)}.png?s=#{size}")
    end

    it 'returns the url for profile picture with size 30' do
      email_id = 'test@example.com'
      size = 30
      profile_picture_url = dp(email_id, size)
      expect(profile_picture_url).to eq("https://gravatar.com/avatar/#{Digest::MD5.hexdigest(email_id)}.png?s=#{size}")
    end
  end

  describe 'generate profile picture image', type: :helper do
    it 'returns the url for profile picture' do
      t = accounts(:europeana_account)
      email_id = t.email
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
      impl = impl_aggregations(:rijksmuseum_aggregation)
      indicator = get_impl_status(impl)
      expect(indicator).to eq("<div class='signal sig-red'></div>")
    end

    it 'should return a html string with class signal sig-gray' do
      impl = impl_aggregations(:diputaciodebarcelona_aggregation)
      indicator = get_impl_status(impl)
      expect(indicator).to eq("<div class='signal sig-gray'></div>")
    end

    it 'should return a html string with class signal sig-green' do
      impl = impl_aggregations(:europeana_aggregation)
      indicator = get_impl_status(impl)
      expect(indicator).to eq("<div class='signal sig-green'></div>")
    end
  end

  describe 'generate an custom html tag for timeago', type: :helper do
    it 'should return <time></time> for the given date' do
      time = Time.new(2015, 10, 31, 5, 30, 0, '+05:30')
      html = timeago(time)
      expect(html).to eq('<time class="timeago" datetime="2015-10-31T00:00:00Z">2015-10-31 05:30:00 +0530</time>')
    end
  end
end
