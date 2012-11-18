require 'spec_helper'

describe "query_analysis/upload_de_novo_edgeR.html.erb" do
  
#   before (:each) do
#     
#   end
  
  it "should" do
    lambda do
      visit_path 'query_analysis/upload_de_novo_edgeR'
      click_button 'I have more samples than this'
    end.should have_selector('input', type: 'submit')
  end
end
