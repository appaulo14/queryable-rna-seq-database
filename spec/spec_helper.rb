# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'
require 'database_cleaner'
require 'tempfile'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

#Special exception used for testing
class SeededTestException < Exception
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include Devise::TestHelpers, :type => :view
  config.include Devise::TestHelpers, :type => :helper
  #config.extend ControllerMacros, :type => :controller
  #config.include RequestMacros, :type => :request

  DatabaseCleaner.strategy = :truncation
  
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  
  def sign_in(user)
    visit new_user_session_path
    fill_in :user_email,    :with => user.email
    fill_in :user_password, :with => user.password
    click_button('Sign In')
  end
  
  def sign_in_as_nietz111()
    visit new_user_session_path
    find('#user_email').set('nietz111@ksu.edu')
    find('#user_password').set('cis895')
    click_button 'Sign in'
  end
  
  def sign_out()
    visit destroy_user_session_path
  end
  
  def populate_short_list_of_go_terms
    go_term_file = File.open('spec/view_models/query_analysis/test_files/GO.terms_and_ids_short')
    while (not go_term_file.eof?)
      line = go_term_file.readline.chomp
      next if line.match(/\AGO/).nil? #skip if line has no term 
      go_id, go_term = line.match(/\A(GO:\d+)\s+(.+)\s+(.+)\z/).captures()
      GoTerm.create!(:id => go_id, :term => go_term)
    end
  end
  
  def generate_uploaded_file(content)
    tmpfile = Tempfile.new('tempfile')
    tmpfile.write(content)
    return ActionDispatch::Http::UploadedFile.new({:tempfile => tmpfile})
  end
  
  def to_cuffdiff_uploaded_file(number_of_samples,file_name)
    absolute_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                    "test_files/cuffdiff/#{number_of_samples}_samples/"
    absolute_path += file_name
    file = File.new(absolute_path,'r')
    uf = ActionDispatch::Http::UploadedFile.new({:tempfile => file, 
                                                      :filename => file_name})
    return uf
  end
  
  def get_uploaded_trinity_fasta_file
    file_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                "test_files/trinity_with_edger/trinity_out_dir/" +
                "Trinity.fasta"
    file = File.new(file_path,'r')
    uploaded_file = ActionDispatch::Http::UploadedFile.new({
        :tempfile => file, :filename => 'Trinity.fasta'
    })
    return uploaded_file
  end
  
  def get_trinity_diff_exp_files(type, number_of_samples)
    absolute_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                    "test_files/trinity_with_edger/" +
                    "#{number_of_samples}_samples"
    if type == 'trans'
      absolute_path += "/edgeR_trans"
    else
      absolute_path += "/edgeR_components"
    end
    uploaded_files = []
    if number_of_samples >= 2
      f = File.new("#{absolute_path}/ds_#{type}_vs_hs_#{type}.results.txt",'r')
      uploaded_file = ActionDispatch::Http::UploadedFile.new({:tempfile => f})
      uploaded_file.original_filename = "ds_#{type}_vs_hs_#{type}.results.txt"
      uploaded_files << uploaded_file
    end
    if number_of_samples >= 3
      # ds vs ms
      f =  File.new("#{absolute_path}/ds_#{type}_vs_ms_#{type}.results.txt",'r')
      uploaded_file1 = ActionDispatch::Http::UploadedFile.new({:tempfile => f})
      uploaded_file1.original_filename = "ds_#{type}_vs_ms_#{type}.results.txt"
      uploaded_files << uploaded_file1
      # hs vs ms
      f2 = File.new("#{absolute_path}/hs_#{type}_vs_ms_#{type}.results.txt",'r')
      uploaded_file2 = ActionDispatch::Http::UploadedFile.new({:tempfile => f2})
      uploaded_file2.original_filename = "hs_#{type}_vs_ms_#{type}.results.txt"
      uploaded_files << uploaded_file2
    end
    if number_of_samples == 4
      # ds vs qs
      f =  File.new("#{absolute_path}/ds_#{type}_vs_qs_#{type}.results.txt",'r')
      uf = ActionDispatch::Http::UploadedFile.new({:tempfile => f})
      uf.original_filename = "ds_#{type}_vs_qs_#{type}.results.txt"
      uploaded_files << uf
      # hs vs qs
      f2 = File.new("#{absolute_path}/hs_#{type}_vs_qs_#{type}.results.txt",'r')
      uf2 = ActionDispatch::Http::UploadedFile.new({:tempfile => f2})
      uf2.original_filename = "hs_#{type}_vs_qs_#{type}.results.txt"
      uploaded_files << uf2
      # ms vs qs
      f3 = File.new("#{absolute_path}/ms_#{type}_vs_qs_#{type}.results.txt",'r')
      uf3 = ActionDispatch::Http::UploadedFile.new({:tempfile => f3})
      uf3.original_filename = "ms_#{type}_vs_qs_#{type}.results.txt"
      uploaded_files << uf3
    end
    return uploaded_files
  end
  
  def get_trinity_transcript_fpkm_file(number_of_samples)
    absolute_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                    "test_files/trinity_with_edger/" +
                    "#{number_of_samples}_samples/edgeR_trans/" +
                    "matrix.TMM_normalized.FPKM"
    file = File.new(absolute_path)
    return ActionDispatch::Http::UploadedFile.new({:tempfile => file})
  end
  
  def get_trinity_gene_fpkm_file(number_of_samples)
    absolute_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                    "test_files/trinity_with_edger/" +
                    "#{number_of_samples}_samples/edgeR_components/" +
                    "matrix.TMM_normalized.FPKM"
    file = File.new(absolute_path)
    return ActionDispatch::Http::UploadedFile.new({:tempfile => file})
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
