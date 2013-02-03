require 'spec_helper'

describe 'Get Transcript Fasta page' do
  it 'should redirect users who are not signed in to the sign-in page'
  it 'should display an error message if the user does not have ' +
     'have permission to access the dataset'
  it 'should succeed when all permissions are correct'
end
