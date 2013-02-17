# == Schema Information
#
# Table name: datasets
#
#  id                      :integer          not null, primary key
#  name                    :string(255)      not null
#  has_transcript_diff_exp :boolean          not null
#  has_transcript_isoforms :boolean          not null
#  has_gene_diff_exp       :boolean          not null
#  blast_db_location       :string(255)      not null
#  user_id                 :integer          not null
#  when_last_queried       :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

# == Schema Information
#
# Table name: datasets
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  blast_db_location :string(255)      not null
#  user_id           :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

# == Schema Information
#
# Table name: datasets
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Dataset do
  #TODO: Ensure this can satisfy use case 8
  pending "add some examples to (or delete) #{__FILE__}"
end
