require 'rails_helper'

RSpec.describe IconHelper, type: :helper do

  describe 'generate html for a link to deleting a resource', type: :helper do
    it 'should return a html string which is a link to delete root' do
      icon = icon_del(root_path)
      output = "<a data-confirm=\"Are you sure you want to delete?\" rel=\"nofollow\" data-method=\"delete\" href=\"/\"><b class='glyphicon glyphicon-trash'></b></a>"
      expect(icon).to eq(output)
    end

    it 'should return a html string which is a link to delete root' do
      icon = icon_del(providers_path)
      output = "<a data-confirm=\"Are you sure you want to delete?\" rel=\"nofollow\" data-method=\"delete\" href=\"/providers\"><b class='glyphicon glyphicon-trash'></b></a>"
      expect(icon).to eq(output)
    end

  end
end